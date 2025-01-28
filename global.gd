extends Node

const resourceInfo = {1:{'name':'Stone'}, 2:{'name':'Coal', 'tilemap':0}, 3:{'name':'Carbon', 'craftResources':[[5, 1]]}, 4:{'name':'Rocket Fuel', 'craftResources':[[3, 1], [2, 1]]}, 5:{'name':'Organic Material', 'tilemap':1}, 6:{'name':'Aluminum', 'tilemap':2}, 7:{'name':'Copper', 'tilemap':3}, 8:{'name':'Titanium', 'tilemap':4}}
const upgradeInfos = {'ship':[[0], [1, [[6, 50]]], [2, [[6, 100], [7, 10]]], [3, [[6, 150], [7, 25]]], [4, [[6, 200], [7, 50]]]], 'drill':[[.24], [.2, [[8, 25]]], [.16, [[8, 50], [7, 5]]], [.12, [[8, 75], [7, 10]]]]}
const planetInfo = [{'name':'Planet 1', 'icon':'res://UI/planetMenu/planetTest.png', 'fuelAmount':10}, {'name':'Planet 2', 'icon':'res://UI/planetMenu/planetTest.png', 'fuelAmount':10}, {'name':'Planet 3', 'icon':'res://UI/planetMenu/planetTest.png', 'fuelAmount':10}, {'name':'Planet 4', 'icon':'res://UI/planetMenu/planetTest.png', 'fuelAmount':10}]
const oreGenerationKey = {'0':[2, 5, 6], '1':[8, 5, 2], '2':[7, 2, 5], '3':[2, 2, 2]}
var oreGenerationMap = [[Vector2(1,-1), Vector2(0, 0), Vector2(1, 0), Vector2(-1, 1)], [Vector2(0, -1), Vector2(-1, 0), Vector2(0, 0), Vector2(1, 0), Vector2(0, 1)], [Vector2(0, -1), Vector2(-1, 0), Vector2(0, 0), Vector2(1, 0), Vector2(-1, 1), Vector2(1, 1)], [Vector2(-1, -1), Vector2(0, -1), Vector2(-1, 0), Vector2(0, 0), Vector2(1, 0), Vector2(0, 1)], [Vector2(-1, -1), Vector2(1, -1), Vector2(0, 0), Vector2(0, 1), Vector2(1, 1)], [Vector2(1, -1), Vector2(0, 0), Vector2(-1, 1), Vector2(0, 1)], [Vector2(0, -1), Vector2(-1, 0), Vector2(0, 0), Vector2(1, 1)], [Vector2(-1, -1), Vector2(1, -1), Vector2(-1, 0), Vector2(0, 0), Vector2(0, 1)], [Vector2(-1, -1), Vector2(0, 0), Vector2(1, 0), Vector2(-1, 1), Vector2(0, 1)]]
var currentPlanet = '0'
var playerInfo = {'movementSpeed':400, 'health':100}
var renderDistance = Vector2(8,5)
var worldInfo = {'0':{'world':{'gravity':30, 'tileMapList':{}, 'map':null, 'tileMapKey':{'rock':1, 'rock45':3, 'border':6}}}, '1':{'world':{'gravity':30, 'tileMapList':{}, 'map':null, 'tileMapKey':{'rock':1, 'rock45':3, 'border':6}}}, '2':{'world':{'gravity':30, 'tileMapList':{}, 'map':null, 'tileMapKey':{'rock':1, 'rock45':3, 'border':6}}}, '3':{'world':{'gravity':30, 'tileMapList':{}, 'map':null, 'tileMapKey':{'rock':1, 'rock45':3, 'border':6}}}, '4':{'world':{'gravity':30, 'tileMapList':{}, 'map':null, 'tileMapKey':{'rock':1, 'rock45':3, 'border':6}}}}
var mineRadius = 1
var saveFilePath = 'user://saveData.txt'
var playerPosition = Vector2(768, 320)
var gamePaused = true
var inventory = {1:0, 3:1, 2:1, 6:1000	, 7:1000, 4:500, 8:1000, 5:0}
var oxygenLevel = 100
var currentMenu = null
var upgradeLevels = {'drill':0, 'ship':0}
var playerAtShip = false

func newGame():
	currentMenu = null
	currentPlanet = '0'
	playerInfo = {'movementSpeed':400, 'health':100}
	renderDistance = Vector2(8, 5)
	worldInfo = {'0':{'world':{'gravity':30, 'tileMapList':{}, 'map':null, 'tileMapKey':{'rock':1, 'rock45':3, 'border':6}}}, '1':{'world':{'gravity':30, 'tileMapList':{}, 'map':null, 'tileMapKey':{'rock':1, 'rock45':3, 'border':6}}}, '2':{'world':{'gravity':30, 'tileMapList':{}, 'map':null, 'tileMapKey':{'rock':1, 'rock45':3, 'border':6}}}, '3':{'world':{'gravity':30, 'tileMapList':{}, 'map':null, 'tileMapKey':{'rock':1, 'rock45':3, 'border':6}}}, '4':{'world':{'gravity':30, 'tileMapList':{}, 'map':null, 'tileMapKey':{'rock':1, 'rock45':3, 'border':6}}}}
	mineRadius = 1
	saveFilePath = 'user://saveData.txt'
	playerPosition = Vector2(768, 320)
	gamePaused = true
	inventory = {1:0, 3:1, 2:1, 6:1000	, 7:1000, 4:500, 8:1000, 5:0}
	oxygenLevel = 100
	upgradeLevels = {'drill':0, 'ship':0}
	playerAtShip = false

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST: #Runs when the user closes the window
		if gamePaused == false:
			save()
		get_tree().quit()

func save(): #Handles the saving of the game
	var file = File.new()
	file.open(saveFilePath, File.WRITE)
	file.store_string(to_json({'world':worldInfo, 'playerPos':get_tree().get_current_scene().get_node('Player').getSavePos(), 'inventory':inventory, 'upgrades':upgradeLevels, 'planet':currentPlanet, 'player':playerInfo}))
	file.close()

func isBetween(lowerBound, upperBound, num):
	if num > lowerBound:
		if num < upperBound:
			return true
		else:
			return false
	else: 
		return false

func getTileMapPos(coords): #Accepts coordinates as a vector and returns the coordinate of the tilemap
	var tileMap = get_tree().get_current_scene().get_node('Player').get_parent().get_node('TileMap')
	var tempPos = Vector2(coords.x/tileMap.cell_size.x/tileMap.scale.x, coords.y/tileMap.cell_size.y/tileMap.scale.y)
	if tempPos.x < 0:
		tempPos.x-=1
	if tempPos.y < 0:
		tempPos.y-=1
	return Vector2(int(tempPos.x), int(tempPos.y))
