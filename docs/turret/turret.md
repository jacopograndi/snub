## turret system

### design
- upgrade graph
```
laser -> (heavy laser -> minigun) or (sniper -> railgun) <br>
shotgun -> cannon -> tesla <br>
plastic -> heavy plastic -> plasma plastic <br>
slower -> (heavy slower -> final slower) or (stopper -> heavy stopper) <br>
T generator -> kad generator -> s generator <br>
```

- [modules](modules.md)

---

### models
- _laser_
- heavy laser
- minigun
- _sniper_
- railgun
- _shotgun_
- cannon
- tesla
- _plastic_
- heavy plastic
- plasma plastic
- _slower_
- heavy slower
- final slower
- stopper
- heavy stopper
- _struct I_
- _struct T_
- _struct X_
- _T generator_
- kad generator
- s generator
- attach point

### stats
- _laser_
- heavy laser
- minigun
- _sniper_
- railgun
- _shotgun_
- cannon
- tesla
- _plastic_
- heavy plastic
- plasma plastic
- _slower_
- heavy slower
- final slower
- stopper
- heavy stopper
- _struct I_
- _struct T_
- _struct X_
- _T generator_
- kad generator
- s generator
- attach point

### placement
- **only place when not ovelapping**
- **ghost cursor**
- **buy spending resources**
- shader to ghost cursor

### targeting
- **check visible**
- **check range**
- target selection
	- **first**
	- last
	- strongest
	- weakest
	- closest
	- further away
	- least turning
	- densest
- precalculate valid path nodes

### shooting
- **spread**
- _projectiles per shot_
- projectile logic
	- **bullet**
	- _ray_
	- **plastic**
- projectile stats
- projectile models
	- bullet
	- ray
	- plastic
	- bullet bounce
	- plastic bounce
- projectile fx
	- trails
	- explosions
	- shooting particles

### economy
- **resources on enemy hit**
- generators make resources at end of wave

### upgrades
- _turrets can be upgraded_
- _only if can afford T_

### modules
- stats
- logic
- gui
	- buy menu
	- details

### range indicator
- model

### selection indicator
- model
- fx

### gui
- stats details
	- _panel with stats_
	- upgrade bonus preview
	- module bonus preview
	- resize based on stats
- **shop thumbnail**
- on select
	- picker options
		- sell
		- upgrade (multiple)
		- target
		- buy module
		- manual control
