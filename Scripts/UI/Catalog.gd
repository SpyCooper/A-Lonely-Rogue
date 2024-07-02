extends Control

# enemy variables
# all enemy sections on the catalog need a reference to it's button, the panel, the kill count, and a bool
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
@onready var earth_elemental_button = $TabContainer/Monsters/ScrollContainer/GridContainer/Spot3/earth_elemental_button
@onready var earth_elemental_panel = $TabContainer/Monsters/Panels/Earth_elemental_panel
@onready var earth_elemental_kill_count_label = $TabContainer/Monsters/Panels/Earth_elemental_panel/KillCountLabel
var earth_elemental_unlocked = false
var earth_elemental_kill_count = 0
@onready var air_elemental_button = $TabContainer/Monsters/ScrollContainer/GridContainer/Spot4/air_elemental_button
@onready var air_elemental_panel = $TabContainer/Monsters/Panels/air_elemental_panel
@onready var air_elemental_kill_count_label = $TabContainer/Monsters/Panels/air_elemental_panel/KillCountLabel
var air_elemental_unlocked = false
var air_elemental_kill_count = 0
@onready var forgotten_golem_button = $TabContainer/Bosses/ScrollContainer/GridContainer/Spot2/Forgotten_Golem_button
@onready var forgotten_golem_panel = $TabContainer/Bosses/Panels/Forgotten_Golem_panel
@onready var forgotten_golem_kill_count_label = $TabContainer/Bosses/Panels/Forgotten_Golem_panel/KillCount
var forgotten_golem_unlocked = false
var forgotten_golem_kill_count = 0
@onready var skeleton_warrior_button = $TabContainer/Monsters/ScrollContainer/GridContainer/Spot5/skeleton_warrior_button
@onready var skeleton_warrior_panel = $TabContainer/Monsters/Panels/skeleton_warrior_panel
@onready var skeleton_warrior_kill_count_label = $TabContainer/Monsters/Panels/skeleton_warrior_panel/KillCountLabel
var skeleton_warrior_unlocked = false
var skeleton_warrior_kill_count = 0
@onready var skeleton_archer_button = $TabContainer/Monsters/ScrollContainer/GridContainer/Spot6/skeleton_archer_button
@onready var skeleton_archer_panel = $TabContainer/Monsters/Panels/skeleton_archer_panel
@onready var skeleton_archer_kill_count_label = $TabContainer/Monsters/Panels/skeleton_archer_panel/KillCountLabel
var skeleton_archer_unlocked = false
var skeleton_archer_kill_count = 0
@onready var skeleton_mage_button = $TabContainer/Monsters/ScrollContainer/GridContainer/Spot7/skeleton_mage_button
@onready var skeleton_mage_panel = $TabContainer/Monsters/Panels/skeleton_mage_panel
@onready var skeleton_mage_kill_count_label = $TabContainer/Monsters/Panels/skeleton_mage_panel/KillCountLabel
var skeleton_mage_unlocked = false
var skeleton_mage_kill_count = 0
@onready var lich_button = $TabContainer/Bosses/ScrollContainer/GridContainer/Spot3/Lich_button
@onready var lich_panel = $TabContainer/Bosses/Panels/Lich_panel
@onready var lich_kill_count_label = $TabContainer/Bosses/Panels/Lich_panel/KillCount
var lich_unlocked = false
var lich_kill_count = 0
@onready var shade_button = $TabContainer/Monsters/ScrollContainer/GridContainer/Spot8/shade_button
@onready var shade_panel = $TabContainer/Monsters/Panels/shade_panel
@onready var shade_kill_count_label = $TabContainer/Monsters/Panels/shade_panel/KillCountLabel
var shade_unlocked = false
var shade_kill_count = 0
@onready var skeleton_button = $TabContainer/Monsters/ScrollContainer/GridContainer/Spot9/skeleton_button
@onready var skeleton_panel = $TabContainer/Monsters/Panels/skeleton_panel
@onready var skeleton_kill_count_label = $TabContainer/Monsters/Panels/skeleton_panel/KillCountLabel
var skeleton_unlocked = false
var skeleton_kill_count = 0
@onready var morphed_shade_button = $TabContainer/Bosses/ScrollContainer/GridContainer/Spot4/Morphed_Shade_button
@onready var morphed_shade_panel = $TabContainer/Bosses/Panels/Morphed_Shade_panel
@onready var morphed_shade_kill_count_label = $TabContainer/Bosses/Panels/Morphed_Shade_panel/KillCount
var morphed_shade_unlocked = false
var morphed_shade_kill_count = 0

