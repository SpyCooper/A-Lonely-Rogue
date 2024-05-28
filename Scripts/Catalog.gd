extends Control

# enemies
@onready var blue_slime_panel = $TabContainer/Monsters/Panels/Blue_slime_panel
@onready var blue_slime_button = $TabContainer/Monsters/ScrollContainer/GridContainer/Spot/Blue_slime
@onready var blue_slime_kill_count_label = $TabContainer/Monsters/Panels/Blue_slime_panel/KillCount
var blue_slime_unlocked = false
var blue_slime_kill_count = 0

@onready var green_slime_panel = $TabContainer/Monsters/Panels/Green_slime_panel
@onready var green_slime_button = $TabContainer/Monsters/ScrollContainer/GridContainer/Spot2/Green_slime
@onready var green_slime_kill_count_label = $TabContainer/Monsters/Panels/Green_slime_panel/KillCount
var green_slime_unlocked = false
var green_slime_kill_count = 0

@onready var gelatinous_cube_button = $TabContainer/Bosses/ScrollContainer/GridContainer/Spot/Gelatinous_cube_button
@onready var gelatinous_cube_panel = $TabContainer/Bosses/Panels/Gelatinous_Cube_panel
@onready var gel_cube_kill_count_label = $TabContainer/Bosses/Panels/Gelatinous_Cube_panel/KillCount
var gelatinous_cube_unlocked = false
var gelatinous_cube_kill_count = 0

# items
@onready var speed_boots_button = $TabContainer/Items/ScrollContainer/GridContainer/Spot/Boots_button
@onready var speed_boots_panel = $TabContainer/Items/Panels/Boots_panel
var speed_boots_unlocked = false
@onready var dust_blade_button = $TabContainer/Items/ScrollContainer/GridContainer/Spot2/dust_blade_button
@onready var dust_blade_panel = $TabContainer/Items/Panels/Dust_blade_panel
var dust_blade_unlocked = false
@onready var glass_blade_button = $TabContainer/Items/ScrollContainer/GridContainer/Spot3/Glass_blade_button
@onready var glass_blade_panel = $TabContainer/Items/Panels/Glass_blade_panel
var glass_blade_unlocked = false
@onready var heart_button = $TabContainer/Items/ScrollContainer/GridContainer/Spot4/Heart_button
@onready var heart_panel = $TabContainer/Items/Panels/Heart_panel
var heart_unlocked = false
@onready var key_button = $TabContainer/Items/ScrollContainer/GridContainer/Spot5/Key_button
@onready var key_panel = $TabContainer/Items/Panels/Key_panel
var key_unlocked = false
@onready var poison_button = $TabContainer/Items/ScrollContainer/GridContainer/Spot6/Poison_button
@onready var poison_panel = $TabContainer/Items/Panels/Poison_panel
var poison_unlocked = false
@onready var quick_blades_button = $TabContainer/Items/ScrollContainer/GridContainer/Spot7/Quick_blades_button
@onready var quick_blades_panel = $TabContainer/Items/Panels/Quick_blades_panel
var quick_blades_unlocked = false
@onready var shadow_blade_button = $TabContainer/Items/ScrollContainer/GridContainer/Spot8/Shadow_blade_button
@onready var shadow_blade_panel = $TabContainer/Items/Panels/Shadow_blade_panel
var shadow_blade_unlocked = false
@onready var shadow_flame_button = $TabContainer/Items/ScrollContainer/GridContainer/Spot9/Shadow_flame_button
@onready var shadow_flame_panel = $TabContainer/Items/Panels/Shadow_flame_panel
var shadow_flame_unlocked = false
@onready var shadow_heart_button = $TabContainer/Items/ScrollContainer/GridContainer/Spot10/Shadow_heart_button
@onready var shadow_heart_panel = $TabContainer/Items/Panels/Shadow_heart_panel
var shadow_heart_unlocked = false
@onready var triple_blades_button = $TabContainer/Items/ScrollContainer/GridContainer/Spot11/Triple_blades_button
@onready var triple_blades_panel = $TabContainer/Items/Panels/Triple_blades_panel
var triple_blades_unlocked = false

func _ready():
	Events.catalog = self
	hide()
	clear_panel()
	load_data()

func _on_blue_slime_pressed():
	clear_panel()
	if blue_slime_unlocked:
		blue_slime_panel.show()
	
func _on_green_slime_pressed():
	clear_panel()
	if green_slime_unlocked:
		green_slime_panel.show()

