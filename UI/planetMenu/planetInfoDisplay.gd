extends TextureRect
onready var globals = get_node("/root/global")
var planetNum

func _ready():
	displayPlanet(0)
func displayPlanet(num):
	planetNum = num
	var planetInfo = globals.planetInfo[num]
	$Button.visible = true
	$planetName.text = planetInfo['name']
	$fuelDisplay.visible = true
	$fuelAmount.text = str(abs(int(globals.currentPlanet)-planetNum)*10)
	$iconDisplay.texture = load('res://UI/planetMenu/Planet' + str(int(num+1)) + '.png')
	isValid()
	
func isValid():
	var valid = true
	if planetNum != null:
		if not planetNum <= globals.upgradeLevels['ship']:
			valid = false
			print("ship")
		if not globals.inventory.getAmount("rocket_fuel") >= abs(int(globals.currentPlanet)-planetNum)*10:
			print("fuel")
			valid = false
		if int(globals.currentPlanet) == planetNum:
			valid = false
			print("num")
		if valid:
			$Button.disabled = false
		else:
			$Button.disabled = true

func _on_Button_pressed():
	var tileMap = global.world.get_node("TileMap")
	tileMap.save()
	get_node(global.worldPath+'/TileMap').reset()
	globals.inventory.add("rocket_fuel", -abs(int(globals.currentPlanet)-planetNum)*10)
	
	globals.currentPlanet = str(planetNum)
	global.world.get_node("TileMap").mapSeed = randi()*100 + randi()*100
	tileMap.setup()
	get_parent().toggleEscape()
	get_node(global.worldPath+'/Player').position = global.playerStartPos[0]
	get_node(global.worldPath+'/Player2').position = global.playerStartPos[1]
	print('Planet' + str(int(globals.currentPlanet)+1) + 'Background.png')
	global.world.get_parent().get_parent().get_node("ViewportPlayer1/ParallaxBackground/ParallaxLayer/Sprite").texture = load("res://tiles/Planet" + str(int(global.currentPlanet)+1) + "Background.png")
	global.world.get_parent().get_parent().get_parent().get_node("ViewportContainer2/ViewportPlayer2/ParallaxBackground/ParallaxLayer/Sprite").texture = load("res://tiles/Planet" + str(int(global.currentPlanet)+1) + "Background.png")
