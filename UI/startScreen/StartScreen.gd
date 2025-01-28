extends CanvasLayer
onready var globals = get_node("/root/global")

func _on_newButton_pressed():
	globals.newGame()
	get_tree().change_scene("res://World.tscn")
	globals.gamePaused = false

func _on_loadButton_pressed():
	var file = File.new()
	#file.open("user://Documents/saveGames/saveData.txt", File.READ_WRI TE)
	file.open(globals.saveFilePath, File.READ_WRITE)
	var content = parse_json(file.get_as_text())
	file.close()
	#Converts the string keys to Vector2 keys
	for k in content['world'].keys():
		var worldInfo = {}
		var strWorldInfo = content['world'][k]['world']['tileMapList']
		for key in strWorldInfo.keys():
			var splitKey = key.split(',')
			splitKey[0] = splitKey[0].substr(1)
			splitKey[1] = splitKey[1].substr(1, len(splitKey[1])-2)
			worldInfo[Vector2(splitKey[0], splitKey[1])] = strWorldInfo[key]
		globals.worldInfo[k]['world']['tileMapList'] = worldInfo
	globals.gamePaused = false
	get_tree().change_scene("res://World.tscn")
	globals.playerPosition = Vector2(content['playerPos'][0], content['playerPos'][1])
	globals.currentPlanet = content['planet']
	for key in content['inventory'].keys():
		globals.inventory[int(key)] = int(content['inventory'][key])
	for key in content['upgrades'].keys():
		content['upgrades'][key] = int(content['upgrades'][key])
	globals.upgradeLevels = content['upgrades']
	globals.playerInfo = content['playerInfo']