func clear_panel():
	blue_slime_panel.hide()
	green_slime_panel.hide()
	
	gelatinous_cube_panel.hide()
	
	speed_boots_panel.hide()
	dust_blade_panel.hide()
	glass_blade_panel.hide()
	heart_panel.hide()
	key_panel.hide()
	poison_panel.hide()
	quick_blades_panel.hide()
	shadow_blade_panel.hide()
	shadow_flame_panel.hide()
	shadow_heart_panel.hide()
	triple_blades_panel.hide()

func unlock_enemy(enemy):
	if enemy == EnemyTypes.enemy.blue_slime:
		if !blue_slime_unlocked:
			blue_slime_button.material.shader = null
			blue_slime_unlocked = true
		blue_slime_kill_count += 1
		update_kill_counts()
	elif enemy == EnemyTypes.enemy.green_slime:
		if !green_slime_unlocked:
			green_slime_button.material.shader = null
			green_slime_unlocked = true
		green_slime_kill_count += 1
		update_kill_counts()
	elif enemy == EnemyTypes.enemy.gelatinous_cube:
		if !gelatinous_cube_unlocked:
			gelatinous_cube_button.material.shader = null
			gelatinous_cube_unlocked = true
		gelatinous_cube_kill_count += 1
		update_kill_counts()
	
	save_enemies()


func unlock_item(item):
	if item == ItemType.type.speed_boots:
		if !speed_boots_unlocked:
			speed_boots_button.material.shader = null
			speed_boots_unlocked = true
	elif item == ItemType.type.dust_blade:
		if !dust_blade_unlocked:
			dust_blade_button.material.shader = null
			dust_blade_unlocked = true
	elif item == ItemType.type.glass_blade:
		if !glass_blade_unlocked:
			glass_blade_button.material.shader = null
			glass_blade_unlocked = true
	elif item == ItemType.type.health_1 || item == ItemType.type.health_2:
		if !heart_unlocked:
			heart_button.material.shader = null
			heart_unlocked = true
	elif item == ItemType.type.key:
		if !key_unlocked:
			key_button.material.shader = null
			key_unlocked = true
	elif item == ItemType.type.poisoned_blades:
		if !poison_unlocked:
			poison_button.material.shader = null
			poison_unlocked = true
	elif item == ItemType.type.quick_blades:
		if !quick_blades_unlocked:
			quick_blades_button.material.shader = null
			quick_blades_unlocked = true
	elif item == ItemType.type.shadow_blade:
		if !shadow_blade_unlocked:
			shadow_blade_button.material.shader = null
			shadow_blade_unlocked = true
	elif item == ItemType.type.shadow_flame:
		if !shadow_flame_unlocked:
			shadow_flame_button.material.shader = null
			shadow_flame_unlocked = true
	elif item == ItemType.type.shadow_heart:
		if !shadow_heart_unlocked:
			shadow_heart_button.material.shader = null
			shadow_heart_unlocked = true
	elif item == ItemType.type.triple_blades:
		if !triple_blades_unlocked:
			triple_blades_button.material.shader = null
			triple_blades_unlocked = true
	
	save_items()

func _on_gelatinous_cube_button_pressed():
	clear_panel()
	if gelatinous_cube_unlocked:
		gelatinous_cube_panel.show()

func save_enemies():
	var save_data = FileAccess.open("user://enemiesfound.save", FileAccess.WRITE)
	var json_string= JSON.stringify(found_enemies())
	save_data.store_line(json_string)

func found_enemies():
	var data = {
		"blue_slime_unlocked" : blue_slime_unlocked,
		"blue_slime_kill_count": blue_slime_kill_count,
		"green_slime_unlocked" : green_slime_unlocked,
		"green_slime_kill_count" : green_slime_kill_count,
		"gelatinous_cube_unlocked" : gelatinous_cube_unlocked,
		"gelatinous_cube_kill_count" : gelatinous_cube_kill_count,
	}
	return data

func save_items():
	var save_data = FileAccess.open("user://itemsfound.save", FileAccess.WRITE)
	var json_string= JSON.stringify(found_items())
	save_data.store_line(json_string)

func found_items():
	var data = {
		"speed_boots_unlocked" : speed_boots_unlocked,
		"dust_blade_unlocked" : dust_blade_unlocked,
		"glass_blade_unlocked" : glass_blade_unlocked,
		"heart_unlocked" : heart_unlocked,
		"key_unlocked" : key_unlocked,
		"poison_unlocked" : poison_unlocked,
		"quick_blades_unlocked" : quick_blades_unlocked,
		"shadow_blade_unlocked" : shadow_blade_unlocked,
		"shadow_flame_unlocked" : shadow_flame_unlocked,
		"shadow_heart_unlocked" : shadow_heart_unlocked,
		"triple_blades_unlocked"  : triple_blades_unlocked,
	}
	return data

