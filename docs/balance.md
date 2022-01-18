# balance

### turret stats
How strong is a turret compared to another? Are there trivial winning strategies? 

### random wave generation:
A wave is generated based on a lives budget, which is a function of the wave number. Tuning that function changes the difficulty of the game.

The current function is `hp_budget = pow((x + 10), 2.7) * 1.8 - 850`
