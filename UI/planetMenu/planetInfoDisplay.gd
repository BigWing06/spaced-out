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
	
func isValid():
	var valid = true
	if planetNum != null:
		if not planetNum <= globals.upgradeLevels['ship']:
			valid = false
		if not globals.inventory.getAmount("rocket_fuel") >= abs(int(globals.currentPlanet)-planetNum)*10:
			valid = false
		if int(globals.currentPlanet) == planetNum:
			valid = false
		if valid:
			$Button.disabled = false
		else:
			$Button.disabled = true


func _on_Button_pressed():
	get_node('/root/worldMain/TileMap').reset()
	globals.inventory[4] -= abs(int(globals.currentPlanet)-planetNum)*10
	get_node('/root/worldMain/Player').position = Vector2(768, 300)
	globals.currentPlanet = str(planetNum)
	get_node('/root/worldMain/background').texture = load('res://tiles/Planet' + str(int(globals.currentPlanet)+1) + 'Background.png')
