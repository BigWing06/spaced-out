extends TextureRect
onready var globals = get_node("/root/global")
var hasResources = true
var upgradeInfo = null
var requiredResources = null
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var requiredResourceDisplay = preload("res://UI/inventory/requiredResourceDisplay.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func display(item):
	var itemName = globals.resourceInfo[item]['name']
	var icon = load('res://resourceImages/' + itemName + '/' + itemName + 'Inventory.png')
	var requiredResources = globals.resourceInfo[item]['craftResources']
	updateInfo(icon, requiredResources, itemName, ['item', item])
			
func displayUpgrade(type, icon, title):
	if globals.upgradeLevels[type]+1 > len(globals.upgradeInfos[type])-1:
		$name.text = title
		$icon.texture = icon
		$craftButton.visible = true
		$required.visible = true
		$craftButton.disabled = true
		$maxLevelLabel.visible = true
	else:
		updateInfo(icon, globals.upgradeInfos[type][globals.upgradeLevels[type]+1][1], title, ['upgrade', type])
	
func updateInfo(texture, resourcesNeeded, title, info):
	requiredResources = resourcesNeeded
	upgradeInfo = info
	hasResources = true
	$maxLevelLabel.visible = false
	$name.text = title
	$icon.texture = texture
	$craftButton.visible = true
	$required.visible = true
	for child in $resourceContainer.get_children():
		child.queue_free()
	for i in range(len(requiredResources)):
		var display = requiredResourceDisplay.instance()
		$resourceContainer.add_child(display)
		display.display(requiredResources[i])
		if not global.inventory.hasAmount(requiredResources[i][1], requiredResources[i][0]):
			hasResources = false
	if not hasResources:
		$craftButton.disabled = true
	else:
		$craftButton.disabled = false
func checkResource():
	if upgradeInfo != null:
		if upgradeInfo[0] == 'upgrade':
			if not globals.upgradeLevels[upgradeInfo[1]]+1 > len(globals.upgradeInfos[upgradeInfo[1]])-1:
				checkResourceSub()
			else:
				$craftButton.disabled = true
		else:
			checkResourceSub()

func checkResourceSub():
	hasResources = true
	for i in range(len(requiredResources)):
		if requiredResources[i][0] in globals.inventory.keys():
			if not globals.inventory[requiredResources[i][0]] >= requiredResources[i][1]:
				hasResources = false
		else:
			hasResources = false
		if not hasResources:
			$craftButton.disabled = true
		else:
			$craftButton.disabled = false


func _on_craftButton_pressed():
	for r in requiredResources:
		globals.inventory[r[0]] -= r[1]
	if upgradeInfo[0] == 'item':
		if not upgradeInfo[1] in globals.inventory.keys():
			globals.inventory[upgradeInfo[1]] = 0
		globals.inventory[upgradeInfo[1]] += 1
		checkResource()
	else:
		globals.upgradeLevels[upgradeInfo[1]] += 1
		displayUpgrade(upgradeInfo[1], $icon.texture, $name.text)
	get_node('/root/worldMain/inventory').inventoryUpdate()
