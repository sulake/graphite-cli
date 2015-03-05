# graphite-cli

makes requests to graphite's `/render` API

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
$ graphite --from=-5min --target="randomWalk('randomWalk')" -o csv
randomWalk,2015-03-05 15:32:03,0
randomWalk,2015-03-05 15:33:03,0.21089740446196048
randomWalk,2015-03-05 15:34:03,0.30473267268105897
randomWalk,2015-03-05 15:35:03,0.5150866652261553
randomWalk,2015-03-05 15:36:03,0.2311229472001599
```

read target from clipboard and open the graph in browser

```sh
$ pbpaste | graphite -s -b
```

print graph image url of `target` piped to stdin

```sh
$ echo "randomWalk('randomWalk')" | graphite -s -i
http://graphite/render?from=-1day&target=randomWalk('randomWalk')
```
