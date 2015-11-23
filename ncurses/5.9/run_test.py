import sys

if __name__ == '__main__':
    try:
        import curses
    except ImportError:
        # Currently fails on conda on ppc64le
        sys.stderr.write("Python 'curses' module not found. Skipping test.\n")
        sys.exit(0)

    screen = curses.initscr()
    try:
        curses.cbreak()
        pad = curses.newpad(10, 10)
        size = screen.getmaxyx()
        pad.refresh(0, 0, 0, 0, size[0] - 1, size[1] - 1)

    finally:
        curses.nocbreak()
        curses.endwin()
