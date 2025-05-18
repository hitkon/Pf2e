# RuleEngine.gd
extends Node

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()

# Roll a d20
func roll_d20() -> int:
	return rng.randi_range(1, 20)

# Roll dice like 2d6
func roll_dice(times: int, sides: int) -> int:
	var total = 0
	for i in times:
		total += rng.randi_range(1, sides)
	return total

# Calculate ability modifier from score
func get_modifier(score: int) -> int:
	return int(floor((score - 10) / 2))

# Calculate damage, e.g. "1d8 + mod", with optional damage type
func calculate_damage(base_dice: String, modifier: int = 0, damage_type: String = "physical") -> Dictionary:
	var parts = base_dice.split("d")
	var times = int(parts[0])
	var sides = int(parts[1])
	var damage = roll_dice(times, sides) + modifier
	return {"amount": damage, "type": damage_type}

# Skill check with bonus
func roll_skill_check(skill_bonus: int) -> Dictionary:
	var roll = roll_d20()
	return {
		"roll": roll,
		"total": roll + skill_bonus
	}

# Saving throw with Pathfinder 2e logic
func resolve_saving_throw(dc: int, bonus: int) -> Dictionary:
	var roll = roll_d20()
	var total = roll + bonus
	var degree = "failure"
	if roll == 1:
		degree = "critical_failure"
	elif roll == 20 or total - dc >= 10:
		degree = "critical_success"
	elif total >= dc:
		degree = "success"
	elif dc - total >= 10:
		degree = "critical_failure"
	return {
		"roll": roll,
		"total": total,
		"result": degree
	}

# Attack roll with degrees of success
func resolve_attack(attack_bonus: int, ac: int) -> Dictionary:
	var roll = roll_d20()
	var total = roll + attack_bonus
	var degree = "miss"
	if roll == 1:
		degree = "critical_miss"
	elif roll == 20 or total - ac >= 10:
		degree = "critical_hit"
	elif total >= ac:
		degree = "hit"
	elif ac - total >= 10:
		degree = "critical_miss"
	return {
		"roll": roll,
		"total": total,
		"result": degree
	}

# Apply condition to character node
func apply_condition(character: Node, condition: String, duration: int = 1):
	if not character.has_meta("conditions"):
		character.set_meta("conditions", {})
	var conditions = character.get_meta("conditions")
	conditions[condition] = duration
	character.set_meta("conditions", conditions)
