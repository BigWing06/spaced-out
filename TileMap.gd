extends TileMap
export(Vector2) var mapSize  = Vector2(100, 100)	
export(String) var mapSeed = "Blah Blah Blah"
export(Vector2) var chunkSize = Vector2(100, 100)
export(int) var octaves = 3
export(int) var period = 3
export(float) var persistence = .3
export(float) var lacunarity = .4
export(float) var noiseThreshold = .5
export(int) var groundLevelOffset = 0
var noise = OpenSimplexNoise.new()
var world = {}

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	noise.seed = mapSeed.hash()
	noise.octaves = octaves
	noise.period = period
	noise.persistence = persistence
	noise.lacunarity = lacunarity
	generateWorld(Vector2(0, 0))
	
func determineGroundLevel(x):
	return groundLevelOffset + round(sin(round(x*.1)*1.25))
	
func generateWorld(pos):
	for x in range(-chunkSize.x/2, chunkSize.x/2):
		for y in range(-chunkSize.y/2, chunkSize.y/2):
			if (noise.get_noise_2d(x, y) < noiseThreshold) and y >= determineGroundLevel(x):
				set_cell(x, y, 25, false, false, false, get_cell_autotile_coord(x, y))
				update_bitmask_area(Vector2(x, y))
	update_dirty_quadrants()
	
func mineCell(pos):
	set_cell(pos.x, pos.y, -1)
	
func setCell(pos, resource):
	set_cell(pos.x, pos.y, 25)
	print("test")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
