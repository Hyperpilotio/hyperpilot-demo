package main

import (
	"fmt"
	"io/ioutil"
	"os"

	"github.com/bitly/go-simplejson"
)

var PATH = "/var/lib/grafana/initial/"

func writeDatasource(source string, target string, influxDBName string) {
	datasource, err := ioutil.ReadFile(PATH + source)
	if err != nil {
		panic(err)
	}
	dsJson, err := simplejson.NewJson(datasource)
	if err != nil {
		panic(err)
	}
	dsJson.Set("Name", os.Getenv("SNAP_DS_NAME"))
	dsJson.Set("Url", fmt.Sprintf("http://%s:%s", os.Getenv("INFLUXDB_HOST"), os.Getenv("INFLUXDB_PORT")))
	dsJson.Set("BasicAuthUser", os.Getenv("INFLUXDB_USER"))
	dsJson.Set("BasicAuthPassword", os.Getenv("INFLUXDB_PASS"))
	dsJson.Set("Database", influxDBName)
	marshalled, err := dsJson.MarshalJSON()
	if err != nil {
		panic(err)
	}
	err = ioutil.WriteFile(PATH+target, marshalled, 0644)
	if err != nil {
		panic(err)
	}
}

func writeDashboardSources(source string, target string) {
	dashboard, err := ioutil.ReadFile(PATH + source)
	if err != nil {
		panic(err)
	}
	dbJson, err := simplejson.NewJson(dashboard)
	if err != nil {
		panic(err)
	}
	dbJson.Get("inputs").GetIndex(0).Set("value", os.Getenv("SNAP_DS_NAME"))
	dbJson.Get("inputs").GetIndex(1).Set("value", os.Getenv("SPARK_DS_NAME"))
	marshalled, err := dbJson.MarshalJSON()
	if err != nil {
		panic(err)
	}
	err = ioutil.WriteFile(PATH+target, marshalled, 0644)
	if err != nil {
		panic(err)
	}
}

func main() {
	writeDatasource("snap-influx-datasource-default.json", "snap-influx-datasource.json", os.Getenv("INFLUXDB_NAME_SNAP"))
	writeDatasource("spark-influx-datasource-default.json", "spark-influx-datasource.json", os.Getenv("INFLUXDB_NAME_SPARK"))
	writeDashboardSources("demo-dashboard-default.json", "demo-dashboard.json")
	writeDashboardSources("internal-dashboard-default.json", "internal-dashboard.json")
}