# items variables
# all enemy sections on the catalog need a reference to it's button, the panel, and a bool
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
@onready var holy_heart_button = $TabContainer/Items/ScrollContainer/GridContainer/Spot12/holy_heart_button
@onready var holy_heart_panel = $TabContainer/Items/Panels/holy_heart_panel
var holy_heart_unlocked = false
@onready var poorly_made_voodoo_doll_button = $TabContainer/Items/ScrollContainer/GridContainer/Spot13/poorly_made_voodoo_doll_button
@onready var poorly_made_voodoo_doll_panel = $TabContainer/Items/Panels/poorly_made_voodoo_doll_panel
var poorly_made_voodoo_doll_unlocked = false
@onready var sleek_blade_button = $TabContainer/Items/ScrollContainer/GridContainer/Spot14/Sleek_blade_button
@onready var sleek_blade_panel = $TabContainer/Items/Panels/Sleek_blade_panel
var sleek_blade_unlocked = false
@onready var dash_boots_button = $TabContainer/Items/ScrollContainer/GridContainer/Spot15/Dash_boots_button
@onready var dash_boots_panel = $TabContainer/Items/Panels/Dash_boots_panel
var dash_boots_unlocked = false
@onready var poison_gas_button = $TabContainer/Items/ScrollContainer/GridContainer/Spot16/Poison_gas_button
@onready var poison_gas_panel = $TabContainer/Items/Panels/poison_gas_panel
var poison_gas_unlocked = false
@onready var protective_charm_button = $TabContainer/Items/ScrollContainer/GridContainer/Spot17/Protective_charm_button
@onready var protective_charm_panel = $TabContainer/Items/Panels/protective_charm_panel
var protective_charm_unlocked = false
@onready var rogue_in_a_bottle_button = $TabContainer/Items/ScrollContainer/GridContainer/Spot18/rogue_in_a_bottle_button
@onready var rogue_in_a_bottle_panel = $TabContainer/Items/Panels/rogue_in_a_bottle_panel
var rogue_in_a_bottle_unlocked = false
@onready var hurtful_charm_button = $TabContainer/Items/ScrollContainer/GridContainer/Spot19/Hurtful_charm_button
@onready var hurtful_charm_panel = $TabContainer/Items/Panels/hurtful_charm_panel
var hurtful_charm_unlocked = false
@onready var magically_trapped_rogue_button = $TabContainer/Items/ScrollContainer/GridContainer/Spot20/magically_trapped_rogue_button
@onready var magically_trapped_rogue_panel = $TabContainer/Items/Panels/magically_trapped_rogue_panel
var magically_trapped_rogue_unlocked = false
@onready var dead_rogues_head_button = $TabContainer/Items/ScrollContainer/GridContainer/Spot21/dead_rogues_head_button
@onready var dead_rogues_head_panel = $TabContainer/Items/Panels/dead_rogues_head_panel
var dead_rogues_head_unlocked = false
@onready var bomb_button = $TabContainer/Items/ScrollContainer/GridContainer/Spot22/bomb_button
@onready var bomb_panel = $TabContainer/Items/Panels/bomb_panel
var bomb_unlocked = false

# on start
func _ready():
	# set the catalog reference
	Events.catalog = self
	# hide the catalog
	hide()
	# clear whatever is in the catalog
	clear_panel()
	# load the catalog data from the save file
	load_data()

# close the catalog when then close button is pressed
func _on_close_button_pressed():
	hide()

