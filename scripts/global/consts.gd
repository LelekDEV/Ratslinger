extends Node

const ITEM_NAMES: Array = [
	"Vampiric Bullet",
	"Inferno Bullet",
	"Poison Bullet"
]

const ITEM_DESC: Array = [
	"Heals HP on hit.",
	"Sets enemies on fire that can spread.",
	"Inflicts damaging and weakening poison"
]

const NPC_SHAPE_RADIUS: Array = [10, 15]
const NPC_SHAPE_POS: Array = [Vector2(-5, 3), Vector2(0, 1)]

const SPECIAL_BULLETS_COLORS: Dictionary = {
	"light": [Color("ff2147"), Color("ff4321"), Color("86b66a")],
	"dark": [Color("e3001d"), Color("e30000"), Color("63806d")]
}

const RIVER_COLOR_LIGHT := Color("4ca1a6")
const RIVER_COLOR_DARK := Color("33727a")

const RAIN_CHANGE_TIME: float = 5

const FIXED_LERP_RELATIVE_FPS: float = 144
