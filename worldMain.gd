extends Node2D
onready var globals = get_node("/root/global")

func toggleEscape():
	$pauseMenu.toggleEscape()

var inventory = false

func _process(delta):
	$background.position.x = get_node('/root/worldMain/Player').position.x
	if Input.is_action_just_pressed("pause"):
		globals.currentMenu.toggleEscape()
	if Input.is_action_just_pressed("inventory"):
		$inventory.toggleEscape()
	if Input.is_action_just_pressed("planetMenu"):
		if globals.playerAtShip:
			get_node('/root/worldMain/planetMenu').toggleEscape()
		
func setPauseState(state):
	if state == true:
		globals.gamePaused = true
		$Player.set_physics_process(false)
	elif state == false:
		globals.gamePaused = false
		$Player.set_physics_process(true)

func _ready():
	globals.currentMenu = self
	$saveTimer.start()
	$oxygenTimer.start()
	$healthTimer.start()
	$background.texture = load('res://tiles/Planet' + str(int(globals.currentPlanet)+1) + 'Background.png')

func _on_saveTimer_timeout(): #Runs when the save timer reaches 0
	globals.save()

func _on_oxygenTimer_timeout():
	if globals.playerAtShip:
		globals.oxygenLevel += 5
	else:
		globals.oxygenLevel -= 2
	globals.oxygenLevel = clamp(globals.oxygenLevel, 0, 100+20*globals.upgradeLevels['ship'])
	get_node('/root/worldMain/hud/oxygenBar').set_max(100+20*globals.upgradeLevels['ship'])
	$oxygenTimer.start()
	if globals.oxygenLevel == 0:
		adjustHealth(-10)

func _on_spaceShipCollision_body_entered(body):
	$oxygenTimer.wait_time = 1
	globals.playerAtShip = true

func _on_spaceShipCollision_body_exited(body):
	$oxygenTimer.wait_time = 2.5
	globals.playerAtShip = false

func adjustHealth(amount):
	globals.playerInfo['health'] += amount
	globals.playerInfo['health'] = clamp(globals.playerInfo['health'], 0, 100)
	if globals.playerInfo['health'] == 0:
		globals.inventory = {}
		globals.playerInfo['health'] = 100
		globals.oxygenLevel = 100+20*globals.upgradeLevels['ship']
		get_node('/root/worldMain/Player').position = Vector2(768, 320)


func _on_healthTimer_timeout():
	$healthTimer.start()
	adjustHealth(5)
