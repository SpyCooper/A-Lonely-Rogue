extends Control

class_name HUD

@onready var heart_1 = $Heart_1
@onready var heart_2 = $Heart_2
@onready var heart_3 = $Heart_3
@onready var heart_4 = $Heart_4
@onready var heart_5 = $Heart_5

@onready var text_box = $ScrollTextBox
@onready var main_text_box = $"ScrollTextBox/Main Text"
@onready var subtext_box = $ScrollTextBox/Subtext
@onready var text_box_timer = $TextBoxTimer
@onready var animation_player = $ScrollTextBox/AnimationPlayer

@onready var health_bar = $HealthBar
@onready var boss_name_label = $HealthBar/Boss_name

func _ready():
	heart_4.play("no_heart")
	heart_5.play("no_heart")
	hide_health_bar()
	hide_text()
	hide_player_health()
	animation_player.play("RESET")

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

func hide_player_health():
	heart_1.hide()
	heart_2.hide()
	heart_3.hide()
	heart_4.hide()
	heart_5.hide()

func show_player_health():
	heart_1.show()
	heart_2.show()
	heart_3.show()
	heart_4.show()
	heart_5.show()

func display_text(main_text, sub_text):
	text_box.show()
	main_text_box.text = str(main_text)
	subtext_box.text = str(sub_text)
	animation_player.play("Enter")
	text_box_timer.start(3)

func hide_text():
	text_box.hide()

func _on_text_box_timer_timeout():
	animation_player.play("Leave")
	text_box_timer.stop()

func set_health_bar(max_health, boss_name):
	health_bar.show()
	health_bar.max_value = max_health
	health_bar.value = max_health
	boss_name_label.text = str(boss_name)

func adjust_health_bar(current_health):
	health_bar.value = current_health

func hide_health_bar():
	health_bar.hide()

func show_starting_text():
	show_player_health()
	display_text("Find a way out ...", "Who knows what's down here")
