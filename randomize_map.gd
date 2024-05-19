extends TileMap 

# 圖塊ID
const SNOW_TILE_ID = 5
const DESERT_TILE_ID = 13
const FOREST_TILE_ID = 3
const PLAIN_TILE_ID = 4
const MOUNTAIN_TILE_ID = 7
const RIVER_TILE_ID = 12
const HILLS_TILE_ID = 6

# 地形條件
var REIER_MAX_HEIGHT =-0.25
var PLAIN_MAX_HEIGHT = 0.1
var HILLS_MAX_HEIGHT = 0.2
var SNOW_MAX_TEMP = 0.15
var DESERT_MAX_TEMP = 0.85
var FOREST_MAX_TEMP = 0.5

var noise = FastNoiseLite.new()
# 地圖尺寸
var map_size = Vector2(30, 30)

# 使用 Godot 生命周期中的 _ready() 函数，场景树准备完成时调用此函数
func _ready():
	generate_map()

func generate_map():
	noise.noise_type = FastNoiseLite.TYPE_PERLIN  # 设置噪声类型为柏林噪声
	noise.frequency = 0.3  # 设置噪声的频率

	for x in range(map_size.y):
		# 氣溫變數
		var T_rand = randf_range(-4,4)

		for y in range(map_size.x):
			var height =( noise.get_noise_2d(x, y))
			var temperature = (y-T_rand)/ float(map_size.y) 
			# 高度判斷地形
			# maybe 全地形
			var terrain_tile_id
			if height < REIER_MAX_HEIGHT:
				terrain_tile_id = RIVER_TILE_ID
			elif height < PLAIN_MAX_HEIGHT:
				terrain_tile_id = PLAIN_TILE_ID
			elif height < HILLS_MAX_HEIGHT:
				terrain_tile_id = HILLS_TILE_ID
			else:
				terrain_tile_id = MOUNTAIN_TILE_ID

			# 溫度判斷
			# maybe圖層2裝飾環境
			var biome_tile_id
			if temperature < SNOW_MAX_TEMP :
				biome_tile_id = SNOW_TILE_ID
			elif temperature > DESERT_MAX_TEMP and terrain_tile_id != RIVER_TILE_ID:
				biome_tile_id = DESERT_TILE_ID
			elif temperature > FOREST_MAX_TEMP and terrain_tile_id == PLAIN_TILE_ID:
				biome_tile_id = FOREST_TILE_ID
			else:
				biome_tile_id = terrain_tile_id
			set_cell(0,Vector2i (-0.5*map_size.x+x, -0.5*map_size.y+y), biome_tile_id,Vector2i(0,0))

    # 更新TileMap中图块的连接和过渡效果（如果使用了连接性(tile connectivity)特性）
    # update_bitmask_area(Vector2(0, 0), map_size) not for 4.22
	
