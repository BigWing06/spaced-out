extends VBoxContainer
func _ready():
	global.addedUI=self
func addItem(item, amount):
	var lbl = load("res://UI/AddedItem.tscn")
	var instance = lbl.instance()
	if amount<=0:
		instance.text = str(amount)+" "+global.resourceInfo[item]["name"]
	else:
		instance.text = "+"+str(amount)+" "+global.resourceInfo[item]["name"]
	add_child(instance)
