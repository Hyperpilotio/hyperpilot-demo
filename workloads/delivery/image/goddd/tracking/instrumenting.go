package tracking

import (
	"time"

	"github.com/go-kit/kit/metrics"

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

func (s *instrumentingService) Track(id string) (Cargo, error) {
	defer func(begin time.Time) {
		s.requestCount.With("method", "track").Add(1)
		s.requestLatency.With("method", "track").Observe(time.Since(begin).Seconds())
	}(time.Now())

	return s.Service.Track(id)
}
