extends Node2D

# object references
@onready var fade_color = $CanvasLayer/Fade_color
@onready var animation_player = $CanvasLayer/Fade_color/AnimationPlayer
@onready var fade_timer = $CanvasLayer/Fade_color/Fade_timer
@onready var bg_music = $"BG music"

@onready var health_gained = $"CanvasLayer/Text and stats/Stats/Health Gained"
@onready var damage_taken = $"CanvasLayer/Text and stats/Stats/DamageTaken"
@onready var items_used_icons = $"CanvasLayer/Text and stats/Items_used_icons"
const LARGER_ITEM_UI_SLOT = preload("res://Scenes/menus/larger_item_ui_slot.tscn")
@onready var no_items_used_text = $"CanvasLayer/Text and stats/Stats/no_Items_used_text"

# variables
var fade_in = true
var next_floor

# on start
func _ready():
	# plays the fade in effect at the start of each floor
	fade_color.show()
	animation_player.play("fade_in")
	fade_timer.start()
	# load the player's stats for this run
	load_stats()

# when the fade timer ends
func _on_fade_timer_timeout():
	# if fade in is true, hide the fade color
	if fade_in:
		fade_color.hide()
		fade_in = false

# plays the background music on the floor
func play_bg_music():
	bg_music.play()

func _on_replay_button_pressed():
	Engine.time_scale = 1.0
	PlayerData.clear_data()
	PlayerData.clear_run_data()
	get_tree().change_scene_to_file("res://Scenes/Dungeon_floors/dungeon_floor_1.tscn")

func _on_main_menu_button_pressed():
	Engine.time_scale = 1.0
	PlayerData.clear_run_data()
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

# loads the player's stats
func load_stats():
	# sets the health gained
	health_gained.text = "Health Gained: " + str(PlayerData.health_healed)
	# sets the damage taken
	damage_taken.text = "Damage Taken: " + str(PlayerData.damage_taken)
	# sets the items used
	for item in PlayerData.items_used:
		# create a item UI slot
		var item_ui = LARGER_ITEM_UI_SLOT.instantiate()
		# add it to the items collected container
		items_used_icons.add_child(item_ui)
		# matches the item type and sets the graphic to the item
		if item == ItemType.type.poisoned_blades:
			item_ui.get_animated_sprite().play("Poison")
		elif item == ItemType.type.speed_boots:
			item_ui.get_animated_sprite().play("Speed_boots")
		elif item == ItemType.type.quick_blades:
			item_ui.get_animated_sprite().play("Quick_blades")
		elif item == ItemType.type.shadow_flame:
			item_ui.get_animated_sprite().play("Shadow_flame")
		elif item == ItemType.type.shadow_blade:
			item_ui.get_animated_sprite().play("Shadow_blade")
		elif item == ItemType.type.triple_blades:
			item_ui.get_animated_sprite().play("Triple_blades")
		elif item == ItemType.type.dust_blade:
			item_ui.get_animated_sprite().play("Dust_blade")
		elif item == ItemType.type.glass_blade:
			item_ui.get_animated_sprite().play("glass_blade")
		elif item == ItemType.type.poorly_made_voodoo_doll:
			item_ui.get_animated_sprite().play("poorly_made_voodoo")
		elif item == ItemType.type.sleek_blades:
			item_ui.get_animated_sprite().play("sleek_blade")
		elif item == ItemType.type.protective_charm:
			item_ui.get_animated_sprite().play("protective_charm")
		elif item == ItemType.type.hurtful_charm:
			item_ui.get_animated_sprite().play("hurtful_charm")
		elif item == ItemType.type.magically_trapped_rogue:
			item_ui.get_animated_sprite().play("magically_trapped_rogue")
		elif item == ItemType.type.dead_rogues_head:
			item_ui.get_animated_sprite().play("dead_rogues_head")
		elif item == ItemType.type.dash_boots:
			item_ui.get_animated_sprite().play("dash_boots")
		elif item == ItemType.type.poison_gas:
			item_ui.get_animated_sprite().play("poison_gas")
		elif item == ItemType.type.rogue_in_a_bottle:
			item_ui.get_animated_sprite().play("rogue_in_a_bottle")
		elif item == ItemType.type.bomb:
			item_ui.get_animated_sprite().play("bomb")
	# if no items were used, show the no items used text
	if PlayerData.items_used.size() == 0:
		no_items_used_text.show()
