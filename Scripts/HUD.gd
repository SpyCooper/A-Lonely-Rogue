extends Control

class_name HUD

# heart UI references
@onready var heart_1 = $Hearts_UI/Heart_1
@onready var heart_2 = $Hearts_UI/Heart_2
@onready var heart_3 = $Hearts_UI/Heart_3
@onready var heart_4 = $Hearts_UI/Heart_4
@onready var heart_5 = $Hearts_UI/Heart_5

# scroll text UI references
@onready var text_box = $ScrollTextBox
@onready var main_text_box = $"ScrollTextBox/Main Text"
@onready var subtext_box = $ScrollTextBox/Subtext
@onready var text_box_timer = $TextBoxTimer
@onready var animation_player = $ScrollTextBox/AnimationPlayer

# boss HP bar UI references
@onready var health_bar = $HealthBar
@onready var boss_name_label = $HealthBar/Boss_name

# key UI reference
@onready var key_amount_label = $Keys_UI/Key_amount_label

# items collected UI references
@onready var items_ui_container = $active_items_ui/items_ui_container
const ITEM_UI_SLOT = preload("res://Scenes/item_ui_slot.tscn")

# on start
func _ready():
	# hide hearts 4 and 5
	heart_4.play("no_heart")
	heart_5.play("no_heart")
	# hide the boss health bar
	hide_health_bar()
	# hide the scroll text box
	hide_text()
	# reset the scroll text animation
	animation_player.play("RESET")

# show the corresponding hearts to the players HP and if the player collected a shadow heart
func refresh_hearts(health, shadow_heart = false):
	if health == 0:
		heart_1.play("no_heart")
		heart_2.play("no_heart")
		heart_3.play("no_heart")
		heart_4.play("no_heart")
		heart_5.play("no_heart")
	elif health == 1:
		if shadow_heart == true:
			heart_1.play("shadow_half")
		else:
			heart_1.play("half_heart")
		heart_2.play("no_heart")
		heart_3.play("no_heart")
		heart_4.play("no_heart")
		heart_5.play("no_heart")
	elif health == 2:
		if shadow_heart == true:
			heart_1.play("shadow_full")
		else:
			heart_1.play("full_heart")
		heart_2.play("no_heart")
		heart_3.play("no_heart")
		heart_4.play("no_heart")
		heart_5.play("no_heart")
	elif health == 3:
		if shadow_heart == true:
			heart_1.play("shadow_full")
			heart_2.play("shadow_half")
		else:
			heart_1.play("full_heart")
			heart_2.play("half_heart")
		heart_3.play("no_heart")
		heart_4.play("no_heart")
		heart_5.play("no_heart")
	elif health == 4:
		if shadow_heart == true:
			heart_1.play("shadow_full")
			heart_2.play("shadow_full")
		else:
			heart_1.play("full_heart")
			heart_2.play("full_heart")
		heart_3.play("no_heart")
		heart_4.play("no_heart")
		heart_5.play("no_heart")
	elif health == 5:
		if shadow_heart == true:
			heart_1.play("shadow_full")
			heart_2.play("shadow_full")
			heart_3.play("shadow_half")
		else:
			heart_1.play("full_heart")
			heart_2.play("full_heart")
			heart_3.play("half_heart")
		heart_4.play("no_heart")
		heart_5.play("no_heart")
	elif health == 6:
		if shadow_heart == true:
			heart_1.play("shadow_full")
			heart_2.play("shadow_full")
			heart_3.play("shadow_full")
		else:
			heart_1.play("full_heart")
			heart_2.play("full_heart")
			heart_3.play("full_heart")
		heart_4.play("no_heart")
		heart_5.play("no_heart")
	elif health == 7:
		if shadow_heart == true:
			heart_1.play("shadow_full")
			heart_2.play("shadow_full")
			heart_3.play("shadow_full")
			heart_4.play("shadow_half")
		else:
			heart_1.play("full_heart")
			heart_2.play("full_heart")
			heart_3.play("full_heart")
			heart_4.play("half_heart")
		heart_5.play("no_heart")
	elif health == 8:
		if shadow_heart == true:
			heart_1.play("shadow_full")
			heart_2.play("shadow_full")
			heart_3.play("shadow_full")
			heart_4.play("shadow_full")
		else:
			heart_1.play("full_heart")
			heart_2.play("full_heart")
			heart_3.play("full_heart")
			heart_4.play("full_heart")
		heart_5.play("no_heart")
	elif health == 9:
		if shadow_heart == true:
			heart_1.play("shadow_full")
			heart_2.play("shadow_full")
			heart_3.play("shadow_full")
			heart_4.play("shadow_full")
			heart_5.play("shadow_half")
		else:
			heart_1.play("full_heart")
			heart_2.play("full_heart")
			heart_3.play("full_heart")
			heart_4.play("full_heart")
			heart_5.play("half_heart")
	elif health == 10:
		if shadow_heart == true:
			heart_1.play("shadow_full")
			heart_2.play("shadow_full")
			heart_3.play("shadow_full")
			heart_4.play("shadow_full")
			heart_5.play("shadow_full")
		else:
			heart_1.play("full_heart")
			heart_2.play("full_heart")
			heart_3.play("full_heart")
			heart_4.play("full_heart")
			heart_5.play("full_heart")

