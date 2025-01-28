extends Sprite
onready var globals = get_node("/root/global")

func showResource(resourceNum):
	if resourceNum == null:
		$icon.texture = null
		$amountText.text = ''
		$itemText.text = ''
	else:
		var resourceName = globals.resourceInfo[resourceNum]['name']
		$icon.texture = load('res://resourceImages/' + resourceName + '/' + resourceName + 'Inventory.png')
		$amountText.text = str(globals.inventory[resourceNum])
		$itemText.text = resourceName
