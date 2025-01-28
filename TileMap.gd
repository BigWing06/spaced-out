extends TileMap
onready var globals = get_node("/root/global")
var map = OpenSimplexNoise.new()
var tileMapList = "globals.worldInfo[globals.currentPlanet]['world']['tileMapList']"
var renderedCells = []
var preRender = null
var unableToUpdate = [] #Keeps track of squares whose neihboring tiles are out of bounds.

func _ready():
	get_parent().get_node('spaceShip').position = Vector2(12, (7-round(cos((PI/24)*0)*(int(map.get_noise_2d(int(int(0)/24), 8)*10000)%3))))/get_parent().get_node("TileMap").scale*get_parent().get_node("TileMap").cell_size
	map.period = 64
	map.lacunarity = 2.0
	map.octaves = 8
	map.persistence = 0.5
	renderedCells = []
	preRender = null
	
func squareUpdate(pos):
	var keys = globals.worldInfo[globals.currentPlanet]['world']['tileMapList'].keys()
	var rock45 = globals.worldInfo[globals.currentPlanet]['world']['tileMapKey']['rock45']
	var resourceTilemap = get_node('/root/worldMain/resourceTileMap')
	var tileMap45Resource = null
	if globals.worldInfo[globals.currentPlanet]['world']['tileMapList'][pos][1] > 1:
		tileMap45Resource = globals.resourceInfo[int(globals.worldInfo[globals.currentPlanet]['world']['tileMapList'][pos][1])]['tilemap'][1]
	#if Vector2(pos.x, pos.y-1) in keys and Vector2(pos.x+1, pos.y) in keys and Vector2(pos.x, pos.y-1) in keys and Vector2(pos.x-1, pos.y) in keys and Vector2(pos.x, pos.y+1) in keys and Vector2(pos.x+1, pos.y) in keys and Vector2(pos.x, pos.y+1) in keys and Vector2(pos.x-1, pos.y) in keys:
	if globals.worldInfo[globals.currentPlanet]['world']['tileMapList'][Vector2(pos.x, pos.y-1)][0] == 0 and globals.worldInfo[globals.currentPlanet]['world']['tileMapList'][Vector2(pos.x+1, pos.y)][0] == 0 and globals.worldInfo[globals.currentPlanet]['world']['tileMapList'][Vector2(pos.x, pos.y)][0] == 3:
		set_cellv(pos, rock45)
		if tileMap45Resource != null:
			resourceTilemap.set_cellv(pos, tileMap45Resource)
	elif globals.worldInfo[globals.currentPlanet]['world']['tileMapList'][Vector2(pos.x, pos.y-1)][0] == 0 and globals.worldInfo[globals.currentPlanet]['world']['tileMapList'][Vector2(pos.x-1, pos.y)][0] == 0 and globals.worldInfo[globals.currentPlanet]['world']['tileMapList'][Vector2(pos.x, pos.y)][0] == 3:
		set_cellv(pos, rock45, true, false)
		if tileMap45Resource != null:
			resourceTilemap.set_cellv(pos, tileMap45Resource, true, false)
	elif globals.worldInfo[globals.currentPlanet]['world']['tileMapList'][Vector2(pos.x, pos.y+1)][0] == 0 and globals.worldInfo[globals.currentPlanet]['world']['tileMapList'][Vector2(pos.x+1, pos.y)][0] == 0 and globals.worldInfo[globals.currentPlanet]['world']['tileMapList'][Vector2(pos.x, pos.y)][0] == 3:
		set_cellv(pos, rock45, false, true)
		if tileMap45Resource != null:
			resourceTilemap.set_cellv(pos, tileMap45Resource, false, true)
	elif globals.worldInfo[globals.currentPlanet]['world']['tileMapList'][Vector2(pos.x, pos.y+1)][0] == 0 and globals.worldInfo[globals.currentPlanet]['world']['tileMapList'][Vector2(pos.x-1, pos.y)][0] == 0 and globals.worldInfo[globals.currentPlanet]['world']['tileMapList'][Vector2(pos.x, pos.y)][0] == 3:
		set_cellv(pos, rock45, true, true)
		if tileMap45Resource != null:
			resourceTilemap.set_cellv(pos, tileMap45Resource, true, true)
	elif globals.worldInfo[globals.currentPlanet]['world']['tileMapList'][pos][0] == 3:
		set_cellv(pos, globals.worldInfo[globals.currentPlanet]['world']['tileMapKey']['rock'])
		
func generateOre(pos, ore, rawValue):
	var generationType = int((rawValue*10000))%len(globals.oreGenerationMap)-1 #Gets the pattern for the cluster of ore
	for j in range(len(globals.oreGenerationMap[generationType])):
		var tempCoord = pos + globals.oreGenerationMap[generationType][j]
		if tempCoord in globals.worldInfo[globals.currentPlanet]['world']['tileMapList'].keys():
			var squareValue = globals.worldInfo[globals.currentPlanet]['world']['tileMapList'][tempCoord]
			if squareValue == [3, 1]:
				globals.worldInfo[globals.currentPlanet]['world']['tileMapList'][tempCoord][1] = ore[1]
		else:
			globals.worldInfo[globals.currentPlanet]['world']['tileMapList'][tempCoord] = ore
	if not Vector2(0, 0) in globals.oreGenerationMap[generationType]:
		globals.worldInfo[globals.currentPlanet]['world']['tileMapList'][pos] = [3, 1]

