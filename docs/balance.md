# balance

### turret effectiveness
How strong is a turret compared to another? Are there trivial winning strategies? Are some turrets unuseful? 

Turret types:
- apply damage
- make the path longer
- resource production

I can compare how effective a turret is w.r.t. the others in its type.

1. damage turret
Effectiveness: damage per second

2. path turret
Effectiveness: elongation constant (adimensional)

3. resource turret
Effectiveness: return on investment (adimensional)

### random wave generation:
A wave is generated based on a lives budget, which is a function of the wave number. Tuning that function changes the difficulty of the game.

The current function is `hp_budget = pow((x + 10), 2.7) * 1.8 - 850`

### total damage output (D)
I need an estimate of how much damage a turret configuration is capable of dealing against enemies in a path of lenght L to derive the function of the wave number.

```
D = sum{d:damage turrets}( dps of d ) / enemy_speed 
	* (1 + sum{p:path turrets}( 
			elongation constant of p * (p.range*2 / L) ) 
		* path_constant)

enemy_speed = 1
```

The `path_constant` is how valuable it is to elongate the path in damage per meter.
