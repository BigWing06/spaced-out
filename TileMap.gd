extends TileMap
export(Vector2) var mapSize  = Vector2(3, 2)	
export(int) var mapSeed = 345
export(Vector2) var chunkSize = Vector2(10, 10)
export(int) var octaves = 3
export(int) var period = 3
export(float) var persistence = 4
export(float) var lacunarity = .4
export(float) var noiseThreshold = .3
export(int) var groundLevelOffset = 0
var mainTileReference = {"land":tile_set.find_tile_by_name("planet0Land")}
var resourceTileReference = {"stone":tile_set.find_tile_by_name("stone")}
var noise = OpenSimplexNoise.new()
var world = {}
var loadedChunks = [] #list to keep track of chunks that are loaded

var resourceNoise = OpenSimplexNoise.new()

var masterWorldDict = {}

func save():
	var resourceTileMap = get_parent().get_node("resourceTileMap")
	masterWorldDict[int(global.currentPlanet)] = {}
	var cellDict = masterWorldDict[int(global.currentPlanet)]
	for cell in resourceTileMap.get_used_cells():
		cellDict[cell] = resourceTileMap.tile_set.tile_get_name(resourceTileMap.get_cellv(cell))

func reset():
	var resourceTileMap = get_parent().get_node("resourceTileMap")
	resourceTileMap.clear()
	clear()
	var backgroundTileMap = get_parent().get_node("backgroundTileMap")
	backgroundTileMap.clear()
	loadedChunks = []
		

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
func onPlayerChunkChange(playerChunk):
	for chunk in getSurroundingChunks(playerChunk):
		if not chunk in loadedChunks:
			loadedChunks.append(chunk)
			generateWorld(chunk)
		
# Called when the node enters the scene tree for the first time.
func _ready():
	noise.octaves = octaves
	noise.period = period
	noise.persistence = persistence
	noise.lacunarity = lacunarity
	resourceNoise.period = period
	resourceNoise.persistence = 500
	resourceNoise.lacunarity = 500
	setup()
	
func setup():
	noise.seed = mapSeed
	resourceNoise.seed = mapSeed
	mainTileReference = {"land":tile_set.find_tile_by_name("planet" + global.currentPlanet + "Land")}
	var startingChunks = getSurroundingChunks(Vector2(0, 0)) 
	startingChunks.append(Vector2(0, 0))
	for chunk in startingChunks:
		generateWorld(chunk)
	
func getSurroundingChunks(pos):
	var coords = []
	var angles = [0, PI/4, PI/2, 3*PI/4, PI, 5*PI/4, 3*PI/2, 7*PI/4]
	for i in range(1, 3):
		for angle in angles:
			coords.append(Vector2(pos.x+round(cos(angle))*i, pos.y+round(sin(angle))*i))
	return coords
	
func determineGroundLevel(x):
	return groundLevelOffset + round(sin(round(x*.1)*1.25))
	
func createLandTile(x, y):
	set_cell(x, y, mainTileReference["land"], false, false, false, get_cell_autotile_coord(x, y))
	var resourceTileMap = get_parent().get_node("resourceTileMap")
	if (resourceNoise.get_noise_2d(x, y) > .3):
		global.planetInfo[int(global.currentPlanet)]['generationKey'].shuffle()
		resourceTileMap.set_cell(x, y, resourceTileMap.tile_set.find_tile_by_name(global.planetInfo[int(global.currentPlanet)]['generationKey'][0]), false, false, false, resourceTileMap.get_cell_autotile_coord(x, y))
	if (resourceTileMap.get_cell(x, y) == -1):
		resourceTileMap.set_cell(x, y, resourceTileMap.tile_set.find_tile_by_name("stone"), false, false, false, resourceTileMap.get_cell_autotile_coord(x, y))
	update_bitmask_area(Vector2(x, y))
	resourceTileMap.update_bitmask_area(Vector2(x, y))
func generateWorld(pos): 
	loadedChunks.append(pos)
	var chunkOffset = pos*chunkSize
	for x in range(chunkOffset.x, chunkOffset.x + chunkSize.x):
		for y in range(chunkOffset.y, chunkOffset.y + chunkSize.y):
			if y >= determineGroundLevel(x): #Checks to make sure that it is under grounnd level
				get_parent().get_node("backgroundTileMap").set_cell(x, y, get_parent().get_node("backgroundTileMap").tile_set.find_tile_by_name("land" + global.currentPlanet + "Dark"), false, false, false, get_parent().get_node("backgroundTileMap").get_cell_autotile_coord(x, y))
				if (y > 10):
					if (noise.get_noise_2d(x, y) < abs(noiseThreshold)/1.5):
						createLandTile(x, y)
				else:
					if (noise.get_noise_2d(x, y) < abs(noiseThreshold)):
						createLandTile(x,y)
					
				#else:
				#	set_cell(x, y, 9, false, false, false, get_cell_autotile_coord(x, y))
	get_parent().get_node("resourceTileMap").update_dirty_quadrants()
	update_dirty_quadrants()
	get_parent().get_node("resourceTileMap").update_bitmask_region()
	get_parent().get_node("backgroundTileMap").update_bitmask_region()
	
func mineCell(pos):
	set_cell(pos.x, pos.y, -1)
	var resourceTileMap = get_parent().get_node("resourceTileMap")
	resourceTileMap.set_cell(pos.x, pos.y, -1)
	get_parent().get_node("resourceTileMap").update_bitmask_region()
	
func setCell(pos, resource):
	set_cell(pos.x, pos.y, mainTileReference["land"])
	var resourceTileMap = get_parent().get_node("resourceTileMap")
	resourceTileMap.set_cell(pos.x, pos.y, 12)
	get_parent().get_node("resourceTileMap").update_bitmask_region()
	


