extends Node2D
onready var globals = get_node("/root/global")

func toggleEscape():
	$pauseMenu.toggleEscape()

var inventory = false

func _process(delta):
	if Input.is_action_just_pressed("pause"):
		globals.currentMenu.toggleEscape()
	if Input.is_action_just_pressed("inventory"):
		$inventory.toggleEscape()
	if Input.is_action_just_pressed("planetMenu"):
		if globals.playerAtShip:
			get_node(global.worldPath+'/planetMenu').toggleEscape()
	if (abs($Player.position.x-$Player2.position.x)>3000):
		$globalLight.hide()
		$player1Light.show()
		$player2Light.show()
	else:
		$globalLight.show()
		$player1Light.hide()
		$player2Light.hide()
		
func setPauseState(state):
	if state == true:
		globals.gamePaused = true
		$Player.set_physics_process(false)
		$Player2.set_physics_process(false)
	elif state == false:
		globals.gamePaused = false
		$Player.set_physics_process(true)
		$Player2.set_physics_process(true)

func _ready():
	globals.world = self
	globals.currentMenu = self
	$saveTimer.start()
	$oxygenTimer.start()
	$oxygen2Timer.start()
	$healthTimer.start()
	$health2Timer.start()
	###$background.texture = load('res://tiles/Planet' + str(int(globals.currentPlanet)+1) + 'Background.png')
func _on_saveTimer_timeout(): #Runs when the save timer reaches 0
	globals.save()

func _on_oxygenTimer_timeout():
	if globals.playerAtShip:
		globals.oxygenLevel += 5
	else:
		globals.oxygenLevel -= 2
	
	globals.oxygenLevel = clamp(globals.oxygenLevel, 0, 100+20*globals.upgradeLevels['ship'])

	get_node('/root/Main/hudPlayer1/oxygenBar').set_max(100+20*globals.upgradeLevels['ship'])
	$oxygenTimer.start()
	if globals.oxygenLevel == 0:
		adjustHealth(-10)


func _on_spaceShipCollision_body_entered(body):
	if body.name == "Player":
		$oxygenTimer.wait_time = 1
		globals.playerAtShip = true
	elif body.name == "Player2":
		$oxygen2Timer.wait_time=1
		global.player2AtShip=true

func _on_spaceShipCollision_body_exited(body):
	if body.name == "Player":
		$oxygenTimer.wait_time = 2.5
		globals.playerAtShip = false
	elif body.name == "Player2":
		$oxygen2Timer.wait_time=2.5
		globals.player2AtShip=false

func adjustHealth(amount):
	globals.playerInfo['health'] += amount
	globals.playerInfo['health'] = clamp(globals.playerInfo['health'], 0, 100)
	if globals.playerInfo['health'] == 0:
		globals.inventory = {}
		globals.playerInfo['health'] = 100
		globals.oxygenLevel = 100+20*globals.upgradeLevels['ship']
		get_node(global.worldPath+'/Player').position = Vector2(-2, -136)

func adjustPlayer2Health(amount):
	globals.player2Info['health'] += amount
	globals.player2Info['health'] = clamp(globals.player2Info['health'], 0, 100)
	if globals.player2Info['health'] == 0:
		globals.inventory = {}
		globals.player2Info['health'] = 100
		globals.oxygen2Level = 100+20*globals.upgradeLevels['ship']
		get_node(global.worldPath+'/Player2').position = Vector2(-2, -136)
func _on_healthTimer_timeout():
	$healthTimer.start()
	adjustHealth(5)


func _on_oxygen2Timer_timeout():
	if globals.player2AtShip:
		globals.oxygen2Level += 5
	else:
		globals.oxygen2Level -= 2
	globals.oxygen2Level = clamp(globals.oxygen2Level, 0, 100+20*globals.upgradeLevels['ship'])
	get_node('/root/Main/hudPlayer2/oxygenBar').set_max(100+20*globals.upgradeLevels['ship'])
	$oxygen2Timer.start()
	if globals.oxygen2Level == 0:
		adjustPlayer2Health(-10)


func _on_health2Timer_timeout():
	$health2Timer.start()
	adjustPlayer2Health(5)
