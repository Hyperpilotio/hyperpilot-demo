package pathfinder

import (
	"github.com/go-kit/kit/metrics"
	"github.com/marcusolsson/pathfinder/path"
)

// PathService provides the shortest path "algoritm".
type PathService interface {
	ShortestPath(origin, destination string) ([]path.TransitPath, error)
}

type pathService struct{}

type PathServiceStat struct {
	requestLatency metrics.Histogram
	requestCount   metrics.Counter
}

func NewPathService() PathService {
	return pathService{}
}

// NewPathServiceStat rerutn instance of pathServiceStat
func NewPathServiceStat(counter metrics.Counter, latency metrics.Histogram) *PathServiceStat {
	return &PathServiceStat{
		requestLatency: latency,
		requestCount:   counter,
	}
}

func (pathService) ShortestPath(origin, destination string) ([]path.TransitPath, error) {
	if origin == "" || destination == "" {
		return nil, errInvalidArgument
	}
	return path.FindShortestPath(origin, destination), nil
}
