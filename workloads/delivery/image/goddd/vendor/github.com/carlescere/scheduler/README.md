# scheduler
[![GoDoc](https://godoc.org/github.com/carlescere/scheduler?status.svg)](https://godoc.org/github.com/carlescere/scheduler)
[![Build Status](https://travis-ci.org/carlescere/scheduler.svg?branch=master)](https://travis-ci.org/carlescere/scheduler)
[![Coverage Status](https://coveralls.io/repos/carlescere/scheduler/badge.svg?branch=master)](https://coveralls.io/r/carlescere/scheduler?branch=master)

Job scheduling made easy.

Scheduler allows you to schedule recurrent jobs with an easy-to-read syntax.

Inspired by the article **[Rethinking Cron](http://adam.heroku.com/past/2010/4/13/rethinking_cron/)** and the **[schedule](https://github.com/dbader/schedule)** python module.

## How to use
```go
job := func() {
      fmt.Println("Time's up!")
}

scheduler.Every(5).Minutes().Run(job)
scheduler.Every().Day().Run(job)
scheduler.Every().Monday().At("08:30").Run(job)
```

## License
Distributed under MIT license. See `LICENSE` for more information.
