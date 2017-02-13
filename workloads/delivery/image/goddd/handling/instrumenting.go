package handling

import (
	"time"

	"github.com/go-kit/kit/metrics"

	"github.com/marcusolsson/goddd/cargo"
	"github.com/marcusolsson/goddd/location"
	"github.com/marcusolsson/goddd/voyage"

	"github.com/marcusolsson/goddd/mock"
)

type instrumentingService struct {
	requestCount   metrics.Counter
	requestLatency metrics.Histogram
	Service
	*mock.Store
}

// NewInstrumentingService returns an instance of an instrumenting Service.
func NewInstrumentingService(counter metrics.Counter, latency metrics.Histogram, s Service, store *mock.Store) Service {
	return &instrumentingService{
		requestCount:   counter,
		requestLatency: latency,
		Service:        s,
		Store:          store,
	}
}

func (s *instrumentingService) RegisterHandlingEvent(completed time.Time, id cargo.TrackingID, voyageNumber voyage.Number,
	loc location.UNLocode, eventType cargo.HandlingEventType) error {

	defer func(begin time.Time) {
		s.requestCount.With("method", "register_incident").Add(1)
		s.requestLatency.With("method", "register_incident").Observe(time.Since(begin).Seconds())
	}(time.Now())

	return s.Service.RegisterHandlingEvent(completed, id, voyageNumber, loc, eventType)
}
