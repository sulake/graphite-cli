# graphite-cli

```sh
$ npm install -g graphite-cli
```

```
Usage: graphite [options]

  -t, --target String         target
  -f, --from String           interval (default: -1day)
  -s, --stdin                 read target from stdin
  -o, --format String         output format (json, csv, raw)
  -p, --print-target          print target
  -i, --image-url             print image graph URL
  -b, --browser               open as image in browser
  -h, --help                  displays help
```

### setup

`graphite-cli` reads URL to graphite from `GRAPHITE_URL` environment variable

```sh
$ export GRAPHITE_URL=http://graphite
```

### examples

get data for a random walk as JSON for last 5 minutes

```sh
$ graphite --from=-5m --target="randomWalk('randomWalk')" -o json
```

read target from clipboard and open the graph in browser

```sh
$ pbpaste | graphite -s -b
```
