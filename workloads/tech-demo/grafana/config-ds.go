package main

import (
	"fmt"
	"os"
	"io/ioutil"
	"github.com/bitly/go-simplejson"
)


func main() {
	path := "/var/lib/grafana/initial/"
	datasource, err := ioutil.ReadFile(path + "snap-influx-datasource-default.json")
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
	dsJson.Set("Database", os.Getenv("INFLUXDB_NAME"))
	marshalled, err := dsJson.MarshalJSON()
	if err != nil {
		panic(err)
	}
	err = ioutil.WriteFile(path + "snap-influx-datasource.json", marshalled, 0644)

	dashboard, err := ioutil.ReadFile(path + "demo-dashboard-default.json")
	if err != nil {
		panic(err)
	}
	dbJson, err := simplejson.NewJson(dashboard)
	if err != nil {
		panic(err)
	}
	dbJson.Get("inputs").GetIndex(0).Set("value", os.Getenv("SNAP_DS_NAME"))
	marshalled, err = dbJson.MarshalJSON()
	if err != nil {
		panic(err)
	}
	err = ioutil.WriteFile(path + "demo-dashboard.json", marshalled, 0644)
}
