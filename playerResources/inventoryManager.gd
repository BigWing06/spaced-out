extends Node

var inventory = {}
 #Is a list of all resrouces in the game
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var validResources

# Called when the node enters the scene tree for the first time.
func setup():
	validResources = global.resourceInfo.keys()
	for resource in global.resourceInfo.keys(): #Adds all of the valid resorucces to the dictionary as to not cause errors later
		inventory[resource] = 0
		
func checkResource(resource):
	if resource in validResources: #Checks to make sure resource is a valid resrouce otherwise throws error
		return true
	else:
		push_error(str(resource) + " is not a valid resource string")
		return false

func add(resource, amount):
	if checkResource(resource):
		inventory[resource] += amount

func getAmount(resource):
	if checkResource(resource):
		return inventory[resource]
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
