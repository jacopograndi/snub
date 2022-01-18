# balance

### lives density
A turret is effective against a group of enemies.
A turret that is dealing 1 damage per second (dps) and can shoot at 20 cells kills an enemy with 20 lives, if the enemy has a speed of 1 cell per second. 
An enemy with 21 lives is not killed. However, infinite enemies with 1 life and 1 cell apart cannot get through the turret.
Therefore the turret effectiveness can be gauged against a **density of lives**: how many lives per cell can the turret take away.

A 1 dps turret can cope with a density of 1 life per cell. <br>
A 2 dps turret can cope with 2 lives per cell.

A turret that applies the slowness effect (50% speed) to an enemy for 10 seconds decreases the density, thus increasing the othe turrets dps.

There can be two cases:
- constant density for the whole path, the turrets damage only the enemies in their range so their effectiveness is lessened by range/path\_lenght.
- the density is uneven, turret effectiveness is greater.

### height
An enemy with 100 lives and 100 enemies with 1 life (within the same cell) both have a density of 100 lives per cell.
To capture this aspect, the height of a cell is defined as the maximum number of lives in that cell.
- high cell: few enemies with a lot of life
- low cell: a lot of enemies with low life

---

### turret balance
Turret types:
- apply damage
- make the path longer
- resource production

target type:
- single target
	- great with high cells
- aoe
	- great with low cells

What are the differences between turrets in the same group?

Special abilities (yikes, but it's an idea)

Tradeoffs:
- short term gain / long term gain
	- good stats / good upgrades or modules
	- low cost, bad stats / high cost, good stats
- specialized / generalist
- reliability (misses)
- synergies with other turrets

### random wave generation:
A wave is generated based on a lives budget, which is a function of the wave number. Tuning that function changes the difficulty of the game.

The current function is `hp_budget = pow((x + 10), 2.7) * 1.8 - 850`

The lives budget also control how many resources are given to the players.

The density is crucial:
- high density, more difficult
- low density, easier

Height is also important:
- Generating lots of enemies with low life is beneficial towards aoe
- High enemies good for single target
