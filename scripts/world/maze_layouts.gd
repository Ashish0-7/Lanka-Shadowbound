class_name MazeLayouts
extends RefCounted

## Hand-authored maze grids, one per chapter. 20 columns × 11 rows of 32 px cells
## (LevelMaze.CELL), drawn from y = LevelMaze.ORIGIN_Y. Edit freely — tools/check_mazes.gd
## verifies every maze is solvable and keeps boss areas clear.
##
##   X  scenery (blocks movement, not drawn — the sky/skyline band and space under the HUD)
##   #  wall (drawn in the chapter's theme)
##   c  crevice — only passable while Hanuman is shrunk [SHIFT]
##   .  open floor
##   S  Hanuman's start
##   E  exit (reaching it completes the chapter, where the chapter has one)
##   G  guard post (Chapter 3)
##   T  Sita beneath the Ashoka tree (Chapter 4)
##   M  Queen Mandodari, asleep in the palace (Chapter 3)
##
## Difficulty rises 1 → 4. Chapter 5 is a different kind of level and has no maze.

const LAYOUTS := {
	# Crossing the Ocean — gentle reef maze. Surasa's jaws (cols 9–13) span every row,
	# so she cannot be walked around. A crevice offers a shrink-only shortcut.
	1: [
		"XXXXXXXXXXXXXXXXXXXX",
		"XXXXXXXXXXXXXXXXXXXX",
		"XXXXXXXXXXXXXXXXXXXX",
		"XXXXXX..#...........",
		"......#.#.........#.",
		"S.....#.#.........#E",
		"......c...........#E",
		"..#...####...#......",
		"..#.........##...#..",
		"..####..#.......##..",
		"........#...........",
	],
	# The Gates of Lanka — stone courtyards lead to Lankini's open arena (cols 13–19).
	2: [
		"XXXXXXXXXXXXXXXXXXXX",
		"XXXXXXXXXXXXXXXXXXXX",
		"XXXXXXXXXXXXXXXXXXXX",
		"XXXXXX#######.......",
		"S..#...#............",
		"##.#.###.#.##.......",
		"...#.....#..........",
		".#.#.#######........",
		".....#..............",
		".#####.#####........",
		".......#............",
	],
	# Lanka at Night — palace corridors with loops. Walls block the guard's line of sight.
	3: [
		"XXXXXXXXXXXXXXXXXXXX",
		"XXXXXXXXXXXXXXXXXXXX",
		"XXXXXXXXXXXXXXXXXXXX",
		"XXXXXX##############",
		"S#......M..#.......#",
		".#.#.#.###.#.#####.#",
		".#.#...#.#.#.#.G.#.E",
		".#####.#.#.#.#.#.###",
		"...#...#...#...#...#",
		".#.#.###.#.#######.#",
		".....#.............#",
	],
	# Ashoka Vatika — the hardest maze: long winding hedges and dead ends, ending at Sita.
	# Crevices (c) are shrink-only shortcuts.
	4: [
		"XXXXXXXXXXXXXXXXXXXX",
		"XXXXXXXXXXXXXXXXXXXX",
		"XXXXXXXXXXXXXXXXXXXX",
		"XXXXXX##############",
		"S..c.......#.....#T#",
		"##.#.#####.#.###.#.#",
		".#.#.#.....#...#...#",
		".#.#.#.#####.#.#c###",
		"...#.#.#...#.#.....#",
		".###.#.#.#.#######.#",
		".....#...#.........#",
	],
	# The Escape — no maze: open burning rooftops, a dash to the sea (right edge).
	5: [
		"XXXXXXXXXXXXXXXXXXXX",
		"XXXXXXXXXXXXXXXXXXXX",
		"XXXXXXXXXXXXXXXXXXXX",
		"XXXXXX.............E",
		"...................E",
		"S..................E",
		"...................E",
		"...................E",
		"...................E",
		"...................E",
		"...................E",
	],
}

## Areas that must stay walkable (boss sprites / arenas), as Rect2i of cells: chapter → rects.
const KEEP_CLEAR := {
	1: [Rect2i(9, 4, 4, 3), Rect2i(14, 4, 3, 3)],
	2: [Rect2i(14, 3, 6, 7)],
	3: [],
	4: [],
	5: [],
}
