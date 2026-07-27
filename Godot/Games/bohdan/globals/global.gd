extends Node

var autotiler: DualGridAutotiler
var map_generator: MapGenerator
var camera: Camera2D

var current_turn_faction: Util.Faction = Util.Faction.KING

var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.seed = 67