# loads in the data from "itemsfound.save" and "enemiesfound.save"
func load_data():
	# if enemiesfound does not exist
	if !FileAccess.file_exists("user://enemiesfound.save"):
		# exit load
		return
	else:
		# read in the data from the save file
		var saved_enemies = FileAccess.open("user://enemiesfound.save", FileAccess.READ)
		while saved_enemies.get_position() < saved_enemies.get_length():
			var json_string = saved_enemies.get_line()
			var json = JSON.new()
			var parse_result = json.parse(json_string)
			var data = json.get_data()
			for enemy in data:
				if enemy == "blue_slime_unlocked":
					# blue slime check
					blue_slime_unlocked = data["blue_slime_unlocked"]
					if blue_slime_unlocked:
						blue_slime_button.material.shader = null
						blue_slime_kill_count = data["blue_slime_kill_count"]
				elif enemy == "green_slime_unlocked":
					# green slime check
					green_slime_unlocked = data["green_slime_unlocked"]
					if green_slime_unlocked:
						green_slime_button.material.shader = null
						green_slime_kill_count = data["green_slime_kill_count"]
				elif enemy == "gelatinous_cube_unlocked":
					# gelatinous cube check
					gelatinous_cube_unlocked = data["gelatinous_cube_unlocked"]
					if gelatinous_cube_unlocked:
						gelatinous_cube_button.material.shader = null
						gelatinous_cube_kill_count = data["gelatinous_cube_kill_count"]
				elif enemy == "earth_elemental_unlocked":
					# earth elemental check
					earth_elemental_unlocked = data["earth_elemental_unlocked"]
					if earth_elemental_unlocked:
						earth_elemental_button.material.shader = null
						earth_elemental_kill_count = data["earth_elemental_kill_count"]
				elif enemy == "air_elemental_unlocked":
					# air elemental check
					air_elemental_unlocked = data["air_elemental_unlocked"]
					if air_elemental_unlocked:
						air_elemental_button.material.shader = null
						air_elemental_kill_count = data["air_elemental_kill_count"]
				elif enemy == "forgotten_golem_unlocked":
					# forgotten golem check
					forgotten_golem_unlocked = data["forgotten_golem_unlocked"]
					if forgotten_golem_unlocked:
						forgotten_golem_button.material.shader = null
						forgotten_golem_kill_count = data["forgotten_golem_kill_count"]
				elif enemy == "skeleton_warrior_unlocked":
					# skeleton warrior check
					skeleton_warrior_unlocked = data["skeleton_warrior_unlocked"]
					if skeleton_warrior_unlocked:
						skeleton_warrior_button.material.shader = null
						skeleton_warrior_kill_count = data["skeleton_warrior_kill_count"]
				elif enemy == "skeleton_archer_unlocked":
					# skeleton archer check
					skeleton_archer_unlocked = data["skeleton_archer_unlocked"]
					if skeleton_archer_unlocked:
						skeleton_archer_button.material.shader = null
						skeleton_archer_kill_count = data["skeleton_archer_kill_count"]
				elif enemy == "skeleton_mage_unlocked":
					# skeleton mage check
					skeleton_mage_unlocked = data["skeleton_mage_unlocked"]
					if skeleton_mage_unlocked:
						skeleton_mage_button.material.shader = null
						skeleton_mage_kill_count = data["skeleton_mage_kill_count"]
				elif enemy == "lich_unlocked":
					# lich check
					lich_unlocked = data["lich_unlocked"]
					if lich_unlocked:
						lich_button.material.shader = null
						lich_kill_count = data["lich_kill_count"]
				elif enemy == "shade_unlocked":
					# shade check
					shade_unlocked = data["shade_unlocked"]
					if shade_unlocked:
						shade_button.material.shader = null
						shade_kill_count = data["shade_kill_count"]
				elif enemy == "skeleton_unlocked":
					# skeleton check
					skeleton_unlocked = data["skeleton_unlocked"]
					if skeleton_unlocked:
						skeleton_button.material.shader = null
						skeleton_kill_count = data["skeleton_kill_count"]
				elif enemy == "morphed_shade_unlocked":
					# morphed shade check
					morphed_shade_unlocked = data["morphed_shade_unlocked"]
					if morphed_shade_unlocked:
						morphed_shade_button.material.shader = null
						morphed_shade_kill_count = data["morphed_shade_kill_count"]
			# update the kill counts in the catalog
			update_kill_counts()
		save_enemies()
	
	# if itemsfound does not exist
	if !FileAccess.file_exists("user://itemsfound.save"):
		# exit load
		return
	else:
		# read in the data from the save file
		var saved_items = FileAccess.open("user://itemsfound.save", FileAccess.READ)
		while saved_items.get_position() < saved_items.get_length():
			var json_string = saved_items.get_line()
			var json = JSON.new()
			var parse_result = json.parse(json_string)
			var data = json.get_data()
			for item in data:
				if item == "speed_boots_unlocked":
					# speed boots check
					speed_boots_unlocked = data["speed_boots_unlocked"]
					if speed_boots_unlocked:
						speed_boots_button.material.shader = null
				elif item == "dust_blade_unlocked":
					# dust blade check
					dust_blade_unlocked = data["dust_blade_unlocked"]
					if dust_blade_unlocked:
						dust_blade_button.material.shader = null
				elif item == "glass_blade_unlocked":
					# glass blade check
					glass_blade_unlocked = data["glass_blade_unlocked"]
					if glass_blade_unlocked:
						glass_blade_button.material.shader = null
				elif item == "heart_unlocked":
					# heart check
					heart_unlocked = data["heart_unlocked"]
					if heart_unlocked:
						heart_button.material.shader = null
				elif item == "key_unlocked":
					# key check
					key_unlocked = data["key_unlocked"]
					if key_unlocked:
						key_button.material.shader = null
				elif item == "poison_unlocked":
					# poison blade check
					poison_unlocked = data["poison_unlocked"]
					if poison_unlocked:
						poison_button.material.shader = null
				elif item == "quick_blades_unlocked":
					# quick blade check
					quick_blades_unlocked = data["quick_blades_unlocked"]
					if quick_blades_unlocked:
						quick_blades_button.material.shader = null
				elif item == "shadow_blade_unlocked":
					# shadow blade check
					shadow_blade_unlocked = data["shadow_blade_unlocked"]
					if shadow_blade_unlocked:
						shadow_blade_button.material.shader = null
				elif item == "shadow_flame_unlocked":
					# shadow flame blade check
					shadow_flame_unlocked = data["shadow_flame_unlocked"]
					if shadow_flame_unlocked:
						shadow_flame_button.material.shader = null
				elif item == "shadow_heart_unlocked":
					# shadow heart check
					shadow_heart_unlocked = data["shadow_heart_unlocked"]
					if shadow_heart_unlocked:
						shadow_heart_button.material.shader = null
				elif item == "triple_blades_unlocked":
					# triple blades check
					triple_blades_unlocked = data["triple_blades_unlocked"]
					if triple_blades_unlocked:
						triple_blades_button.material.shader = null
				elif item == "holy_heart_unlocked":
					# holy heart check
					holy_heart_unlocked = data["holy_heart_unlocked"]
					if holy_heart_unlocked:
						holy_heart_button.material.shader = null
				elif item == "poorly_made_voodoo_doll_unlocked":
					# poorly_made_voodoo_doll check
					poorly_made_voodoo_doll_unlocked = data["poorly_made_voodoo_doll_unlocked"]
					if poorly_made_voodoo_doll_unlocked:
						poorly_made_voodoo_doll_button.material.shader = null
				elif item == "sleek_blade_unlocked":
					# sleek blade check
					sleek_blade_unlocked = data["sleek_blade_unlocked"]
					if sleek_blade_unlocked:
						sleek_blade_button.material.shader = null
				elif item == "dash_boots_unlocked":
					# dash boots check
					dash_boots_unlocked = data["dash_boots_unlocked"]
					if dash_boots_unlocked:
						dash_boots_button.material.shader = null
				elif item == "poison_gas_unlocked":
					# poison gas check
					poison_gas_unlocked = data["poison_gas_unlocked"]
					if poison_gas_unlocked:
						poison_gas_button.material.shader = null
				elif item == "protective_charm_unlocked":
					# protective charm check
					protective_charm_unlocked = data["protective_charm_unlocked"]
					if protective_charm_unlocked:
						protective_charm_button.material.shader = null
				elif item == "rogue_in_a_bottle_unlocked":
					# rogue_in_a_bottle check
					rogue_in_a_bottle_unlocked = data["rogue_in_a_bottle_unlocked"]
					if rogue_in_a_bottle_unlocked:
						rogue_in_a_bottle_button.material.shader = null
				elif item == "hurtful_charm_unlocked":
					# hurtful charm check
					hurtful_charm_unlocked = data["hurtful_charm_unlocked"]
					if hurtful_charm_unlocked:
						hurtful_charm_button.material.shader = null
				elif item == "magically_trapped_rogue_unlocked":
					# magically_trapped_rogue check
					magically_trapped_rogue_unlocked = data["magically_trapped_rogue_unlocked"]
					if magically_trapped_rogue_unlocked:
						magically_trapped_rogue_button.material.shader = null
				elif item == "dead_rogues_head_unlocked":
					# dead_rogues_head check
					dead_rogues_head_unlocked = data["dead_rogues_head_unlocked"]
					if dead_rogues_head_unlocked:
						dead_rogues_head_button.material.shader = null
				elif item == "bomb_unlocked":
					# bomb check
					bomb_unlocked = data["bomb_unlocked"]
					if bomb_unlocked:
						bomb_button.material.shader = null
		save_items()

