- Encountered a compiler bug
- Chapel solution is quite fast
- Difficult to pass iterators around


# Timing

Chapel:

```shell
$ time ./solve
./solve  105.51s user 0.04s system 199% cpu 52.858 total
```

Python:

```
$ time py ./solve.py
py solve.py  196.56s user 0.02s system 99% cpu 3:16.67 total
```

These were collected on my homeserver (an old thinkpad with a two core i5 2.6
GHz processor).
