class_name HexTileData

var tile_id: int = 0
var terrain: String = "plains"   # "plains" / "forest" / "mountain"
var resources: Dictionary = { "food": 0, "material": 0 }
var productivity: float = 1.0
var occupied_by: int = -1
var has_outpost: bool = false