# goes through all the panels and hides all of them
func clear_panel():
	# enemy tab
	blue_slime_panel.hide()
	green_slime_panel.hide()
	earth_elemental_panel.hide()
	air_elemental_panel.hide()
	skeleton_warrior_panel.hide()
	skeleton_archer_panel.hide()
	skeleton_mage_panel.hide()
	shade_panel.hide()
	skeleton_panel.hide()
	
	# boss tab
	gelatinous_cube_panel.hide()
	forgotten_golem_panel.hide()
	lich_panel.hide()
	morphed_shade_panel.hide()
	
	# items tab
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
	holy_heart_panel.hide()
	poorly_made_voodoo_doll_panel.hide()
	sleek_blade_panel.hide()
	dash_boots_panel.hide()
	poison_gas_panel.hide()
	protective_charm_panel.hide()
	rogue_in_a_bottle_panel.hide()
	hurtful_charm_panel.hide()
	magically_trapped_rogue_panel.hide()
	dead_rogues_head_panel.hide()
	bomb_panel.hide()

## ---------------------------------- Enemies --------------------------------------------------------

# unlocks an enemy based on it's type
func unlock_enemy(enemy):
	# matches the enemy type
	if enemy == EnemyTypes.enemy.blue_slime:
		# if the enemy is locked
		if !blue_slime_unlocked:
			# remove the locked shader
			blue_slime_button.material.shader = null
			# set the enemy to be unlocked
			blue_slime_unlocked = true
		# increase the kill count and update the counts in the catalog
		blue_slime_kill_count += 1
	elif enemy == EnemyTypes.enemy.green_slime:
		# if the enemy is locked
		if !green_slime_unlocked:
			# remove the locked shader
			green_slime_button.material.shader = null
			# set the enemy to be unlocked
			green_slime_unlocked = true
		# increase the kill count and update the counts in the catalog
		green_slime_kill_count += 1
	elif enemy == EnemyTypes.enemy.gelatinous_cube:
		# if the enemy is locked
		if !gelatinous_cube_unlocked:
			# remove the locked shader
			gelatinous_cube_button.material.shader = null
			# set the enemy to be unlocked
			gelatinous_cube_unlocked = true
		# increase the kill count and update the counts in the catalog
		gelatinous_cube_kill_count += 1
	elif enemy == EnemyTypes.enemy.earth_elemental:
		# if the enemy is locked
		if !earth_elemental_unlocked:
			# remove the locked shader
			earth_elemental_button.material.shader = null
			# set the enemy to be unlocked
			earth_elemental_unlocked = true
		# increase the kill count and update the counts in the catalog
		earth_elemental_kill_count += 1
	elif enemy == EnemyTypes.enemy.air_elemental:
		# if the enemy is locked
		if !air_elemental_unlocked:
			# remove the locked shader
			air_elemental_button.material.shader = null
			# set the enemy to be unlocked
			air_elemental_unlocked = true
		# increase the kill count and update the counts in the catalog
		air_elemental_kill_count += 1
	elif enemy == EnemyTypes.enemy.forgotten_golem:
		# if the enemy is locked
		if !forgotten_golem_unlocked:
			# remove the locked shader
			forgotten_golem_button.material.shader = null
			# set the enemy to be unlocked
			forgotten_golem_unlocked = true
		# increase the kill count and update the counts in the catalog
		forgotten_golem_kill_count += 1
	elif enemy == EnemyTypes.enemy.skeleton_warrior:
		# if the enemy is locked
		if !skeleton_warrior_unlocked:
			# remove the locked shader
			skeleton_warrior_button.material.shader = null
			# set the enemy to be unlocked
			skeleton_warrior_unlocked = true
		# increase the kill count and update the counts in the catalog
		skeleton_warrior_kill_count += 1
	elif enemy == EnemyTypes.enemy.skeleton_archer:
		# if the enemy is locked
		if !skeleton_archer_unlocked:
			# remove the locked shader
			skeleton_archer_button.material.shader = null
			# set the enemy to be unlocked
			skeleton_archer_unlocked = true
		# increase the kill count and update the counts in the catalog
		skeleton_archer_kill_count += 1
	elif enemy == EnemyTypes.enemy.skeleton_mage:
		# if the enemy is locked
		if !skeleton_mage_unlocked:
			# remove the locked shader
			skeleton_mage_button.material.shader = null
			# set the enemy to be unlocked
			skeleton_mage_unlocked = true
		# increase the kill count and update the counts in the catalog
		skeleton_mage_kill_count += 1
	elif enemy == EnemyTypes.enemy.lich:
		# if the enemy is locked
		if !lich_unlocked:
			# remove the locked shader
			lich_button.material.shader = null
			# set the enemy to be unlocked
			lich_unlocked = true
		# increase the kill count and update the counts in the catalog
		lich_kill_count += 1
	elif enemy == EnemyTypes.enemy.shade:
		# if the enemy is locked
		if !shade_unlocked:
			# remove the locked shader
			shade_button.material.shader = null
			# set the enemy to be unlocked
			shade_unlocked = true
		# increase the kill count and update the counts in the catalog
		shade_kill_count += 1
	elif enemy == EnemyTypes.enemy.skeleton:
		# if the enemy is locked
		if !skeleton_unlocked:
			# remove the locked shader
			skeleton_button.material.shader = null
			# set the enemy to be unlocked
			skeleton_unlocked = true
		# increase the kill count and update the counts in the catalog
		skeleton_kill_count += 1
	elif enemy == EnemyTypes.enemy.morphed_shade:
		# if the enemy is locked
		if !morphed_shade_unlocked:
			# remove the locked shader
			morphed_shade_button.material.shader = null
			# set the enemy to be unlocked
			morphed_shade_unlocked = true
		# increase the kill count and update the counts in the catalog
		morphed_shade_kill_count += 1
	update_kill_counts()
	# saves the enemies to the catalog file
	save_enemies()

