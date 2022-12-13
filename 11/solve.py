import collections
import functools
import logging
import operator
import re

logging.basicConfig(level=logging.WARN)

log = logging.getLogger(__name__)


def operation_fn(operation):
    return eval(f"lambda old: {operation}")


def test_fn(m: int):
    return lambda n: (n % int(m)) == 0


class Monkey:
    monkeys = {}

    def __init__(self, id, items, operation, testdiv, true_recipient, false_recipient):
        self.id = id
        self.items = collections.deque(items)
        self.operation = operation_fn(operation)
        self.test = test_fn(testdiv)
        self.divisor = int(testdiv)
        self.true_recipient = true_recipient
        self.false_recipient = false_recipient
        self.monkeys[id] = self
        self.inspections = 0

    @classmethod
    def parse(cls, src: str):
        pattern = re.compile(
            r"""Monkey (\d+):
  Starting items: ([^\n]+)
  Operation: new = ([^\n]+)
  Test: divisible by (\d+)
    If true: throw to monkey (\d+)
    If false: throw to monkey (\d+)"""
        )
        match = pattern.match(src)
        assert match, src
        id, item_src, op_src, testdiv, true_recip, false_recip = match.groups()
        items = [int(d) for d in item_src.split(", ")]
        return cls(id, items, op_src, testdiv, true_recip, false_recip)

    def inspect(self):
        self.inspections += 1
        return self.items.popleft()

    def send_to(self, item, recipient):
        self.monkeys[recipient].receive(item)

    def receive(self, item):
        self.items.append(item)


def load_monkeys(inf):
    src = inf.read().split("\n\n")
    return [Monkey.parse(s) for s in src if s]


def relief(worry: int) -> int:
    return worry


def simulate(monkeys, rounds=20, relief=lambda x: x // 3):
    for round in range(1, rounds + 1):
        if round % 100 == 0:
            print("Round ", round)
        for monkey in monkeys:
            log.debug(f"Monkey {monkey.id}")
            while monkey.items:
                item = monkey.inspect()
                log.debug(f"  Monkey inspects an item with worry level {item}")
                new_worry = monkey.operation(item)
                new_item = relief(new_worry)
                log.debug(f"    Worry goes up to {new_worry} then down to {new_item}")
                if monkey.test(new_item):
                    log.debug(f"    match; send {new_item} to {monkey.true_recipient}")
                    monkey.send_to(new_item, monkey.true_recipient)
                else:
                    log.debug(
                        f"    no match, send {new_item} to {monkey.false_recipient}"
                    )
                    monkey.send_to(new_item, monkey.false_recipient)
        log.info(f"After round {round}:")
        for monkey in monkeys:
            log.info(f"  {monkey.id}: {monkey.items}")
    return monkeys


def monkey_business(monkeys):
    inspections = sorted((m.inspections for m in monkeys), reverse=True)
    print(inspections)
    return inspections[0] * inspections[1]


if __name__ == "__main__":
    with open("input.txt") as inf:
        monkeys = load_monkeys(inf)
    monkeys = simulate(monkeys, rounds=20)
    print(monkey_business(monkeys))
    with open("input.txt") as inf:
        monkeys = load_monkeys(inf)
    modulus = functools.reduce(operator.mul, (m.divisor for m in monkeys))
    monkeys = simulate(monkeys, rounds=10_000, relief=lambda s: s % modulus)
    print(monkey_business(monkeys))

