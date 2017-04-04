package main

import (
	"fmt"
	"github.com/bitly/go-simplejson"
	"io/ioutil"
	"os"
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
	dsJson.Set("Database", os.Getenv("INFLUXDB_NAME_SNAP"))
	marshalled, err := dsJson.MarshalJSON()
	if err != nil {
		panic(err)
	}
	err = ioutil.WriteFile(path+"snap-influx-datasource.json", marshalled, 0644)

	datasource2, err := ioutil.ReadFile(path + "spark-influx-datasource-default.json")
	if err != nil {
		panic(err)
	}
	dsJson2, err := simplejson.NewJson(datasource2)
	if err != nil {
		panic(err)
	}
	dsJson2.Set("Name", os.Getenv("SPARK_DS_NAME"))
	dsJson2.Set("Url", fmt.Sprintf("http://%s:%s", os.Getenv("INFLUXDB_HOST"), os.Getenv("INFLUXDB_PORT")))
	dsJson2.Set("BasicAuthUser", os.Getenv("INFLUXDB_USER"))
	dsJson2.Set("BasicAuthPassword", os.Getenv("INFLUXDB_PASS"))
	dsJson2.Set("Database", os.Getenv("INFLUXDB_NAME_SPARK"))
	marshalled, err = dsJson2.MarshalJSON()
	if err != nil {
		panic(err)
	}
	err = ioutil.WriteFile(path+"spark-influx-datasource.json", marshalled, 0644)

	dashboard, err := ioutil.ReadFile(path + "demo-dashboard-default.json")
	if err != nil {
		panic(err)
	}
	dbJson, err := simplejson.NewJson(dashboard)
	if err != nil {
		panic(err)
	}
	dbJson.Get("inputs").GetIndex(0).Set("value", os.Getenv("SNAP_DS_NAME"))
	dbJson.Get("inputs").GetIndex(1).Set("value", os.Getenv("SPARK_DS_NAME"))
	marshalled, err = dbJson.MarshalJSON()
	if err != nil {
		panic(err)
	}
	err = ioutil.WriteFile(path+"demo-dashboard.json", marshalled, 0644)
}