# hides the player's hearts
func hide_player_health():
	heart_1.hide()
	heart_2.hide()
	heart_3.hide()
	heart_4.hide()
	heart_5.hide()

# shows the player's hearts
func show_player_health():
	heart_1.show()
	heart_2.show()
	heart_3.show()
	heart_4.show()
	heart_5.show()

# shows the scroll text with the main text and the subtext
func display_text(main_text, sub_text):
	text_box.show()
	main_text_box.text = str(main_text)
	subtext_box.text = str(sub_text)
	animation_player.play("Enter")
	# starts the text box timer
	text_box_timer.start(3)

# hides the scroll text
func hide_text():
	text_box.hide()
	
# when the text box timer stops
func _on_text_box_timer_timeout():
	# start the leave animation and stop the timer
	animation_player.play("Leave")
	text_box_timer.stop()

# sets and shows the boss' HP bar
func set_health_bar(max_health, boss_name):
	health_bar.show()
	health_bar.max_value = max_health
	health_bar.value = max_health
	boss_name_label.text = str(boss_name)

# sets the current HP of the boss' health bar
func adjust_health_bar(current_health):
	health_bar.value = current_health

# hides the boss' health bar
func hide_health_bar():
	health_bar.hide()

# shows the starting text for floor 1
func show_starting_text():
	show_player_health()
	display_text("Find a way out ...", "Who knows what's down here")

# changes the key amount to match the key amount inputted
func refresh_key_amount(key_amount):
	key_amount_label.text = str(key_amount)

# adds an item to the collected item UI
func item_added(item):
	# matches the item type
	if item == ItemType.type.poisoned_blades:
		# create a item UI slot
		var item_ui = ITEM_UI_SLOT.instantiate()
		# add it to the items collected container
		items_ui_container.add_child(item_ui)
		# set the graphic to the item
		item_ui.get_animated_sprite().play("Poison")
	elif item == ItemType.type.speed_boots:
		# create a item UI slot
		var item_ui = ITEM_UI_SLOT.instantiate()
		# add it to the items collected container
		items_ui_container.add_child(item_ui)
		# set the graphic to the item
		item_ui.get_animated_sprite().play("Speed_boots")
	elif item == ItemType.type.quick_blades:
		# create a item UI slot
		var item_ui = ITEM_UI_SLOT.instantiate()
		# add it to the items collected container
		items_ui_container.add_child(item_ui)
		# set the graphic to the item
		item_ui.get_animated_sprite().play("Quick_blades")
	elif item == ItemType.type.shadow_flame:
		# create a item UI slot
		var item_ui = ITEM_UI_SLOT.instantiate()
		# add it to the items collected container
		items_ui_container.add_child(item_ui)
		# set the graphic to the item
		item_ui.get_animated_sprite().play("Shadow_flame")
	elif item == ItemType.type.shadow_blade:
		# create a item UI slot
		var item_ui = ITEM_UI_SLOT.instantiate()
		# add it to the items collected container
		items_ui_container.add_child(item_ui)
		# set the graphic to the item
		item_ui.get_animated_sprite().play("Shadow_blade")
	elif item == ItemType.type.triple_blades:
		# create a item UI slot
		var item_ui = ITEM_UI_SLOT.instantiate()
		# add it to the items collected container
		items_ui_container.add_child(item_ui)
		# set the graphic to the item
		item_ui.get_animated_sprite().play("Triple_blades")
	elif item == ItemType.type.dust_blade:
		# create a item UI slot
		var item_ui = ITEM_UI_SLOT.instantiate()
		# add it to the items collected container
		items_ui_container.add_child(item_ui)
		# set the graphic to the item
		item_ui.get_animated_sprite().play("Dust_blade")
	elif item == ItemType.type.glass_blade:
		# create a item UI slot
		var item_ui = ITEM_UI_SLOT.instantiate()
		# add it to the items collected container
		items_ui_container.add_child(item_ui)
		# set the graphic to the item
		item_ui.get_animated_sprite().play("glass_blade")
