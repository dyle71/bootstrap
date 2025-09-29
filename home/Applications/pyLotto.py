#!/usr/bin/env python3

import argparse
import random
import sys


def pick(choose: int, total: int) -> (list, int):
    """Pick randomly a list of numbers from a total amount of numbers.

    :param choose:  the amount of numbers to pick.
    :param total:   the total amount of numbers.
    :return:        the list of randomly picked numbers, error number
    """

    if choose < 1:
        sys.stderr.write('Must have at least 1 number to pick.\n')
        return [], 1

    if choose > total:
        sys.stderr.write('Picking more numbers than available. Cutting...\n')
        choose = total

    n = list(range(1, total + 1))
    random.shuffle(n)

    return n[0:choose], 0


def main() -> int:

    """Startup: grep the X and Y values and call the pick function."""

    parser = argparse.ArgumentParser(description='pyLotto')
    parser.add_argument('pick', metavar='PICK', type=int, nargs=1, help='Amount of numbers to pick.')
    parser.add_argument('total', metavar='TOTAL', type=int, nargs=1, help='Total amount of numbers.')

    args = parser.parse_args()
    (n, err) = pick(choose=args.pick[0], total=args.total[0])

    if err != 0:
        sys.exit(err)

    n.sort()
    print(n)
    return 0


if __name__ == '__main__':
    main()

