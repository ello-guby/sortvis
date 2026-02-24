sortvis
=======
A sorting visualizer made in Godot Engine. In competition against
[Space's sort-visualizer](https://github.com/SpaceTurtle-git/sort-visualizer).

Installation Prerequisite
-------------------------
- [Godot Engine](https://godotengine.org/)
- [git](https://git-scm.com/): Optional for downloading.

Installation
------------
1. Copy project.
2. Import project into Godot Engine.

Usage
-----
From Godot Engine's Project List, run the imported project.

You can create your own sorter by extending the [Sorter](src/sorters/sorter.gd) class,
`class_name` it, and implement `_sort_step` method.
It will be added into the option box.
