# graphite-cli

makes requests to graphite's `/render` API

```sh
$ npm install -g graphite-cli
```

```
Usage: graphite [options]

  -t, --target String  target
  -f, --from String    interval - default: -1day
  -s, --stdin          read target from stdin
  -o, --format String  output format (json, csv, raw)
  -p, --print-target   print target
  -i, --image-url      print graph image URL
  -b, --browser        open as image in browser
  -c, --curl           send graph image data to stdout
  -h, --help           displays help
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

get status codes for last hour summarized into 10min intervals

```sh
$ graphite --target="aliasByNode(summarize(counts.web.status_code.*), '10m', 'sum', false), 6)" \
  --from=-1h | tr '|' , | cut -d',' -f1,5- | sed 's/\.0//g' | column -t -s, | sort -k1
200  176  213  207  227  292  320  0
201  0    0    0    0    2    0    0
202  0    0    0    0    0    0    0
204  0    0    1    0    0    0    0
302  0    2    0    0    0    2    0
304  0    0    0    0    2    4    0
400  1    0    0    0    0    0    0
401  0    0    0    0    0    0    0
404  0    0    0    0    1    0    0
409  0    0    0    0    0    0    0
429  0    0    0    0    0    0    0
500  0    0    0    0    0    0    0
```
