extends Node

enum Faction { NEUTRAL, KING, CHRIST, DRUID, SATAN }
enum CellType { WATER, LAND }
enum TerrainType { ID_WATER, ID_DARK_GRASS, ID_MEDIUM_GRASS, ID_LIGHT_GRASS }

enum Scene {
	START_MENU,
	OPTIONS_MENU,
	JOIN_MENU,
	CREATE_MENU,
	LOBBY,
	GAME
}

const SCENE_PATHS: Dictionary = {
	Scene.START_MENU: "uid://5ffbc1r3re0o",
	Scene.GAME: "uid://dc3vyxoakfed1",
}
