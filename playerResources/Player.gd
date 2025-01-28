extends KinematicBody2D
onready var globals = get_node("/root/global")
onready var planetInfo = globals.worldInfo[globals.currentPlanet]
onready var gravity = planetInfo['world']['gravity']
onready var jumpAmount = gravity*-30
onready var playerInfo = globals.playerInfo
onready var movementSpeed = playerInfo['movementSpeed']
onready var tileMap = get_parent().get_node("TileMap")
onready var mineTilemap = get_parent().get_node("miningTileMap")
onready var mineTimer = get_parent().get_node("mineTimer")
var mineCells = []
var mineCellState = -1
var mineStartPos
var timerActive = false
var prePos = null
var direction = 1
var mining = false
var stop = false

var velocity = Vector2.ZERO

func _ready():
	position = globals.playerPosition

func _physics_process(delta):
	velocity.y += gravity
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jumpAmount
	if Input.is_action_pressed('moveRight'):
		velocity.x += movementSpeed/4
	if Input.is_action_pressed('moveLeft'):
		velocity.x -= movementSpeed/4
	if not Input.is_action_pressed("moveRight") and not Input.is_action_pressed("moveLeft") and velocity.x != 0:
		velocity.x += movementSpeed/4*(velocity.x/abs(velocity.x)*-1)
	velocity.y = clamp(velocity.y, jumpAmount, gravity*25)
	velocity.x = clamp(velocity.x, -movementSpeed, movementSpeed)
	
	#Determines direction character faces
	var preDirection = direction
	if velocity.x > 0:
		direction = 1
	if velocity.x < 0:
		direction = -1
	if direction != preDirection:
		scale.x = -1
		
	velocity = move_and_slide(velocity, Vector2.UP)
	var tileMapPos = globals.getTileMapPos(position)
	if tileMapPos != prePos:
		tileMap.render(tileMapPos)
	globals.playerPosition = position
	prePos = tileMapPos
	var startPos = Vector2(tileMapPos.x-globals.renderDistance.x, tileMapPos.y-globals.renderDistance.y)
	if Input.is_action_pressed("mine") and mining == false:
		mineTimer.wait_time = globals.upgradeInfos['drill'][globals.upgradeLevels['drill']][0]
		var rawPos = get_viewport().get_mouse_position()
		var center = get_viewport_rect().get_center()
		var centerTilemap = globals.getTileMapPos(center)
		var cameraPos = $Camera2D.get_camera_position()
		var tanInput = Vector2(rawPos.x-center.x, -1*(rawPos.y-center.y))
		var mineAngle = atan2(tanInput.y, tanInput.x)
		var offsetAmount = 75
		var minePos = globals.getTileMapPos(Vector2(position.x+cos(mineAngle)*offsetAmount, position.y-sin(mineAngle)*offsetAmount))+Vector2(0, -1)
		mineStartPos = Vector2(minePos.x-globals.mineRadius, minePos.y-globals.mineRadius)
		for x in range(globals.mineRadius*2+1):
			for y in range(globals.mineRadius*2+1):
				var pos = Vector2(mineStartPos.x + x, mineStartPos.y+y)
				if globals.worldInfo[globals.currentPlanet]['world']['tileMapList'][pos][0] != 4:
					mineCells.append(pos)
		mineTimer.start()
		timerActive = true
		mining = true
	elif Input.is_action_pressed("mine"):
		var rawPos = get_viewport().get_mouse_position()
		var center = get_viewport_rect().get_center()
		var centerTilemap = globals.getTileMapPos(center)
		var cameraPos = $Camera2D.get_camera_position()
		var tanInput = Vector2(rawPos.x-center.x, -1*(rawPos.y-center.y))
		var mineAngle = atan2(tanInput.y, tanInput.x)
		var offsetAmount = 75
		var minePos = globals.getTileMapPos(Vector2(position.x+cos(mineAngle)*offsetAmount, position.y-sin(mineAngle)*offsetAmount))+Vector2(0, -1)
		var mineTempStartPos = Vector2(minePos.x-globals.mineRadius, minePos.y-globals.mineRadius)
		if mineTempStartPos != mineStartPos:
			mining = false
			stop = true
			mineCellState = -1
			timerActive = false
			for cell in mineCells:
				mineTilemap.set_cellv(cell, -1)
			mineCells = []
	else:
		if mining:
			stop = true
		mining = false
		mineCellState = -1
		timerActive = false
		for cell in mineCells:
			mineTilemap.set_cellv(cell, -1)
		mineCells = []
	if mining:
		$drill.playing = true
	else:
		$drill.playing = false
	if Input.is_action_pressed("place"):
		var rawPos = get_viewport().get_mouse_position()
		var placeTileMapPos
		if get_viewport_rect().has_point(rawPos):
			var playerPosition = globals.getTileMapPos(position)
			var cameraPos = $Camera2D.get_camera_position()
			placeTileMapPos = globals.getTileMapPos(Vector2(rawPos.x+cameraPos.x-532, rawPos.y+cameraPos.y-300))
			if abs(placeTileMapPos.x-playerPosition.x)>1 or abs(placeTileMapPos.y-playerPosition.y)>1:
				if globals.worldInfo[globals.currentPlanet]['world']['tileMapList'][placeTileMapPos][0] == 0:
					if globals.inventory[1] > 0:
						globals.inventory[1] = globals.inventory[1] - 1
						globals.worldInfo[globals.currentPlanet]['world']['tileMapList'][placeTileMapPos] = [3, 1]
						tileMap.set_cellv(placeTileMapPos, 1)
						for x in range(3):
							for y in range(3):
								tileMap.squareUpdate(placeTileMapPos-Vector2(1, 1)+Vector2(x, y))
func getSavePos():
	return [position.x, position.y]
	
func _on_mineTimer_timeout():
	if not stop:
		updateMineState()
	else:
		mining = false
		stop = false
	
func updateMineState():
	mineCellState += 1
	if mineCellState == 3:
		timerActive = false
		mining = false
		mineCellState = -1
		for cell in mineCells:
			mineTilemap.set_cellv(cell, mineCellState)
			var resourceValue = globals.worldInfo[globals.currentPlanet]['world']['tileMapList'][cell][1]
			if resourceValue != 0:
				if not resourceValue in globals.inventory.keys():
					globals.inventory[int(resourceValue)] = 1
				else:
					globals.inventory[int(resourceValue)] += 1
			globals.worldInfo[globals.currentPlanet]['world']['tileMapList'][cell] = [0, 0]
			tileMap.set_cellv(cell, -1)
			if resourceValue != 1:
				get_parent().get_node("resourceTileMap").set_cellv(cell, -1)
		mineCells = []
	else:
		for cell in mineCells:
			if globals.worldInfo[globals.currentPlanet]['world']['tileMapList'][cell][0] != 0:	
				mineTilemap.set_cellv(cell, mineCellState+3)
	if mineCellState == -1:
		for x in range(globals.mineRadius+1+4):
			for y in range(globals.mineRadius+1+4):
				tileMap.squareUpdate(Vector2(mineStartPos.x+x-2, mineStartPos.y+y-2))
	else:
		mineTimer.start()
	
	
