package main

import (
	"flag"
	"fmt"
	"net/http"
	"os"
	"os/signal"
	"sync"
	"syscall"
	"time"

	stdinfluxdb "github.com/influxdata/influxdb/client/v2"
	"golang.org/x/net/context"
	"gopkg.in/mgo.v2"

	"github.com/go-kit/kit/log"
	kitinfluxdb "github.com/go-kit/kit/metrics/influx"

	"github.com/marcusolsson/goddd/booking"
	"github.com/marcusolsson/goddd/cargo"
	"github.com/marcusolsson/goddd/handling"
	"github.com/marcusolsson/goddd/inmem"
	"github.com/marcusolsson/goddd/inspection"
	"github.com/marcusolsson/goddd/location"
	"github.com/marcusolsson/goddd/mock"
	"github.com/marcusolsson/goddd/mongo"
	"github.com/marcusolsson/goddd/routing"
	"github.com/marcusolsson/goddd/tracking"
	"github.com/marcusolsson/goddd/voyage"
)

const (
	defaultPort              = "8080"
	defaultRoutingServiceURL = "http://localhost:7878"
	defaultMongoDBURL        = "127.0.0.1"
	defaultDBName            = "dddsample"
)

func main() {
	var (
		addr   = envString("PORT", defaultPort)
		rsurl  = envString("ROUTINGSERVICE_URL", defaultRoutingServiceURL)
		dburl  = envString("MONGODB_URL", defaultMongoDBURL)
		dbname = envString("DB_NAME", defaultDBName)

		httpAddr          = flag.String("http.addr", ":"+addr, "HTTP listen address")
		routingServiceURL = flag.String("service.routing", rsurl, "routing service URL")
		mongoDBURL        = flag.String("db.url", dburl, "MongoDB URL")
		databaseName      = flag.String("db.name", dbname, "MongoDB database name")
		inmemory          = flag.Bool("inmem", false, "use in-memory repositories")

		ctx = context.Background()
	)

	flag.Parse()

	var logger log.Logger
	logger = log.NewLogfmtLogger(os.Stderr)
	logger = &serializedLogger{Logger: logger}
	logger = log.NewContext(logger).With("ts", log.DefaultTimestampUTC)

	// Setup repositories
	var (
		cargos         cargo.Repository
		locations      location.Repository
		voyages        voyage.Repository
		handlingEvents cargo.HandlingEventRepository
	)

	if *inmemory {
		cargos = inmem.NewCargoRepository()
		locations = inmem.NewLocationRepository()
		voyages = inmem.NewVoyageRepository()
		handlingEvents = inmem.NewHandlingEventRepository()
	} else {
		session, err := mgo.Dial(*mongoDBURL)
		if err != nil {
			panic(err)
		}
		defer session.Close()

		session.SetMode(mgo.Monotonic, true)

		cargos, _ = mongo.NewCargoRepository(*databaseName, session)
		locations, _ = mongo.NewLocationRepository(*databaseName, session)
		voyages, _ = mongo.NewVoyageRepository(*databaseName, session)
		handlingEvents = mongo.NewHandlingEventRepository(*databaseName, session)
	}

	// Configure some questionable dependencies.
	var (
		handlingEventFactory = cargo.HandlingEventFactory{
			CargoRepository:    cargos,
			VoyageRepository:   voyages,
			LocationRepository: locations,
		}
		handlingEventHandler = handling.NewEventHandler(
			inspection.NewService(cargos, handlingEvents, nil),
		)
	)

	// Facilitate testing by adding some cargos.
	storeTestData(cargos)

	var rs routing.Service
	rs = routing.NewProxyingMiddleware(ctx, *routingServiceURL)(rs)

	// FIXME refactor the initiation of influxdb
	client, err := stdinfluxdb.NewHTTPClient(stdinfluxdb.HTTPConfig{
		Addr:     "http://localhost:8086",
		Username: "user123",
		Password: "user123",
	})

	if err != nil {
		logger.Log("influxdb", "connectTo", "http://influxdb:8086", "failed")
	} else {
		fmt.Println("Connect to influxdb!!!!!!!!!")
	}

	var bs booking.Service
	bs = booking.NewService(cargos, locations, handlingEvents, rs)
	bs = booking.NewLoggingService(log.NewContext(logger).With("component", "booking"), bs)
	bookServiceInflux := kitinfluxdb.New(map[string]string{"namespace": "api", "subsystem": "booking_service"}, stdinfluxdb.BatchPointsConfig{
		Database:  "goddd",
		Precision: "s",
	}, log.NewNopLogger())
	bsStore := mock.NewStore(bookServiceInflux, &client)
	bs = booking.NewInstrumentingService(
		bookServiceInflux.NewCounter("request_count"),
		bookServiceInflux.NewHistogram("request_latency_microseconds"),
		bs,
		bsStore,
	)

	var ts tracking.Service
	trackingServiceInflux := kitinfluxdb.New(map[string]string{"namespace": "api", "subsystem": "tracking_service"}, stdinfluxdb.BatchPointsConfig{
		Database:  "goddd",
		Precision: "s",
	}, log.NewNopLogger())
	tsStore := mock.NewStore(trackingServiceInflux, &client)
	ts = tracking.NewService(cargos, handlingEvents)
	ts = tracking.NewLoggingService(log.NewContext(logger).With("component", "tracking"), ts)
	ts = tracking.NewInstrumentingService(
		trackingServiceInflux.NewCounter("request_count"),
		trackingServiceInflux.NewHistogram("request_latency_microseconds"),
		ts,
		tsStore,
	)

	var hs handling.Service
	handlingServiceInflux := kitinfluxdb.New(map[string]string{"namespace": "api", "subsystem": "handling_service"}, stdinfluxdb.BatchPointsConfig{
		Database:  "goddd",
		Precision: "s",
	}, log.NewNopLogger())
	hsStore := mock.NewStore(handlingServiceInflux, &client)
	hs = handling.NewService(handlingEvents, handlingEventFactory, handlingEventHandler)
	hs = handling.NewLoggingService(log.NewContext(logger).With("component", "handling"), hs)
	hs = handling.NewInstrumentingService(
		handlingServiceInflux.NewCounter("request_count"),
		handlingServiceInflux.NewHistogram("request_latency_microseconds"),
		hs,
		hsStore,
	)

	bsStore.SaveMetrics(client)
	tsStore.SaveMetrics(client)
	hsStore.SaveMetrics(client)

	httpLogger := log.NewContext(logger).With("component", "http")

	mux := http.NewServeMux()

	mux.Handle("/booking/v1/", booking.MakeHandler(ctx, bs, httpLogger))
	mux.Handle("/tracking/v1/", tracking.MakeHandler(ctx, ts, httpLogger))
	mux.Handle("/handling/v1/", handling.MakeHandler(ctx, hs, httpLogger))

	http.Handle("/", accessControl(mux))

	errs := make(chan error, 2)
	go func() {
		logger.Log("transport", "http", "address", *httpAddr, "msg", "listening")
		errs <- http.ListenAndServe(*httpAddr, nil)
	}()
	go func() {
		c := make(chan os.Signal)
		signal.Notify(c, syscall.SIGINT)
		errs <- fmt.Errorf("%s", <-c)
	}()

	logger.Log("terminated", <-errs)
}

func accessControl(h http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Origin, Content-Type")

		if r.Method == "OPTIONS" {
			return
		}

		h.ServeHTTP(w, r)
	})
}

func envString(env, fallback string) string {
	e := os.Getenv(env)
	if e == "" {
		return fallback
	}
	return e
}

func storeTestData(r cargo.Repository) {
	test1 := cargo.New("FTL456", cargo.RouteSpecification{
		Origin:          location.AUMEL,
		Destination:     location.SESTO,
		ArrivalDeadline: time.Now().AddDate(0, 0, 7),
	})
	if err := r.Store(test1); err != nil {
		panic(err)
	}

	test2 := cargo.New("ABC123", cargo.RouteSpecification{
		Origin:          location.SESTO,
		Destination:     location.CNHKG,
		ArrivalDeadline: time.Now().AddDate(0, 0, 14),
	})
	if err := r.Store(test2); err != nil {
		panic(err)
	}
}

type serializedLogger struct {
	mtx sync.Mutex
	log.Logger
}

func (l *serializedLogger) Log(keyvals ...interface{}) error {
	l.mtx.Lock()
	defer l.mtx.Unlock()
	return l.Logger.Log(keyvals...)
}