# checks what enemies have been found
func found_enemies():
	var data = {
		"blue_slime_unlocked" : blue_slime_unlocked,
		"blue_slime_kill_count": blue_slime_kill_count,
		"green_slime_unlocked" : green_slime_unlocked,
		"green_slime_kill_count" : green_slime_kill_count,
		"gelatinous_cube_unlocked" : gelatinous_cube_unlocked,
		"gelatinous_cube_kill_count" : gelatinous_cube_kill_count,
		"earth_elemental_unlocked" : earth_elemental_unlocked,
		"earth_elemental_kill_count" : earth_elemental_kill_count,
		"air_elemental_unlocked" : air_elemental_unlocked,
		"air_elemental_kill_count" : air_elemental_kill_count,
		"forgotten_golem_unlocked" : forgotten_golem_unlocked,
		"forgotten_golem_kill_count" : forgotten_golem_kill_count,
		"skeleton_warrior_unlocked" : skeleton_warrior_unlocked,
		"skeleton_warrior_kill_count" : skeleton_warrior_kill_count,
		"skeleton_archer_unlocked" : skeleton_archer_unlocked,
		"skeleton_archer_kill_count" : skeleton_archer_kill_count,
		"skeleton_mage_unlocked" : skeleton_mage_unlocked,
		"skeleton_mage_kill_count" : skeleton_mage_kill_count,
		"lich_unlocked" : lich_unlocked,
		"lich_kill_count" : lich_kill_count,
		"shade_unlocked" : shade_unlocked,
		"shade_kill_count" : shade_kill_count,
		"skeleton_unlocked" : skeleton_unlocked,
		"skeleton_kill_count" : skeleton_kill_count,
		"morphed_shade_unlocked" : morphed_shade_unlocked,
		"morphed_shade_kill_count" : morphed_shade_kill_count,
	}
	return data

# updates the kill counts in the catalog
func update_kill_counts():
	blue_slime_kill_count_label.text = "Killed: " + str(blue_slime_kill_count)
	green_slime_kill_count_label.text = "Killed: " + str(green_slime_kill_count)
	gel_cube_kill_count_label.text = "Killed: " + str(gelatinous_cube_kill_count)
	earth_elemental_kill_count_label.text = "Killed: " + str(earth_elemental_kill_count)
	air_elemental_kill_count_label.text = "Killed: " + str(air_elemental_kill_count)
	forgotten_golem_kill_count_label.text = "Killed: " + str(forgotten_golem_kill_count)
	skeleton_warrior_kill_count_label.text = "Killed: " + str(skeleton_warrior_kill_count)
	skeleton_archer_kill_count_label.text = "Killed: " + str(skeleton_archer_kill_count)
	skeleton_mage_kill_count_label.text = "Killed: " + str(skeleton_mage_kill_count)
	lich_kill_count_label.text = "Killed: " + str(lich_kill_count)
	shade_kill_count_label.text = "Killed: " + str(shade_kill_count)
	skeleton_kill_count_label.text = "Killed: " + str(skeleton_kill_count)
	morphed_shade_kill_count_label.text = "Killed: " + str(morphed_shade_kill_count)

