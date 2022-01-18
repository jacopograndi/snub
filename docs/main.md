# design, documentation and notes

### design:
snub is inspired by [Terrorhedron](https://store.steampowered.com/app/299720/Terrorhedron_Tower_Defense/). <br>
The goal of this project is to expand the Terrorhedron ideas. The main addition are a map editor (even the terrain), a more complex enemy system (topological hierarchy) and more turret upgrades and customization (modules for small bonuses). Mod support and multiplayer are planned.

### [balance](balance.md)

---

### credits:
- voxel-core: https://github.com/ClarkThyLord/Voxel-Core
- hdr skies: https://pixeledasteroid.gumroad.com
- godot dark theme: https://mounirtohami.itch.io/godot-dark-theme

### legend:
**bold** is done (release quality) <br>
_underline_ is done (debug quality) <br>
regular is planned

### roadmap:
- 0.1 alpha:
	- turret system
	- enemy system
	- resources system
	- wave system
	- editor

- 0.2 beta:
	- unit tests & refactoring
	- mod api support

### systems:
- [turret](./turret/turret.md)
	- _models_
	- _stats_
	- **placement**
	- _targeting_
	- _shooting_
	- _economy_
	- _upgrades_
	- modules
	- range indicator
	- selection indicator
	- gui
		- _info details_
		- **shop thumbnail**
		-  on select

- [enemy](./enemy/enemy.md):
	- **models**
	- **path subsystem**
	- **hierarchy**
	- _stats_
	- _color change_
	- **hit effect**
	- gui
		- info detail

- [resources](./resources/resources.md):
	- **Tkads**
	- lives
	- _economy_

- [wave](./wave/wave.md):
	- spawns
	- randomizer
	- balance
	- win/lose condition
	- gui
		- details
		- win/lose
		- endwave report

- [editor](./editor/editor.md):
	- _control_
	- turret
	- _attach_
	- _path_
	- voxel
		- _cubes_
		- palette
	- gui
		- picker
		- help
		- path 
		- loadsave
