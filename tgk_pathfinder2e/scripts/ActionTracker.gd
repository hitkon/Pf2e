# ActionTracker.gd
extends Node
class_name ActionTracker

var max_actions := 3
var actions_left := 3
var has_reaction := true

func reset_turn():
	actions_left = max_actions
	has_reaction = true

func use_action(amount := 1) -> bool:
	if actions_left >= amount:
		actions_left -= amount
		return true
	print("Not enough actions")
	return false

func can_act() -> bool:
	return actions_left > 0