# when the blue slime button is presed
func _on_blue_slime_pressed():
	# clear the info panel
	clear_panel()
	# if the enemy is unlocked
	if blue_slime_unlocked:
		# show the enemy's info panel
		blue_slime_panel.show()

# when the green slime button is presed
func _on_green_slime_pressed():
	# clear the info panel
	clear_panel()
	# if the enemy is unlocked
	if green_slime_unlocked:
		# show the enemy's info panel
		green_slime_panel.show()

# when the earth elemental button is presed
func _on_earth_elemental_button_pressed():
	# clear the info panel
	clear_panel()
	# if the enemy is unlocked
	if earth_elemental_unlocked:
		# show the enemy's info panel
		earth_elemental_panel.show()

# when the air elemental button is presed
func _on_air_elemental_button_pressed():
	# clear the info panel
	clear_panel()
	# if the enemy is unlocked
	if air_elemental_unlocked:
		# show the enemy's info panel
		air_elemental_panel.show()

# when the gelatinous cube button is presed
func _on_gelatinous_cube_button_pressed():
	# clear the info panel
	clear_panel()
	# if the enemy is unlocked
	if gelatinous_cube_unlocked:
		# show the enemy's info panel
		gelatinous_cube_panel.show()

# when the forgotten golem button is presed
func _on_forgotten_golem_pressed():
	# clear the info panel
	clear_panel()
	# if the enemy is unlocked
	if forgotten_golem_unlocked:
		# show the enemy's info panel
		forgotten_golem_panel.show()

# when the skeleton warrior cube button is presed
func _on_skeleton_warrior_button_pressed():
	# clear the info panel
	clear_panel()
	# if the enemy is unlocked
	if skeleton_warrior_unlocked:
		# show the enemy's info panel
		skeleton_warrior_panel.show()

# when the skeleton archer button is presed
func _on_skeleton_archer_button_pressed():
	# clear the info panel
	clear_panel()
	# if the enemy is unlocked
	if skeleton_archer_unlocked:
		# show the enemy's info panel
		skeleton_archer_panel.show()

# when the skeleton mage button is presed
func _on_skeleton_mage_button_pressed():
	# clear the info panel
	clear_panel()
	# if the enemy is unlocked
	if skeleton_mage_unlocked:
		# show the enemy's info panel
		skeleton_mage_panel.show()

# when the lich button is presed
func _on_lich_button_pressed():
	# clear the info panel
	clear_panel()
	# if the enemy is unlocked
	if lich_unlocked:
		# show the enemy's info panel
		lich_panel.show()

# when the shade button is presed
func _on_shade_button_pressed():
	# clear the info panel
	clear_panel()
	# if the enemy is unlocked
	if shade_unlocked:
		# show the enemy's info panel
		shade_panel.show()

# when the skeleton button is presed
func _on_skeleton_button_pressed():
	# clear the info panel
	clear_panel()
	# if the enemy is unlocked
	if skeleton_unlocked:
		# show the enemy's info panel
		skeleton_panel.show()

# when the morphed shade button is presed
func _on_morphed_shade_button_pressed():
	# clear the info panel
	clear_panel()
	# if the enemy is unlocked
	if morphed_shade_unlocked:
		# show the enemy's info panel
		morphed_shade_panel.show()

# saves the enemy found to "enemiesfound.save"
func save_enemies():
	var save_data = FileAccess.open("user://enemiesfound.save", FileAccess.WRITE)
	var json_string= JSON.stringify(found_enemies())
	save_data.store_line(json_string)

## ---------------------------------- Items --------------------------------------------------------

