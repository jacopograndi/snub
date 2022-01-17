## enemy system

### design
The enemies are spawned by the wave system, their 3d model is a mathematical shape. These shapes are the 5 [Platonic solids](https://en.wikipedia.org/wiki/Platonic_solid), the 13 [Archimedean solids](https://en.wikipedia.org/wiki/Archimedean_solid) and their dual the 13 [Catalan solids](https://en.wikipedia.org/wiki/Catalan_solid), which amount to 31 shapes. <br>

The enemies are arranged in a tree based on their topology using [Conway polyhedron notation](https://en.wikipedia.org/wiki/Conway_polyhedron_notation). Four operators are used: kis, ambo, dual, snub (k, a, d, s). From these operators all the shapes in the game can be obtained if the staring shape is a Tetrahedron (T). For example, an Octahedron (O) is an ambo Tetrahedron (aT): ) = aT. saT is the snub cube, from which the game is named. Each node of the tree is a shape and each edge represent an operation. The root is T and each operation is appended to the left of T, so the snub cube saT is connected to the Octahedron aT and aT is connected to T. <br>

The other operators can be obtained by the four operator used:
- truncation: t = dkd
- expansion: e = aa
- bevel: b = dkda = td
- join: j = da
- meta: m = kda
- ortho: o = daa
- gyro: g = dsd

**topology graph**
- T = [Tetrahedron](https://en.wikipedia.org/wiki/Tetrahedron)
	- k, kT = [Triakis Tetrahedron](https://en.wikipedia.org/wiki/Triakis_tetrahedron)
		- d, dkdT = dkT = [Truncated Tetrahedron](https://en.wikipedia.org/wiki/Truncated_tetrahedron)
	- a, aT = O = [Octahedron](https://en.wikipedia.org/wiki/Octahedron)
		- k, kaT = [Triakis Octahedron](https://en.wikipedia.org/wiki/Triakis_octahedron)
			- d, dkaT = tC = [Truncated Cube](https://en.wikipedia.org/wiki/Truncated_cube)
		- a, aaT = [Cuboctahedron](https://en.wikipedia.org/wiki/Cuboctahedron)
			- d, daaT = jC = [Rhombic Dodecahedron](https://en.wikipedia.org/wiki/Rhombic_dodecahedron)
				- k, kdaaT = mC = [Disdyakis Dodecahedron](https://en.wikipedia.org/wiki/Disdyakis_dodecahedron)
					- d, dkdaaT = bC = taaT = [Truncated Cuboctahedron](https://en.wikipedia.org/wiki/Truncated_cuboctahedron)
			- a, aaaT = eC = [Rhombicuboctahedron](https://en.wikipedia.org/wiki/Rhombicuboctahedron)
				- d, daaaT = oC = [Deltoidal Icositetrahedron](https://en.wikipedia.org/wiki/Deltoidal_icositetrahedron)
		- d, daT = C = [Cube](https://en.wikipedia.org/wiki/Cube)
			- k, kdaT = [Tetrakis Hexahedron](https://en.wikipedia.org/wiki/Tetrakis_hexahedron)
				- d, dkdaT = tO = [Truncated Octahedron](https://en.wikipedia.org/wiki/Truncated_octahedron)
		- s, saT = [Snub Cube](https://en.wikipedia.org/wiki/Snub_cube)
			- d, dsaT = g = [Pentagonal Icositetrahedron](https://en.wikipedia.org/wiki/Pentagonal_icositetrahedron)
	- s, sT = [Icosahedron](https://en.wikipedia.org/wiki/Icosahedron)
		- k, ksT = [Triakis icosahedron](https://en.wikipedia.org/wiki/Triakis_icosahedron)
			- d, dksT = [Truncated Dodecahedron](https://en.wikipedia.org/wiki/Truncated_dodecahedron)
		- a, asT = [Icosidodecahedron](https://en.wikipedia.org/wiki/Icosidodecahedron)
			- d, dasT = jD = [Rhombic Triacontahedron](https://en.wikipedia.org/wiki/Rhombic_triacontahedron)
				- k, kdaaT = mD = [Disdyakis Triacontahedron](https://en.wikipedia.org/wiki/Disdyakis_triacontahedron)
					- d, dkdaaT = bD = [Truncated Icosidodecahedron](https://en.wikipedia.org/wiki/Truncated_icosidodecahedron)
			- a, aasT = eD = [Rhombicosidodecahedron](https://en.wikipedia.org/wiki/Rhombicosidodecahedron)
				- d, daasT = oD = [Deltoidal Hexecontahedron](https://en.wikipedia.org/wiki/Deltoidal_hexecontahedron)
		- d, dsT = D [Dodecahedron](https://en.wikipedia.org/wiki/Dodecahedron)
			- k, kdsT = [Pentakis Dodecahedron](https://en.wikipedia.org/wiki/Pentakis_dodecahedron)
				- d, dkdsT = tI = [Truncated Icosahedron](https://en.wikipedia.org/wiki/Truncated_icosahedron)
		- s, ssT = [Snub Dodecahedron](https://en.wikipedia.org/wiki/Snub_dodecahedron)
			- d, dssT = gD = [Pentagonal Hexecontahedron](https://en.wikipedia.org/wiki/Pentagonal_hexecontahedron)

**effects**

Enemies start with 10 lives. When lives reaches zero and the shape is T, the shape dies. Otherwise, an operator is lost and lives are set back to 10.

The enemies gain effects based on their topology:
- T: no effect
- k: speed, 20%
- a: damage, 2x
- d: duplicates on death (only when losing the d)
- s: armored (multiplies life by 3), speed -20%

Effect stack multiplicativly, so aaaT does `2*2*2=8x` more damage, ssT is very slow and very armored.

```
Example for ssT: 
1. after 90 damage, s is removed
5. after 30 damage, s is removed
6. after 10 damage, T dies.
```

```
Example for dkdasT:
1. after 30 damage, d is removed and 4 kdasT are spawned
2. after 30 damage, k is removed
3. after 30 damage, d is removed and 2 asT are spawned
4. after 30 damage, a is removed
5. after 30 damage, s is removed
6. after 10 damage, T dies.
```

```
Values of life(shape)
life(daaT) = 10 * 2*(10 * 3) = 70
life(ssT) = 90 + 30 + 10 = 130
life(dssT) = 90 + 2*(90 + 30 + 10) = 350
life(dkdasT) = 30 + 4*(30 + 30 + 2*(30 + 30 + 10)) = 830
```

---

### models
- **all 31 shapes**

### path subsystem
- **hide/show**
- **instantiate**
- **follow**
- **destroy on end**

### hierarchy
- **design topological hierarchy**

### stats
- _name_
- effects
- type/description

### color change
- _change based on resource color_

### hit effect
- **dissolve**

### gui
- info detail
