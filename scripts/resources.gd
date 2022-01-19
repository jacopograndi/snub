extends Node

var T : float = 500
var k : float = 0
var a : float = 0
var d : float = 0
var s : float = 0

var lives : int = 0

func get_names(): return "Tkads"

func dict_to_str (cost):
	var st = ""
	var i = 0
	for n in cost.keys():
		st += str(cost[n]) + n
		if i <= cost.keys().size()-2: st += " "
		i += 1
	return st
	
func add (cost):
	for n in cost.keys(): self[n] += cost[n]
	
func sub (cost):
	for n in cost.keys(): self[n] -= cost[n]

func greater_than (cost):
	for n in cost.keys():
		if self[n] < cost[n]:
			return false
	return true
