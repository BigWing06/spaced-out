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
signal chunkChanged
var mineCells = []
var mineCellState = -1
var mineStartPos
var timerActive = false
var prePos = null
var direction = 1
var mining = false
var stop = false
var chunk = Vector2(0, 0)
var preChunk = Vector2(0, 0)

var velocity = Vector2.ZERO

func _ready():
	position = globals.playerStartPos[0]
	global.players[1] = self
	

func _physics_process(delta):
	var moveRight = Input.is_action_pressed("playerOneMoveRight")
	var moveLeft = Input.is_action_pressed("playerOneMoveLeft")
	var jump = Input.is_action_pressed("playerOneJump")
	if Input.is_action_just_pressed("playerOneMoveLeft") or Input.is_action_just_pressed("playerOneMoveRight") or Input.is_action_just_pressed("playerTwoMoveLeft") or Input.is_action_just_pressed("playerTwoMoveRight") and not (Input.is_action_pressed("playerOneMoveLeft") or Input.is_action_pressed("playerOneMoveRight") or Input.is_action_pressed("playerTwoMoveLeft") or Input.is_action_pressed("playerOneMoveRight")):
		$AnimationPlayer2.play("fadeIn")
	if Input.is_action_just_released("playerOneMoveLeft") or Input.is_action_just_released("playerOneMoveRight") or Input.is_action_just_released("playerTwoMoveLeft") or Input.is_action_just_released("playerTwoMoveRight"): 
		if not (Input.is_action_pressed("playerOneMoveLeft") or Input.is_action_pressed("playerOneMoveRight") or Input.is_action_pressed("playerTwoMoveLeft") or Input.is_action_pressed("playerOneMoveRight")):
			$AnimationPlayer2.play("fadeOut")
	velocity.y += gravity
	if jump and is_on_floor():
		velocity.y = jumpAmount
	if moveRight:
		velocity.x += movementSpeed/4
	if moveLeft:
		velocity.x -= movementSpeed/4
	if not moveRight and not moveLeft and velocity.x != 0:
		if velocity.x > 0:
			velocity.x += movementSpeed/4*(velocity.x/abs(velocity.x)*-1)
			velocity.x = clamp(velocity.x, 0, 100)
		else:
			velocity.x += movementSpeed/4*(velocity.x/abs(velocity.x)*-1)
			velocity.x = clamp(velocity.x, -100, 0)
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
	prePos = tileMapPos
	var startPos = Vector2(tileMapPos.x-globals.renderDistance.x, tileMapPos.y-globals.renderDistance.y)
	if Input.is_action_just_pressed("mine"):
		$AnimationPlayer.play("fadeIn")
	if Input.is_action_just_released("mine"):
		$AnimationPlayer.play("fadeOut")
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
			placeTileMapPos = global.world.get_node("TileMap").world_to_map(get_viewport().get_mouse_position()+position-(get_viewport().size)/2)
			if abs(placeTileMapPos.x-playerPosition.x)>1 or abs(placeTileMapPos.y-playerPosition.y)>1:
				if globals.world.get_node("TileMap").get_cellv(placeTileMapPos) == -1:
					if global.inventory.hasAmount(1, "stone"):
						globals.inventory.add("stone", -1)
						globals.world.get_node("TileMap").setCell(placeTileMapPos, 25)
						globals.world.get_node("TileMap").update_bitmask_area(placeTileMapPos)
	var tileMap = global.world.get_node("TileMap") #Gets the tilemap node from the main scene 
	chunk = (tileMap.world_to_map(position)/tileMap.chunkSize).floor()
	if preChunk != chunk:
		tileMap.onPlayerChunkChange(chunk)
		
	

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
			if get_parent().get_node("resourceTileMap").get_cellv(cell) != -1:
				var resourceValue = (get_parent().get_node("resourceTileMap").tile_set.tile_get_name(get_parent().get_node("resourceTileMap").get_cellv(cell)))
				global.inventory.add(resourceValue, 1)
				globals.world.get_node("TileMap").mineCell(cell)
				if resourceValue != "stone":
					get_parent().get_node("resourceTileMap").set_cellv(cell, -1)
		for cell in mineCells:
			globals.world.get_node("TileMap").update_bitmask_area(cell)
		mineCells = []
	else:
		for cell in mineCells:
			if globals.world.get_node("TileMap").get_cellv(cell) != -1:	
				mineTilemap.set_cellv(cell, mineCellState+3)
	if mineCellState != -1:
		mineTimer.start()
func showItemData():
	var mapPos = null
	if global.p1Screen:
		mapPos = get_node(global.worldPath+"/resourceTileMap").world_to_map(get_viewport().get_mouse_position()+position-(get_viewport().size)/2)
	else:
		mapPos = get_node(global.worldPath+"/resourceTileMap").world_to_map(get_viewport().get_mouse_position()+get_node(global.worldPath+"/Player2").position-((get_viewport().size)/2)-(Vector2(get_viewport().size.x,0)))
	var resourceValue = (get_parent().get_node("resourceTileMap").tile_set.tile_get_name(get_parent().get_node("resourceTileMap").get_cellv(mapPos)))
	global.resourceInfoNode.setText(resourceValue)
func _process(delta):
	showItemData()
