## wave system
Timing and composition of enemy waves.

### design
A wave is a list of timed spawns. The spawns contain a list of enemies, which defines how many enemies of one type to spawn and how much time to wait after spawning the next. Spawns can be randomized, which will make the system pick from the list of enemies a random one instead of sequentially selecting them.

For example:
```
[ 
{
	"time": 0, 
	"random": false,
	"enemies": [
		{ "enemy": "aaT", "amount": 10, "cooldown": 0.1 },
		{ "enemy": "kT", "amount": 20, "cooldown": 0.02 }
	]
},
{
	"time": 1, 
	"random": true,
	"enemies": [
		{ "enemy": "dssT", "amount": 4, "cooldown": 0.05 },
		{ "enemy": "dsaT", "amount": 4, "cooldown": 0.05 },
		{ "enemy": "aaaT", "amount": 4, "cooldown": 0.05 }
	]
}
]
```

This wave can be generated randomly given a total life, which is necessary to do unless people don't want to script the waves of every map they create or use old waves.

---

### spawns
- timers
- cooldowns

### randomizer
- generate from difficulty
- patterns

### balance
- figure out how the difficulty

### win/lose condition
- win
- lose

### gui
- details
- win/lose
- endwave report 
