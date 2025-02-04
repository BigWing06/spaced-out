extends Sprite
onready var globals = get_node("/root/global")

func showResource(resource):
	if resource == null:
		$icon.texture = null
		$amountText.text = ''
		$itemText.text = ''
	else:
		var resourceName = globals.resourceInfo[resource]['name']
		$icon.texture = load('res://resourceImages/' + resourceName + '/' + resourceName + 'Inventory.png')
		$amountText.text = str(global.inventory.getAmount(resource))
		$itemText.text = resourceName