func load_data():
	if !FileAccess.file_exists("user://enemiesfound.save"):
		return
	else:
		var saved_enemies = FileAccess.open("user://enemiesfound.save", FileAccess.READ)
		while saved_enemies.get_position() < saved_enemies.get_length():
			var json_string = saved_enemies.get_line()
			var json = JSON.new()
			var parse_result = json.parse(json_string)
			var data = json.get_data()
			
			blue_slime_unlocked = data["blue_slime_unlocked"]
			if blue_slime_unlocked:
				blue_slime_button.material.shader = null
				blue_slime_kill_count = data["blue_slime_kill_count"]
			
			green_slime_unlocked = data["green_slime_unlocked"]
			if green_slime_unlocked:
				green_slime_button.material.shader = null
				green_slime_kill_count = data["green_slime_kill_count"]
			
			gelatinous_cube_unlocked = data["gelatinous_cube_unlocked"]
			if gelatinous_cube_unlocked:
				gelatinous_cube_button.material.shader = null
				gelatinous_cube_kill_count = data["gelatinous_cube_kill_count"]
			
			update_kill_counts()
	
	if !FileAccess.file_exists("user://itemsfound.save"):
		return
	else:
		var saved_enemies = FileAccess.open("user://itemsfound.save", FileAccess.READ)
		while saved_enemies.get_position() < saved_enemies.get_length():
			var json_string = saved_enemies.get_line()
			var json = JSON.new()
			var parse_result = json.parse(json_string)
			var data = json.get_data()
			
			speed_boots_unlocked = data["speed_boots_unlocked"]
			if speed_boots_unlocked:
				speed_boots_button.material.shader = null
			
			dust_blade_unlocked = data["dust_blade_unlocked"]
			if dust_blade_unlocked:
				dust_blade_button.material.shader = null
			
			glass_blade_unlocked = data["glass_blade_unlocked"]
			if glass_blade_unlocked:
				glass_blade_button.material.shader = null
			
			heart_unlocked = data["heart_unlocked"]
			if heart_unlocked:
				heart_button.material.shader = null
			
			key_unlocked = data["key_unlocked"]
			if key_unlocked:
				key_button.material.shader = null
			
			poison_unlocked = data["poison_unlocked"]
			if poison_unlocked:
				poison_button.material.shader = null
			
			quick_blades_unlocked = data["quick_blades_unlocked"]
			if quick_blades_unlocked:
				quick_blades_button.material.shader = null
			
			shadow_blade_unlocked = data["shadow_blade_unlocked"]
			if shadow_blade_unlocked:
				shadow_blade_button.material.shader = null
			
			shadow_flame_unlocked = data["shadow_flame_unlocked"]
			if shadow_flame_unlocked:
				shadow_flame_button.material.shader = null
			
			shadow_heart_unlocked = data["shadow_heart_unlocked"]
			if shadow_heart_unlocked:
				shadow_heart_button.material.shader = null
			
			triple_blades_unlocked = data["triple_blades_unlocked"]
			if triple_blades_unlocked:
				triple_blades_button.material.shader = null

func update_kill_counts():
	blue_slime_kill_count_label.text = "Killed: " + str(blue_slime_kill_count)
	green_slime_kill_count_label.text = "Killed: " + str(green_slime_kill_count)
	gel_cube_kill_count_label.text = "Killed: " + str(gelatinous_cube_kill_count)

func _on_close_button_pressed():
	hide()

func _on_boots_button_pressed():
	clear_panel()
	if speed_boots_unlocked:
		speed_boots_panel.show()

func _on_dust_blade_button_pressed():
	clear_panel()
	if dust_blade_unlocked:
		dust_blade_panel.show()

func _on_glass_blade_button_pressed():
	clear_panel()
	if glass_blade_unlocked:
		glass_blade_panel.show()

func _on_heart_button_pressed():
	clear_panel()
	if heart_unlocked:
		heart_panel.show()

func _on_key_button_pressed():
	clear_panel()
	if key_unlocked:
		key_panel.show()

func _on_poison_button_pressed():
	clear_panel()
	if poison_unlocked:
		poison_panel.show()

func _on_quick_blades_button_pressed():
	clear_panel()
	if quick_blades_unlocked:
		quick_blades_panel.show()

func _on_shadow_blade_button_pressed():
	clear_panel()
	if shadow_blade_unlocked:
		shadow_blade_panel.show()

func _on_shadow_flame_button_pressed():
	clear_panel()
	if shadow_flame_unlocked:
		shadow_flame_panel.show()

func _on_shadow_heart_button_pressed():
	clear_panel()
	if shadow_heart_unlocked:
		shadow_heart_panel.show()


func _on_triple_blades_button_pressed():
	clear_panel()
	if triple_blades_unlocked:
		triple_blades_panel.show()
