extends Node

const ITEM_NAMES: Array = [
	"Vampiric Bullet",
	"Inferno Bullet",
	"Poison Bullet",
	"Shotgun",
	"Blunderboost"
]

const ITEM_DESC: Array = [
	"Heals HP on hit.",
	"Sets enemies on fire that can spread.",
	"Inflicts damaging and weakening poison.",
	[
		"""Traits: penetrating, multi-target, static projectile
		Damage: 1
		Range: low
		Knockback: medium
		Recoil: high
		Accuracy layout:""",
		"Perfect shots: less recoil"
	],
	[
		"""Traits: penetrating, multi-target, reversed direction, bouncing
		Damage: 0.5
		Range: medium
		Knockback: high
		Recoil: INSANE
		Accuracy layout:""",
		"Perfect shots: much greater lifetime"
	]
]

const SHOTGUN_PRICE: int = 250
const BLUNDERBOOST_PRICE: int = 200

const NPC_SHAPE_RADIUS: Array = [10, 15, 12]
const NPC_SHAPE_POS: Array = [Vector2(-5, 3), Vector2(0, 1), Vector2(-10, 1)]

const NPC_BUILDER_POSITIONS: Array = [Vector2(-459.5, -44), Vector2(-592.5, -50), Vector2(-720.5, -48), Vector2(-10000, 0)]
const NPC_BUILDER_WAVE_REQUIREMENTS = [3, 6, 9]

const BUILDING_NAMES: Array = ["shop", "rathouse", "forge"]

const CAMERA_POSITIONS: Dictionary = {
	"arena": Vector2.ZERO,
	"buildings": [Vector2(-452, -75), Vector2(-584, -75), Vector2(-719.5, -75)],
	"mayor": Vector2(-584, 15)
}

const SPECIAL_BULLETS_COLORS: Dictionary = {
	"light": [Color("ff2147"), Color("ff4321"), Color("86b66a")],
	"dark": [Color("e3001d"), Color("e30000"), Color("63806d")]
}

const RIVER_COLOR_LIGHT := Color("4ca1a6")
const RIVER_COLOR_DARK := Color("33727a")

const RAIN_CHANGE_TIME: float = 5

const FIXED_LERP_RELATIVE_FPS: float = 144

const MAX_VISIBLE_SCREEN_SIZE: int = 320
const DEFAULT_RES := Vector2(1152, 648)

const ORIG_PLAYER_Z_IDX: int = 0
