package main

import (
	"flag"
	"fmt"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"golang.org/x/net/context"

	"github.com/go-kit/kit/log"
	"github.com/marcusolsson/pathfinder"

	kitinfluxdb "github.com/go-kit/kit/metrics/influx"
	stdinfluxdb "github.com/influxdata/influxdb/client/v2"
)

const defaultPort = "8080"

func main() {
	var (
		addr     = envString("PORT", defaultPort)
		httpAddr = flag.String("http.addr", ":"+addr, "HTTP listen address")

		ctx = context.Background()
	)

	flag.Parse()

	var logger log.Logger
	logger = log.NewLogfmtLogger(os.Stderr)
	logger = log.NewContext(logger).With("ts", log.DefaultTimestampUTC)

	// FIXME refactor the initiation of influxdb
	client, err := stdinfluxdb.NewHTTPClient(stdinfluxdb.HTTPConfig{
		Addr:     "http://localhost:8086",
		Username: "user123",
		Password: "user123",
	})

	if err != nil {
		logger.Log("influxdb", "connectTo", "http://influxdb:8086", "failed")
	} else {
		fmt.Println("Connect to influxdb.")
	}

	pathServiceInfluxdb := kitinfluxdb.New(map[string]string{"namespace": "api", "subsystem": "pathfinder_service"}, stdinfluxdb.BatchPointsConfig{
		Database:  "pathfinder",
		Precision: "s",
	}, log.NewNopLogger())

	tickChan := time.NewTicker(time.Minute * 1).C
	go func() {
		pathServiceInfluxdb.WriteLoop(tickChan, client)
	}()

	var ps pathfinder.PathService
	psStat := pathfinder.NewPathServiceStat(pathServiceInfluxdb.NewCounter("request_count"), pathServiceInfluxdb.NewHistogram("request_latency_microseconds"))
	ps = pathfinder.NewPathService()
	ps = pathfinder.NewLoggingService(log.NewContext(logger).With("component", "path"), ps)

	httpLogger := log.NewContext(logger).With("component", "http")
	http.Handle("/", pathfinder.MakeHTTPHandler(ctx, ps, httpLogger, psStat))

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

func envString(env, fallback string) string {
	e := os.Getenv(env)
	if e == "" {
		return fallback
	}
	return e
}