# unlocks an item based on it's type
func unlock_item(item):
	# matches the item type
	if item == ItemType.type.speed_boots:
		# if the item is locked
		if !speed_boots_unlocked:
			# remove the locked shader
			speed_boots_button.material.shader = null
			# set the item to be unlocked
			speed_boots_unlocked = true
	elif item == ItemType.type.dust_blade:
		# if the item is locked
		if !dust_blade_unlocked:
			# remove the locked shader
			dust_blade_button.material.shader = null
			# set the item to be unlocked
			dust_blade_unlocked = true
	elif item == ItemType.type.glass_blade:
		# if the item is locked
		if !glass_blade_unlocked:
			# remove the locked shader
			glass_blade_button.material.shader = null
			# set the item to be unlocked
			glass_blade_unlocked = true
	elif item == ItemType.type.health_1 || item == ItemType.type.health_2:
		# if the item is locked
		if !heart_unlocked:
			# remove the locked shader
			heart_button.material.shader = null
			# set the item to be unlocked
			heart_unlocked = true
	elif item == ItemType.type.key:
		# if the item is locked
		if !key_unlocked:
			# remove the locked shader
			key_button.material.shader = null
			# set the item to be unlocked
			key_unlocked = true
	elif item == ItemType.type.poisoned_blades:
		# if the item is locked
		if !poison_unlocked:
			# remove the locked shader
			poison_button.material.shader = null
			# set the item to be unlocked
			poison_unlocked = true
	elif item == ItemType.type.quick_blades:
		# if the item is locked
		if !quick_blades_unlocked:
			# remove the locked shader
			quick_blades_button.material.shader = null
			# set the item to be unlocked
			quick_blades_unlocked = true
	elif item == ItemType.type.shadow_blade:
		# if the item is locked
		if !shadow_blade_unlocked:
			# remove the locked shader
			shadow_blade_button.material.shader = null
			# set the item to be unlocked
			shadow_blade_unlocked = true
	elif item == ItemType.type.shadow_flame:
		# if the item is locked
		if !shadow_flame_unlocked:
			# remove the locked shader
			shadow_flame_button.material.shader = null
			# set the item to be unlocked
			shadow_flame_unlocked = true
	elif item == ItemType.type.shadow_heart:
		# if the item is locked
		if !shadow_heart_unlocked:
			# remove the locked shader
			shadow_heart_button.material.shader = null
			# set the item to be unlocked
			shadow_heart_unlocked = true
	elif item == ItemType.type.triple_blades:
		# if the item is locked
		if !triple_blades_unlocked:
			# remove the locked shader
			triple_blades_button.material.shader = null
			# set the item to be unlocked
			triple_blades_unlocked = true
	elif item == ItemType.type.holy_heart:
		# if the item is locked
		if !holy_heart_unlocked:
			# remove the locked shader
			holy_heart_button.material.shader = null
			# set the item to be unlocked
			holy_heart_unlocked = true
	elif item == ItemType.type.poorly_made_voodoo_doll:
		# if the item is locked
		if !poorly_made_voodoo_doll_unlocked:
			# remove the locked shader
			poorly_made_voodoo_doll_button.material.shader = null
			# set the item to be unlocked
			poorly_made_voodoo_doll_unlocked = true
	elif item == ItemType.type.sleek_blades:
		# if the item is locked
		if !sleek_blade_unlocked:
			# remove the locked shader
			sleek_blade_button.material.shader = null
			# set the item to be unlocked
			sleek_blade_unlocked = true
	elif item == ItemType.type.dash_boots:
		# if the item is locked
		if !dash_boots_unlocked:
			# remove the locked shader
			dash_boots_button.material.shader = null
			# set the item to be unlocked
			dash_boots_unlocked = true
	elif item == ItemType.type.poison_gas:
		# if the item is locked
		if !poison_gas_unlocked:
			# remove the locked shader
			poison_gas_button.material.shader = null
			# set the item to be unlocked
			poison_gas_unlocked = true
	elif item == ItemType.type.protective_charm:
		# if the item is locked
		if !protective_charm_unlocked:
			# remove the locked shader
			protective_charm_button.material.shader = null
			# set the item to be unlocked
			protective_charm_unlocked = true
	elif item == ItemType.type.rogue_in_a_bottle:
		# if the item is locked
		if !rogue_in_a_bottle_unlocked:
			# remove the locked shader
			rogue_in_a_bottle_button.material.shader = null
			# set the item to be unlocked
			rogue_in_a_bottle_unlocked = true
	elif item == ItemType.type.hurtful_charm:
		# if the item is locked
		if !hurtful_charm_unlocked:
			# remove the locked shader
			hurtful_charm_button.material.shader = null
			# set the item to be unlocked
			hurtful_charm_unlocked = true
	elif item == ItemType.type.magically_trapped_rogue:
		# if the item is locked
		if !magically_trapped_rogue_unlocked:
			# remove the locked shader
			magically_trapped_rogue_button.material.shader = null
			# set the item to be unlocked
			magically_trapped_rogue_unlocked = true
	elif item == ItemType.type.dead_rogues_head:
		# if the item is locked
		if !dead_rogues_head_unlocked:
			# remove the locked shader
			dead_rogues_head_button.material.shader = null
			# set the item to be unlocked
			dead_rogues_head_unlocked = true
	elif item == ItemType.type.bomb:
		# if the item is locked
		if !bomb_unlocked:
			# remove the locked shader
			bomb_button.material.shader = null
			# set the item to be unlocked
			bomb_unlocked = true
	save_items()

# saves the items found to "itemsfound.save"
func save_items():
	var save_data = FileAccess.open("user://itemsfound.save", FileAccess.WRITE)
	var json_string= JSON.stringify(found_items())
	save_data.store_line(json_string)

# checks what items have been found
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
		"holy_heart_unlocked"  : holy_heart_unlocked,
		"poorly_made_voodoo_doll_unlocked"  : poorly_made_voodoo_doll_unlocked,
		"sleek_blade_unlocked" : sleek_blade_unlocked,
		"dash_boots_unlocked" : dash_boots_unlocked,
		"poison_gas_unlocked" : poison_gas_unlocked,
		"protective_charm_unlocked" : protective_charm_unlocked,
		"rogue_in_a_bottle_unlocked" : rogue_in_a_bottle_unlocked,
		"hurtful_charm_unlocked" : hurtful_charm_unlocked,
		"magically_trapped_rogue_unlocked" : magically_trapped_rogue_unlocked,
		"dead_rogues_head_unlocked" : dead_rogues_head_unlocked,
		"bomb_unlocked" : bomb_unlocked,
	}
	return data

