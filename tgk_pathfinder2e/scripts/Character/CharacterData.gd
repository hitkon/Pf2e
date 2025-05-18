extends Node
class_name CharacterData

@export var characterName: String
@export var ancestry: Resource
@export var characterClass: Resource
@export var level: int = 1
@export var speed: int = 5
@export var maxHP: int = 10
@export var currentHP: int = 10
@export var tempHP: int = 0
@export var armorClass: int = 10
@export var perception: int = 0
@export var reach:int = 1

@export var is_player_character: bool

@export var skills: Dictionary = {
	"Acrobatics": 0, "Arcana": 0, "Athletics": 0,
	"Crafting": 0, "Deception": 0, "Diplomaacy": 0,
	"Intimidation": 0, "Medicine": 0, "Nature": 0,
	"Occultism": 0, "Performance": 0, "Religion": 0,
	"Society": 0, "Stealth": 0, "Survival": 0, "Thievery": 0
}
@export var loreSkills: Dictionary = {}
@export var languages: Dictionary = {}

@export var abilities: Dictionary = {}


@export var attributes: Dictionary = {
	"STR": 10, "DEX": 10, "CON": 10, 
	"INT": 10, "WIS": 10, "CHA": 10
}
@export var items: Array

@export var feats: Dictionary = {
	"Power Attack": {
		"type": "action",
		"cost": 2,
		"effect": "double weapon damage"
	},
	"Toughness": {
		"type": "passive",
		"effect": "increase HP by 5"
	}
}

#@export var items
