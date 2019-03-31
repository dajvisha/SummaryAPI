# :fax: Summary API

## Installation

Before to execute SummaryAPI fetch deps with the following command:

`mix deps.get`

## Execute

In order to execute SummaryAPI run the following command:

`iex -S mix`

And write:

`Summary.start()`

That command will fetch Users and Movements records to generate to report, and then it will send the report to the given endpoint. At the end it will display the logs like these:

```
The report has been sent correctly.

Genereting and sending the report took: 9 seconds
The number of requests made to users was: 7
The number of requests made to movements was: 83
```

## Run Tests

In order to run tests, you must write the following command:

`mix test`

## Generate documention

If you want to generate the documentation for SummaryAPI run the following command:

`mix docs`

It will generate a `doc/index.html` file, open it. 