# when the boots button is pressed
func _on_boots_button_pressed():
	# clear the into panel
	clear_panel()
	# if the item is unlocked
	if speed_boots_unlocked:
		# show the item's info panel
		speed_boots_panel.show()

# when the dust blade button is pressed
func _on_dust_blade_button_pressed():
	# clear the into panel
	clear_panel()
	# if the item is unlocked
	if dust_blade_unlocked:
		# show the item's info panel
		dust_blade_panel.show()

# when the glass blade button is pressed
func _on_glass_blade_button_pressed():
	# clear the into panel
	clear_panel()
	# if the item is unlocked
	if glass_blade_unlocked:
		# show the item's info panel
		glass_blade_panel.show()

# when the heart button is pressed
func _on_heart_button_pressed():
	# clear the into panel
	clear_panel()
	# if the item is unlocked
	if heart_unlocked:
		# show the item's info panel
		heart_panel.show()

# when the key button is pressed
func _on_key_button_pressed():
	# clear the into panel
	clear_panel()
	# if the item is unlocked
	if key_unlocked:
		# show the item's info panel
		key_panel.show()

# when the poison blade button is pressed
func _on_poison_button_pressed():
	# clear the into panel
	clear_panel()
	# if the item is unlocked
	if poison_unlocked:
		# show the item's info panel
		poison_panel.show()

# when the quick blades button is pressed
func _on_quick_blades_button_pressed():
	# clear the into panel
	clear_panel()
	# if the item is unlocked
	if quick_blades_unlocked:
		# show the item's info panel
		quick_blades_panel.show()

# when the shadow blade button is pressed
func _on_shadow_blade_button_pressed():
	# clear the into panel
	clear_panel()
	# if the item is unlocked
	if shadow_blade_unlocked:
		# show the item's info panel
		shadow_blade_panel.show()

# when the shadow flame blade button is pressed
func _on_shadow_flame_button_pressed():
	# clear the into panel
	clear_panel()
	# if the item is unlocked
	if shadow_flame_unlocked:
		# show the item's info panel
		shadow_flame_panel.show()

# when the shadow heart button is pressed
func _on_shadow_heart_button_pressed():
	# clear the into panel
	clear_panel()
	# if the item is unlocked
	if shadow_heart_unlocked:
		# show the item's info panel
		shadow_heart_panel.show()

# when the triple blades button is pressed
func _on_triple_blades_button_pressed():
	# clear the into panel
	clear_panel()
	# if the item is unlocked
	if triple_blades_unlocked:
		# show the item's info panel
		triple_blades_panel.show()

# when the holy heart button is pressed
func _on_holy_heart_button_pressed():
	# clear the into panel
	clear_panel()
	# if the item is unlocked
	if holy_heart_unlocked:
		# show the item's info panel
		holy_heart_panel.show()

# when the poorly_made_voodoo button is pressed
func _on_poorly_made_voodoo_doll_button_pressed():
	# clear the into panel
	clear_panel()
	# if the item is unlocked
	if poorly_made_voodoo_doll_unlocked:
		# show the item's info panel
		poorly_made_voodoo_doll_panel.show()

# when the sleek blade button is pressed
func _on_sleek_blade_button_pressed():
	# clear the into panel
	clear_panel()
	# if the item is unlocked
	if sleek_blade_unlocked:
		# show the item's info panel
		sleek_blade_panel.show()

# when the dash boots button is pressed
func _on_dash_boots_button_pressed():
	# clear the into panel
	clear_panel()
	# if the item is unlocked
	if dash_boots_unlocked:
		# show the item's info panel
		dash_boots_panel.show()

# when the poison gas button is pressed
func _on_poison_gas_button_pressed():
	# clear the into panel
	clear_panel()
	# if the item is unlocked
	if poison_gas_unlocked:
		# show the item's info panel
		poison_gas_panel.show()

# when the protective charm button is pressed
func _on_protective_charm_button_pressed():
	# clear the into panel
	clear_panel()
	# if the item is unlocked
	if protective_charm_unlocked:
		# show the item's info panel
		protective_charm_panel.show()

# when the progue_in_a_bottle button is pressed
func _on_rogue_in_a_bottle_button_pressed():
	# clear the into panel
	clear_panel()
	# if the item is unlocked
	if rogue_in_a_bottle_unlocked:
		# show the item's info panel
		rogue_in_a_bottle_panel.show()

# when the hurtful charm button is pressed
func _on_hurtful_charm_button_pressed():
	# clear the into panel
	clear_panel()
	# if the item is unlocked
	if hurtful_charm_unlocked:
		# show the item's info panel
		hurtful_charm_panel.show()

# when the magically_trapped_rogue button is pressed
func _on_magically_trapped_rogue_button_pressed():
	# clear the into panel
	clear_panel()
	# if the item is unlocked
	if magically_trapped_rogue_unlocked:
		# show the item's info panel
		magically_trapped_rogue_panel.show()

# when the dead_rogues_head button is pressed
func _on_dead_rogues_head_button_pressed():
	# clear the into panel
	clear_panel()
	# if the item is unlocked
	if dead_rogues_head_unlocked:
		# show the item's info panel
		dead_rogues_head_panel.show()

# when bomb button is pressed
func _on_bomb_button_pressed():
	# clear the into panel
	clear_panel()
	# if the item is unlocked
	if bomb_unlocked:
		# show the item's info panel
		bomb_panel.show()
