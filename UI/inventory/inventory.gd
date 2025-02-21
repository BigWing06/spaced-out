extends CanvasLayer
onready var globals = get_node("/root/global")
var itemScene = null
var craftItemScene = null
var itemSceneList = []
var craftItemSceneList = []

func _ready():
	itemScene = preload("res://UI/inventory/inventoryItem.tscn")
	craftItemScene = preload("res://UI/inventory/craftItem.tscn")
	for y in range(3): #Crates grid for item show screen
		for x in range(5):
			var item = itemScene.instance()
			$itemList.add_child(item)
			item.position = Vector2(77+66*(x+1)+75*x, 45+60+(y+1)*56+y*75)
			itemSceneList.append(item)
	var craftResourceList = []
	for key in globals.resourceInfo.keys():
		if 'craftResources' in globals.resourceInfo[key].keys():
			craftResourceList.append(key)
	for i in range(int(len(craftResourceList)/3+1)):
		var hbox = HBoxContainer.new()
		hbox.set('custom_constants/separation', 66)
		$craftMenu/ScrollContainer/craftMenuList.add_child(hbox)
		if (i+1)*3<len(craftResourceList):
			for x in range(3):
				var craftItem = craftItemScene.instance()
				hbox.add_child(craftItem)
				craftItem.showItem(craftResourceList[x])
				craftItemSceneList.append(craftItem)
		elif float(len(craftResourceList)/3) != len(craftResourceList)/3.0:
			for x in range(len(craftResourceList)%3):
				var craftItem = craftItemScene.instance()
				hbox.add_child(craftItem)
				craftItem.showItem(craftResourceList[x])
				craftItemSceneList.append(craftItem)

func toggleEscape():
	if visible == false and global.currentOverlay =="none":
		print("sdfhsdjfhskdjfhjksdfhsjkhdf")
		globals.currentMenu = self
		get_parent().setPauseState(true)
		visible = true
		inventoryUpdate()
		get_node(global.worldPath+'/inventory/craftMenu/upgradeViewer').checkResource()
		global.main.splitScreenOff()
		global.currentOverlay = "inventory"
	elif global.currentOverlay == "inventory":
		global.currentOverlay="none"
		globals.currentMenu = get_node(global.worldPath+'/pauseMenu')
		get_parent().setPauseState(false)
		visible = false
		global.main.splitScreenOn()

func inventoryUpdate():
	var resources = global.inventory.getResourceDict()
	for resource in len(resources.keys()):
		itemSceneList[resource].showResource(resources.keys()[resource])

func _on_TextureButton4_pressed():
	toggleEscape()


func _on_TextureButton_pressed(): #Runs when the buton to show the main inventory is clicked
	$craftMenu.visible = false
	$itemList.visible = true


func _on_TextureButton2_pressed(): #Runs whem the button to show crafting is clicked+
	$craftMenu.visible = true
	$itemList.visible = false


func _on_drillUpgrade_pressed():
	get_node(global.worldPath+'/inventory/craftMenu/upgradeViewer').displayUpgrade('drill', load('res://playerResources/drill/drillr.png'), 'Upgrade Drill')


func _on_shipUpgrade_pressed():
	get_node(global.worldPath+'/inventory/craftMenu/upgradeViewer').displayUpgrade('ship', load('res://Spaceship.png'), 'Upgrade Ship')
