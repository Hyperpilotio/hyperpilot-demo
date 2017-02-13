package mock

import (
	"github.com/marcusolsson/goddd/cargo"
	"github.com/marcusolsson/goddd/location"
	"github.com/marcusolsson/goddd/voyage"

	"time"

	kitinfluxdb "github.com/go-kit/kit/metrics/influx"
	stdinfluxdb "github.com/influxdata/influxdb/client/v2"
)

// CargoRepository is a mock cargo repository.
type CargoRepository struct {
	StoreFn      func(c *cargo.Cargo) error
	StoreInvoked bool

	FindFn      func(id cargo.TrackingID) (*cargo.Cargo, error)
	FindInvoked bool

	FindAllFn      func() []*cargo.Cargo
	FindAllInvoked bool
}

// Store calls the StoreFn.
func (r *CargoRepository) Store(c *cargo.Cargo) error {
	r.StoreInvoked = true
	return r.StoreFn(c)
}

// Find calls the FindFn.
func (r *CargoRepository) Find(id cargo.TrackingID) (*cargo.Cargo, error) {
	r.FindInvoked = true
	return r.FindFn(id)
}

// FindAll calls the FindAllFn.
func (r *CargoRepository) FindAll() []*cargo.Cargo {
	r.FindAllInvoked = true
	return r.FindAllFn()
}

// LocationRepository is a mock location repository.
type LocationRepository struct {
	FindFn      func(location.UNLocode) (*location.Location, error)
	FindInvoked bool

	FindAllFn      func() []*location.Location
	FindAllInvoked bool
}

// Find calls the FindFn.
func (r *LocationRepository) Find(locode location.UNLocode) (*location.Location, error) {
	r.FindInvoked = true
	return r.FindFn(locode)
}

// FindAll calls the FindAllFn.
func (r *LocationRepository) FindAll() []*location.Location {
	r.FindAllInvoked = true
	return r.FindAllFn()
}

// VoyageRepository is a mock voyage repository.
type VoyageRepository struct {
	FindFn      func(voyage.Number) (*voyage.Voyage, error)
	FindInvoked bool
}

// Find calls the FindFn.
func (r *VoyageRepository) Find(number voyage.Number) (*voyage.Voyage, error) {
	r.FindInvoked = true
	return r.FindFn(number)
}

// HandlingEventRepository is a mock handling events repository.
type HandlingEventRepository struct {
	StoreFn      func(cargo.HandlingEvent)
	StoreInvoked bool

	QueryHandlingHistoryFn      func(cargo.TrackingID) cargo.HandlingHistory
	QueryHandlingHistoryInvoked bool
}

// Store calls the StoreFn.
func (r *HandlingEventRepository) Store(e cargo.HandlingEvent) {
	r.StoreInvoked = true
	r.StoreFn(e)
}

// QueryHandlingHistory calls the QueryHandlingHistoryFn.
func (r *HandlingEventRepository) QueryHandlingHistory(id cargo.TrackingID) cargo.HandlingHistory {
	r.QueryHandlingHistoryInvoked = true
	return r.QueryHandlingHistoryFn(id)
}

// RoutingService provides a mock routing service.
type RoutingService struct {
	FetchRoutesFn      func(cargo.RouteSpecification) []cargo.Itinerary
	FetchRoutesInvoked bool
}

// FetchRoutesForSpecification calls the FetchRoutesFn.
func (s *RoutingService) FetchRoutesForSpecification(rs cargo.RouteSpecification) []cargo.Itinerary {
	s.FetchRoutesInvoked = true
	return s.FetchRoutesFn(rs)
}

// Store manage metrics
type Store struct {
	*kitinfluxdb.Influx
	client *stdinfluxdb.Client
}

// SaveMetrics send metrics to influxdb.
func (store *Store) SaveMetrics(w kitinfluxdb.BatchPointsWriter) {
	// NOTE: After send metrics to influxdb, the counter will be reset

	tickChan := time.NewTicker(time.Minute * 1).C
	go func() {
		store.Influx.WriteLoop(tickChan, w)
	}()
}

// NewStore returns an instance of Store struct
func NewStore(influx *kitinfluxdb.Influx, client *stdinfluxdb.Client) *Store {
	return &Store{
		Influx: influx,
		client: client,
	}
}
