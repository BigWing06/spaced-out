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

func add(resource, amount): #Adds an amount of a specific resrouce to inventory
	if checkResource(resource):
		inventory[resource] += amount
		if  global.addedUI:
			global.addedUI.addItem(resource,amount)

func getAmount(resource): #Gets amount of a specific resource in inventory
	if checkResource(resource):
		return inventory[resource]
		
func hasAmount(amount, resource): #Checks to see if a specified amount of a resource is in the inventory
	if checkResource(resource):
		if amount <= getAmount(resource):
			return true
	return false
		
func getResourceDict(): #Returns a dictionary containg resouces and amounts that are in inventory
	var output = {}
	for resource in inventory.keys():
		if inventory[resource] > 0:
			output[resource] = inventory[resource]
	return output
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
