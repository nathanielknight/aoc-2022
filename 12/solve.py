import collections
import dataclasses
import heapq
import math
import time
import typing as ty


Point = ty.Tuple[int, int]


@dataclasses.dataclass
class Map:
    raw: ty.Dict[Point, str]
    heights: ty.Dict[Point, int]
    bounds: ty.Tuple[int, int]
    start: Point
    end: Point


def read_map(inf):
    raw = dict()
    heights = dict()
    src = [l.strip() for l in inf.readlines() if l.strip()]
    start = (0, 0)
    end = (0, 0)
    for (y, line) in enumerate(src):
        for (x, c) in enumerate(line):
            raw[(x, y)] = c
            if c.islower():
                heights[(x, y)] = ord(c)
            else:
                if c == "S":
                    start = (x, y)
                    heights[(x, y)] = ord("a")
                if c == "E":
                    end = (x, y)
                    heights[(x, y)] = ord("z")
    return Map(raw, heights, (x, y), start, end)


def neighbor_points(p: Point) -> ty.Iterable[Point]:
    (x, y) = p
    yield (x + 1, y)
    yield (x - 1, y)
    yield (x, y + 1)
    yield (x, y - 1)


def make_neighbors(heights: ty.Dict[Point, int]) -> ty.Dict[Point, ty.Set[Point]]:
    neighbors = {p: set() for p in heights}
    for p, p_height in heights.items():
        for n in neighbor_points(p):
            if (n_height := heights.get(n)) is not None:
                if n_height <= p_height + 1:
                    neighbors[p].add(n)
    return neighbors


def astar_search(map: Map) -> ty.List[Point]:
    """Implementation of A-Start based on https://en.wikipedia.org/wiki/A*_search_algorithm."""

    start = map.start
    end = map.end
    neighbors = make_neighbors(map.heights)

    def heuristic(p):
        # NB: I experimented with a few heuristics for this one: manhattan
        # distance, square distance, and cartesian distance. Cartesian distance
        # gave the right answer, so I stuck with that.
        (x1, y1) = p
        (x2, y2) = end
        return abs(y2 - y1) + abs(x2 - x1)

    def reconstruct_path(start: Point, came_from) -> ty.List[Point]:
        path = [start]
        current = start
        while current in came_from:
            current = came_from[current]
            path.append(current)
        return list(reversed(path))

    def print_map():
        for y in range(40):
            chars = (
                "." if (x, y) in came_from else map.raw.get((x, y), "#")
                for x in range(172)
            )
            print("".join(chars))
        print(88 * "-")

    # points that still need to be considered
    to_check = []
    heapq.heappush(to_check, (heuristic(start), start))
    # n -> preceding point in cheapest known path from n to start
    came_from = dict()
    # n -> cost of cheapest path to n
    gscore = collections.defaultdict(lambda: float("inf"))
    gscore[start] = 0
    # n -> estimate of how cheap path through n could be
    fscore = collections.defaultdict(lambda: float("inf"))
    fscore[start] = heuristic(start)

    while len(to_check) > 0:
        (_, current) = heapq.heappop(to_check)
        if current == end:
            return reconstruct_path(current, came_from)
        for neighbor in neighbors[current]:
            # nb: all edges have weight of 1
            tentative_gscore = gscore[current] + 1
            if tentative_gscore < gscore[neighbor]:
                came_from[neighbor] = current
                gscore[neighbor] = tentative_gscore
                fscore[neighbor] = tentative_gscore + heuristic(neighbor)
                if neighbor not in set(p for _, p in to_check):
                    heapq.heappush(to_check, (fscore[neighbor], neighbor))
    raise ValueError("No path from start to finish is possible")


def hiking_trail(m: Map) -> ty.List[Point]:
    "This worked on the first try and ran in less than a minute. LML"
    candidate_starting_points = [p for p, v in m.heights.items() if v == ord("a")]
    candidates = len(candidate_starting_points)
    trail = [(0, 0) for _ in range(9999)]
    for cnd, pos in enumerate(candidate_starting_points):
        if cnd % 50 == 0:
            print(f"{cnd} / {candidates}")
        try:
            candidate_trail = astar_search(dataclasses.replace(m, start=pos))
            if len(candidate_trail) < len(trail):
                trail = candidate_trail
        except ValueError:
            continue
    return trail


if __name__ == "__main__":
    with open("./input.txt") as inf:
        m = read_map(inf)
    path = astar_search(m)
    print(path)
    print("Part 1:", len(path) - 1)
    trail = hiking_trail(m)
    print("Part 2: ", len(trail) - 1)
