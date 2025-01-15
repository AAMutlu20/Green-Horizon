extends Control

func set_tile_info(tile_id: int):
	for child in $Popup.get_children():
		if child is TextureRect:
			child.visible = false

	match tile_id:
		0:
			$Popup/TR_DisplayRiver.visible = true
		1:
			$Popup/TR_DisplayWaterPlant.visible = true
		2:
			$Popup/TR_DisplayHill.visible = true
		3:
			$Popup/TR_DisplayMine.visible = true
		4:
			$Popup/TR_DisplayMountain.visible = true
		5:
			$Popup/TR_DisplayDesertMine.visible = true
		6:
			$Popup/TR_DisplayDesert.visible = true
		7:
			$Popup/TR_DisplayRefinery.visible = true
		8:
			$Popup/TR_DisplayDesertSands.visible = true
		9:
			$Popup/TR_DisplaySolarPanel.visible = true
		_:
			print("Unknown tile ID:", tile_id)

func set_tile_name(tile_name: String):
	$TileNameLabel.text = tile_name

func _on_UpgradeButton_pressed():
	queue_free()
