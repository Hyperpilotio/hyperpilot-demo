const PARSER_DATASET = {
    'lucene': [
        {
            'input': `Starting Faban Server
Please point your browser to http://cloudsuite-client-ndz3n:9980/
Buildfile: /usr/src/faban/search/build.xml

init:
    [mkdir] Created dir: /usr/src/faban/search/build/classes

compile:
    [javac] /usr/src/faban/search/build.xml:35: warning: 'includeantruntime' was not set, defaulting to build.sysclasspath=last; set to false for repeatable builds
    [javac] Compiling 1 source file to /usr/src/faban/search/build/classes
    [javac]
    [javac]           WARNING
    [javac]
    [javac] The -source switch defaults to 1.7 in JDK 1.7.
    [javac] If you specify -target 1.5 you now must also specify -source 1.5.
    [javac] Ant will implicitly add -source 1.5 for you.  Please change your build file.
    [javac] warning: [options] bootstrap class path not set in conjunction with -source 1.5
    [javac] 1 warning

bench.jar:
    [mkdir] Created dir: /usr/src/faban/search/build/lib
      [jar] Building jar: /usr/src/faban/search/build/lib/search.jar

deploy.jar:
      [jar] Building jar: /usr/src/faban/search/build/search.jar

deploy:

BUILD SUCCESSFUL
Total time: 8 seconds
Print= 10.36.0.2:1
Aug 03, 2017 9:42:32 AM com.sun.faban.common.RegistryImpl main
INFO: Registry started.
Aug 03, 2017 9:42:35 AM com.sun.faban.common.RegistryImpl reregister
INFO: Registering SearchDriver.1 (type: SearchDriverAgent) on 10.36.0.2
Aug 03, 2017 9:42:35 AM com.sun.faban.common.RegistryImpl reregister
INFO: Registering Master on 10.36.0.2
Aug 03, 2017 9:42:35 AM com.sun.faban.driver.engine.MasterImpl runBenchmark
INFO: RunID for this run is : 1
Aug 03, 2017 9:42:35 AM com.sun.faban.driver.engine.MasterImpl runBenchmark
INFO: Output directory for this run is : /usr/src/outputFaban/1
Aug 03, 2017 9:42:35 AM com.sun.faban.common.RegistryImpl getServices
INFO: Get services by type: SearchDriverAgent
Aug 03, 2017 9:42:35 AM com.sun.faban.driver.engine.MasterImpl configureAgents
INFO: Configuring 1 SearchDriverAgents...
Aug 03, 2017 9:42:35 AM com.sun.faban.driver.util.Timer idleTimerCheck
INFO: SearchDriverAgent[1]: Performing idle timer check
Aug 03, 2017 9:42:36 AM com.sun.faban.driver.util.Timer idleTimerCheck
INFO: SearchDriverAgent[1]: Idle timer characteristics:
Accuracy=3,
min. invocation cost=91,
med. invocation cost (math)=94.0,
med. invocation cost (phys)=94,
avg. invocation cost=96.5769,
max. invocation cost=366,
variance of invocation cost=56.21968639000086.
Aug 03, 2017 9:42:39 AM com.sun.faban.driver.engine.AgentImpl run
INFO: SearchDriverAgent[1]: Successfully started 50 driver threads.
Aug 03, 2017 9:42:40 AM com.sun.faban.driver.engine.MasterImpl executeRun
INFO: Started all threads; run commences in 2998 ms
^C
 ✘ WilliamChen@chenbiweide-MacBook-Air  ~/hyperpilot/hyperpilot-demo/workloads/lucene   add_lucene_workload ●  kubectl logs cloudsuite-client-ndz3n
Starting Faban Server
Please point your browser to http://cloudsuite-client-ndz3n:9980/
Buildfile: /usr/src/faban/search/build.xml

init:
    [mkdir] Created dir: /usr/src/faban/search/build/classes

compile:
    [javac] /usr/src/faban/search/build.xml:35: warning: 'includeantruntime' was not set, defaulting to build.sysclasspath=last; set to false for repeatable builds
    [javac] Compiling 1 source file to /usr/src/faban/search/build/classes
    [javac]
    [javac]           WARNING
    [javac]
    [javac] The -source switch defaults to 1.7 in JDK 1.7.
    [javac] If you specify -target 1.5 you now must also specify -source 1.5.
    [javac] Ant will implicitly add -source 1.5 for you.  Please change your build file.
    [javac] warning: [options] bootstrap class path not set in conjunction with -source 1.5
    [javac] 1 warning

bench.jar:
    [mkdir] Created dir: /usr/src/faban/search/build/lib
      [jar] Building jar: /usr/src/faban/search/build/lib/search.jar

deploy.jar:
      [jar] Building jar: /usr/src/faban/search/build/search.jar

deploy:

BUILD SUCCESSFUL
Total time: 8 seconds
Print= 10.36.0.2:1
Aug 03, 2017 9:42:32 AM com.sun.faban.common.RegistryImpl main
INFO: Registry started.
Aug 03, 2017 9:42:35 AM com.sun.faban.common.RegistryImpl reregister
INFO: Registering SearchDriver.1 (type: SearchDriverAgent) on 10.36.0.2
Aug 03, 2017 9:42:35 AM com.sun.faban.common.RegistryImpl reregister
INFO: Registering Master on 10.36.0.2
Aug 03, 2017 9:42:35 AM com.sun.faban.driver.engine.MasterImpl runBenchmark
INFO: RunID for this run is : 1
Aug 03, 2017 9:42:35 AM com.sun.faban.driver.engine.MasterImpl runBenchmark
INFO: Output directory for this run is : /usr/src/outputFaban/1
Aug 03, 2017 9:42:35 AM com.sun.faban.common.RegistryImpl getServices
INFO: Get services by type: SearchDriverAgent
Aug 03, 2017 9:42:35 AM com.sun.faban.driver.engine.MasterImpl configureAgents
INFO: Configuring 1 SearchDriverAgents...
Aug 03, 2017 9:42:35 AM com.sun.faban.driver.util.Timer idleTimerCheck
INFO: SearchDriverAgent[1]: Performing idle timer check
Aug 03, 2017 9:42:36 AM com.sun.faban.driver.util.Timer idleTimerCheck
INFO: SearchDriverAgent[1]: Idle timer characteristics:
Accuracy=3,
min. invocation cost=91,
med. invocation cost (math)=94.0,
med. invocation cost (phys)=94,
avg. invocation cost=96.5769,
max. invocation cost=366,
variance of invocation cost=56.21968639000086.
Aug 03, 2017 9:42:39 AM com.sun.faban.driver.engine.AgentImpl run
INFO: SearchDriverAgent[1]: Successfully started 50 driver threads.
Aug 03, 2017 9:42:40 AM com.sun.faban.driver.engine.MasterImpl executeRun
INFO: Started all threads; run commences in 2998 ms
 WilliamChen@chenbiweide-MacBook-Air  ~/hyperpilot/hyperpilot-demo/workloads/lucene   add_lucene_workload ●  kubectl logs -f cloudsuite-client-ndz3n
Starting Faban Server
Please point your browser to http://cloudsuite-client-ndz3n:9980/
Buildfile: /usr/src/faban/search/build.xml

init:
    [mkdir] Created dir: /usr/src/faban/search/build/classes

compile:
    [javac] /usr/src/faban/search/build.xml:35: warning: 'includeantruntime' was not set, defaulting to build.sysclasspath=last; set to false for repeatable builds
    [javac] Compiling 1 source file to /usr/src/faban/search/build/classes
    [javac]
    [javac]           WARNING
    [javac]
    [javac] The -source switch defaults to 1.7 in JDK 1.7.
    [javac] If you specify -target 1.5 you now must also specify -source 1.5.
    [javac] Ant will implicitly add -source 1.5 for you.  Please change your build file.
    [javac] warning: [options] bootstrap class path not set in conjunction with -source 1.5
    [javac] 1 warning

bench.jar:
    [mkdir] Created dir: /usr/src/faban/search/build/lib
      [jar] Building jar: /usr/src/faban/search/build/lib/search.jar

deploy.jar:
      [jar] Building jar: /usr/src/faban/search/build/search.jar

deploy:

BUILD SUCCESSFUL
Total time: 8 seconds
Print= 10.36.0.2:1
Aug 03, 2017 9:42:32 AM com.sun.faban.common.RegistryImpl main
INFO: Registry started.
Aug 03, 2017 9:42:35 AM com.sun.faban.common.RegistryImpl reregister
INFO: Registering SearchDriver.1 (type: SearchDriverAgent) on 10.36.0.2
Aug 03, 2017 9:42:35 AM com.sun.faban.common.RegistryImpl reregister
INFO: Registering Master on 10.36.0.2
Aug 03, 2017 9:42:35 AM com.sun.faban.driver.engine.MasterImpl runBenchmark
INFO: RunID for this run is : 1
Aug 03, 2017 9:42:35 AM com.sun.faban.driver.engine.MasterImpl runBenchmark
INFO: Output directory for this run is : /usr/src/outputFaban/1
Aug 03, 2017 9:42:35 AM com.sun.faban.common.RegistryImpl getServices
INFO: Get services by type: SearchDriverAgent
Aug 03, 2017 9:42:35 AM com.sun.faban.driver.engine.MasterImpl configureAgents
INFO: Configuring 1 SearchDriverAgents...
Aug 03, 2017 9:42:35 AM com.sun.faban.driver.util.Timer idleTimerCheck
INFO: SearchDriverAgent[1]: Performing idle timer check
Aug 03, 2017 9:42:36 AM com.sun.faban.driver.util.Timer idleTimerCheck
INFO: SearchDriverAgent[1]: Idle timer characteristics:
Accuracy=3,
min. invocation cost=91,
med. invocation cost (math)=94.0,
med. invocation cost (phys)=94,
avg. invocation cost=96.5769,
max. invocation cost=366,
variance of invocation cost=56.21968639000086.
Aug 03, 2017 9:42:39 AM com.sun.faban.driver.engine.AgentImpl run
INFO: SearchDriverAgent[1]: Successfully started 50 driver threads.
Aug 03, 2017 9:42:40 AM com.sun.faban.driver.engine.MasterImpl executeRun
INFO: Started all threads; run commences in 2998 ms
Aug 03, 2017 9:43:28 AM com.sun.faban.driver.util.Timer$BusyTimerMeter run
INFO: SearchDriverAgent[1]: Performing busy timer check
Aug 03, 2017 9:43:29 AM com.sun.faban.driver.util.Timer$BusyTimerMeter run
INFO: SearchDriverAgent[1]: Busy timer characteristics:
Accuracy=3,
min. invocation cost=91,
med. invocation cost (math)=122.0,
med. invocation cost (phys)=122,
avg. invocation cost=118.9738,
max. invocation cost=1879,
variance of invocation cost=821.3523135600336.
Aug 03, 2017 9:44:13 AM com.sun.faban.driver.util.Timer$SleepCalibrator run
INFO: SearchDriverAgent[1]: Calibration succeeded. Sleep time deviation: 0.2742320119176598 ms, compensation: 1 ms.
Aug 03, 2017 9:44:13 AM com.sun.faban.driver.engine.MasterImpl executeRun
INFO: Ramp up completed
Aug 03, 2017 9:45:13 AM com.sun.faban.driver.engine.MasterImpl executeRun
INFO: Steady state completed
Aug 03, 2017 9:46:13 AM com.sun.faban.driver.engine.MasterImpl executeRun
INFO: Ramp down completed
Aug 03, 2017 9:46:13 AM com.sun.faban.driver.engine.MasterImpl getDriverMetrics
INFO: Gathering SearchDriverStats ...
Aug 03, 2017 9:46:13 AM com.sun.faban.driver.engine.MasterImpl generateReports
INFO: Printing Summary report ...
Aug 03, 2017 9:46:13 AM com.sun.faban.driver.engine.MasterImpl generateReports
INFO: Summary finished. Now printing detail ...
Aug 03, 2017 9:46:13 AM com.sun.faban.driver.engine.MasterImpl generateReports
INFO: Detail finished. Results written to /usr/src/outputFaban/1.
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="../../xslt/summary_report.xsl"?>
<benchResults>
    <benchSummary name="Sample Search Workload" version="0.3">
        <runId>1</runId>
        <startTime>Thu Aug 03 09:42:43 UTC 2017</startTime>
        <endTime>Thu Aug 03 09:46:13 UTC 2017</endTime>
        <metric unit="ops/sec">24.333</metric>
        <passed>true</passed>
    </benchSummary>
    <driverSummary name="SearchDriver">
        <metric unit="ops/sec">24.333</metric>
        <startTime>Thu Aug 03 09:42:43 UTC 2017</startTime>
        <endTime>Thu Aug 03 09:46:13 UTC 2017</endTime>
        <totalOps unit="operations">1460</totalOps>
        <users>50</users>
        <rtXtps>46.8968</rtXtps>
        <passed>true</passed>
        <mix allowedDeviation="0.0000">
            <operation name="GET">
                <successes>1460</successes>
                <failures>0</failures>
                <mix>1.0000</mix>
                <requiredMix>1.0000</requiredMix>
                <passed>true</passed>
            </operation>
        </mix>
        <responseTimes unit="seconds">
            <operation name="GET" r90th="0.500">
                <avg>0.029</avg>
                <max>0.156</max>
                <sd>0.023</sd>
                <p90th>0.060</p90th>
                <passed>true</passed>
                <p99th>0.110</p99th>
            </operation>
        </responseTimes>
        <delayTimes>
            <operation name="GET" type="cycleTime">
                <targetedAvg>1.995</targetedAvg>
                <actualAvg>1.994</actualAvg>
                <min>0.009</min>
                <max>10.000</max>
                <passed>true</passed>
            </operation>
        </delayTimes>
    </driverSummary>
</benchResults>`,
            'expect': {
                'ops/sec': 24.333
            }
        }
    ]
};

module.exports = {
    'PARSER_DATASET': PARSER_DATASET
};
