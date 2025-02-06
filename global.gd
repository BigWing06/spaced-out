extends Node

#const resourceInfo = {1:{'name':'Stone'}, 2:{'name':'Coal', 'tilemap':[0, 7]}, 3:{'name':'Carbon', 'craftResources':[[5, 1]]}, 4:{'name':'Rocket Fuel', 'craftResources':[[3, 1], [2, 1]]}, 5:{'name':'Organic Material', 'tilemap':[1, 9]}, 6:{'name':'Aluminum', 'tilemap':[2, 6]}, 7:{'name':'Copper', 'tilemap':[3, 8]}, 8:{'name':'Titanium', 'tilemap':[4, 10]}, 9:{'name':'rohbheighdanqueium', 'tilemap':[5]}}
const resourceInfo = {
	"stone":{'name':'Stone'}, 
	"coal":{'name':'Coal', "generation":{0:.3}}, 
	'carbon':{'name':'Carbon', 'craftResources':[["organic_material", 1]]}, 
	"rocket_fuel":{'name':'Rocket Fuel', 'craftResources':[["carbon", 1], ["coal", 1]]}, 
	'organic_material':{'name':'Organic Material', 'tilemap':[1, 9]}, 
	'aluminum':{'name':'Aluminum', 'tilemap':[2, 6]}, 
	'copper':{'name':'Copper', 'tilemap':[3, 8]}, 
	'titanium':{'name':'Titanium', 'tilemap':[4, 10]}}
const upgradeInfos = {
	'ship':[[0], [1, [['aluminum', 50]]], [2, [['aluminum', 100], ['copper', 10]]], [3, [['aluminum', 150], ['copper', 25]]], [4, [['aluminum', 200], ['copper', 50]]]], 
	'drill':[[.24], [.2, [["titanium", 25]]], [.16, [["titanium", 50], ["copper", 5]]], [.12, [["titanium", 75], ["copper", 10]]]]}
const planetInfo = [{'name':'Florp', 'icon':'res://UI/planetMenu/planetTest.png', 'fuelAmount':10}, {'name':'Planet 2', 'icon':'res://UI/planetMenu/planetTest.png', 'fuelAmount':10}, {'name':'Planet 3', 'icon':'res://UI/planetMenu/planetTest.png', 'fuelAmount':10}, {'name':'Planet 4', 'icon':'res://UI/planetMenu/planetTest.png', 'fuelAmount':10}]
const oreGenerationKey = {'0':[2, 5, 6], '1':[8, 5, 2], '2':[7, 2, 5], '3':[2, 2, 2]}
const playerStartPos = [Vector2(0, 0), Vector2(10, 0)]
var oreGenerationMap = [[Vector2(1,-1), Vector2(0, 0), Vector2(1, 0), Vector2(-1, 1)], [Vector2(0, -1), Vector2(-1, 0), Vector2(0, 0), Vector2(1, 0), Vector2(0, 1)], [Vector2(0, -1), Vector2(-1, 0), Vector2(0, 0), Vector2(1, 0), Vector2(-1, 1), Vector2(1, 1)], [Vector2(-1, -1), Vector2(0, -1), Vector2(-1, 0), Vector2(0, 0), Vector2(1, 0), Vector2(0, 1)], [Vector2(-1, -1), Vector2(1, -1), Vector2(0, 0), Vector2(0, 1), Vector2(1, 1)], [Vector2(1, -1), Vector2(0, 0), Vector2(-1, 1), Vector2(0, 1)], [Vector2(0, -1), Vector2(-1, 0), Vector2(0, 0), Vector2(1, 1)], [Vector2(-1, -1), Vector2(1, -1), Vector2(-1, 0), Vector2(0, 0), Vector2(0, 1)], [Vector2(-1, -1), Vector2(0, 0), Vector2(1, 0), Vector2(-1, 1), Vector2(0, 1)]]
var currentPlanet = '0'
var playerInfo = {'movementSpeed':800, 'health':100}
var player2Info = {'movementSpeed':800, 'health':100}
var renderDistance = Vector2(8,5)
var worldInfo = {'0':{'world':{'gravity':30, 'tileMapList':{}, 'map':null, 'tileMapKey':{'rock':7, 'rock45':8, 'border':6, 'mined':0}}}, '1':{'world':{'gravity':30, 'tileMapList':{}, 'map':null, 'tileMapKey':{'rock':9, 'rock45':10, 'border':6, 'mined':1}}}, '2':{'world':{'gravity':30, 'tileMapList':{}, 'map':null, 'tileMapKey':{'rock':11, 'rock45':12, 'border':6, 'mined':2}}}, '3':{'world':{'gravity':30, 'tileMapList':{}, 'map':null, 'tileMapKey':{'rock':13, 'rock45':14, 'border':6, 'mined':3}}}, '4':{'world':{'gravity':30, 'tileMapList':{}, 'map':null, 'tileMapKey':{'rock':1, 'rock45':3, 'border':6}}}}
var mineRadius = 1
var saveFilePath = 'user://saveData.txt'
var gamePaused = true
var oxygenLevel = 100
var oxygen2Level = 100
var currentMenu = null
var upgradeLevels = {'drill':0, 'ship':0}
var playerAtShip = false
var player2AtShip = false
var players = {}
var world = null
var worldPath = "/root/Main/Viewports/ViewportContainer/ViewportPlayer1/worldMain"
var main = null
var hideHud = false
var inventory = preload('res://playerResources/inventoryManager.gd').new()

func newGame():
	currentMenu = null
	inventory.setup()
	currentPlanet = '0'
	playerInfo = {'movementSpeed':400, 'health':100}
	renderDistance = Vector2(8, 5)
	worldInfo = {'0':{'world':{'gravity':30, 'tileMapList':{}, 'map':null, 'tileMapKey':{'rock':7, 'rock45':8, 'border':6, 'mined':0}}}, '1':{'world':{'gravity':30, 'tileMapList':{}, 'map':null, 'tileMapKey':{'rock':9, 'rock45':10, 'border':6, 'mined':1}}}, '2':{'world':{'gravity':30, 'tileMapList':{}, 'map':null, 'tileMapKey':{'rock':11, 'rock45':12, 'border':6, 'mined':2}}}, '3':{'world':{'gravity':30, 'tileMapList':{}, 'map':null, 'tileMapKey':{'rock':13, 'rock45':14, 'border':6, 'mined':3}}}, '4':{'world':{'gravity':30, 'tileMapList':{}, 'map':null, 'tileMapKey':{'rock':1, 'rock45':3, 'border':6}}}}
	mineRadius = 1
	saveFilePath = 'user://saveData.txt'
	gamePaused = true
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
	file.store_string(to_json({'world':worldInfo, 'playerPos':get_node(global.worldPath+'/Player').getSavePos(), 'inventory':inventory, 'upgrades':upgradeLevels, 'planet':currentPlanet, 'player':playerInfo}))
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
	var tileMap = get_node(worldPath+'/Player').get_parent().get_node('TileMap')
	var tempPos = Vector2(coords.x/tileMap.cell_size.x/tileMap.scale.x, coords.y/tileMap.cell_size.y/tileMap.scale.y)
	if tempPos.x < 0:
		tempPos.x-=1
	if tempPos.y < 0:
		tempPos.y-=1
	return Vector2(int(tempPos.x), int(tempPos.y))