func render(pos):
	var newRenders = []
	var resourceTilemap = get_parent().get_node("resourceTileMap")
	var coords = [] #Positions to be rendered get added to this list
	var distance = Vector2((globals.renderDistance.x+2)*2+1, (globals.renderDistance.y+2)*2+1)
	var offsetFromCenter = null
	#print(distance.x, 'test', globals.renderDistance.x)
	for z in range(len(renderedCells)-1, 0, -1):
		if abs(renderedCells[z].x-pos.x) > globals.renderDistance.x or abs(renderedCells[z].y-pos.y) > globals.renderDistance.y:
			set_cellv(renderedCells[z], -1)
			resourceTilemap.set_cellv(renderedCells[z], -1)
			renderedCells.remove(z)
	var storedPositions = globals.worldInfo[globals.currentPlanet]['world']['tileMapList'].keys()
	for x in range(distance.x):
		for y in range(distance.y):
			offsetFromCenter = Vector2(x, y)+Vector2(-(globals.renderDistance.x+2), -(globals.renderDistance.y+2))
			var coord = pos+offsetFromCenter
			#Gets value for square and adds it to tilemaplist
			if not coord in storedPositions:
				var rawValue = map.get_noise_2dv(coord)
				if coord.y > 100:
					globals.worldInfo[globals.currentPlanet]['world']['tileMapList'][coord] = [4, 0]
				elif abs(coord.x) > 200:
					globals.worldInfo[globals.currentPlanet]['world']['tileMapList'][coord] = [4, 0]
				elif round(sin((PI/24)*coord.x)*(int(map.get_noise_2d(int(int(coord.x)/24), 8)*10000)%3))+coord.y < 8:
					globals.worldInfo[globals.currentPlanet]['world']['tileMapList'][coord] = [0, 0]
				elif coord == Vector2(200, 100):
					globals.worldInfo[globals.currentPlanet]['world']['tileMapList'][coord] = [0, 9]
				else:
					if round(sin((PI/24)*coord.x)*(int(map.get_noise_2d(int(int(coord.x)/24), 8)*10000)%3))+coord.y < 11:
						 globals.worldInfo[globals.currentPlanet]['world']['tileMapList'][coord] = [3, 1]
					elif globals.isBetween(.37, .371, abs(rawValue)) or globals.isBetween(.27, .271, abs(rawValue)):
						generateOre(coord, [3, globals.oreGenerationKey[globals.currentPlanet][0]], rawValue)
					elif globals.isBetween(.33, .331, abs(rawValue)) or globals.isBetween(.23, .231, abs(rawValue)):
						generateOre(coord, [3, globals.oreGenerationKey[globals.currentPlanet][1]], rawValue)
					elif globals.isBetween(.35, .351, abs(rawValue)) or globals.isBetween(.25, .251, abs(rawValue)):
						generateOre(coord, [3, globals.oreGenerationKey[globals.currentPlanet][2]], rawValue)
					else:
						globals.worldInfo[globals.currentPlanet]['world']['tileMapList'][coord] = [3, 1]
						
			#Renders the square
			if not coord in renderedCells:
				if abs(offsetFromCenter.x) <= globals.renderDistance.x and abs(offsetFromCenter.y) <= globals.renderDistance.y:
					renderedCells.append(coord)
					var squareValue = globals.worldInfo[globals.currentPlanet]['world']['tileMapList'][coord]
					if squareValue[1] != 1 and squareValue[1] != 0: #runs if there is a resouce there
						resourceTilemap.set_cell(coord.x, coord.y, globals.resourceInfo[int(squareValue[1])]['tilemap'][0])
					elif squareValue[0] == 4:
						set_cell(coord.x, coord.y, globals.worldInfo[globals.currentPlanet]['world']['tileMapKey']['border'])
					elif squareValue[0] == 0: #-10 represents air
						set_cell(coord.x, coord.y, -1)
					else:
						set_cell(coord.x, coord.y, globals.worldInfo[globals.currentPlanet]['world']['tileMapKey']['rock'])
					if -round(sin((PI/24)*coord.x)*(int(map.get_noise_2d(int(int(coord.x)/24), 8)*10000)%3))+8 < coord.y:
						get_node('/root/worldMain/backgroundTileMap').set_cellv(coord, globals.worldInfo[globals.currentPlanet]['world']['tileMapKey']['mined'])
					newRenders.append(coord)
	for i in range(len(newRenders)):
		squareUpdate(newRenders[i])

func reset():
	get_node('/root/worldMain/Player').set_physics_process(false)
	var resourceTilemap = get_parent().get_node("resourceTileMap")
	for coord in renderedCells:
		set_cellv(coord, -1)
		resourceTilemap.set_cellv(coord, -1)
	renderedCells = []
	render(get_node('/root/worldMain/Player').position)
	get_node('/root/worldMain/Player').set_physics_process(true)
