extends Resource
class_name WeaponResource
@export var weapon_name: String = ""
@export var damage: String = ""   # e.g., "1d8"
@export var weapon_type: String = ""  # e.g., "sword"
@export var traits: Array[WeaponTraits] = []
@export var hands_required: int = 1
@export var actions_required: int = 1
@export var description: String = ""
@export var proficiency: String = "Simple"
@export var range: int = 1
@export var type: WeaponType
@export var reloadable: bool = false

var loaded: bool = true

enum WeaponTraits{
	Agile,
	Backstabber,
	Finesse
}
enum WeaponType{
	MELEE,
	RANGE
}
