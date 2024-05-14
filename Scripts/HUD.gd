extends Control

@onready var heart_1 = $Heart_1
@onready var heart_2 = $Heart_2
@onready var heart_3 = $Heart_3
@onready var heart_4 = $Heart_4
@onready var heart_5 = $Heart_5

func _ready():
	heart_4.play("no_heart")
	heart_5.play("no_heart")

func refresh_hearts(health):
	if health == 0:
		heart_1.play("no_heart")
		heart_2.play("no_heart")
		heart_3.play("no_heart")
		heart_4.play("no_heart")
		heart_5.play("no_heart")
	elif health == 1:
		heart_1.play("half_heart")
		heart_2.play("no_heart")
		heart_3.play("no_heart")
		heart_4.play("no_heart")
		heart_5.play("no_heart")
	elif health == 2:
		heart_1.play("full_heart")
		heart_2.play("no_heart")
		heart_3.play("no_heart")
		heart_4.play("no_heart")
		heart_5.play("no_heart")
	elif health == 3:
		heart_1.play("full_heart")
		heart_2.play("half_heart")
		heart_3.play("no_heart")
		heart_4.play("no_heart")
		heart_5.play("no_heart")
	elif health == 4:
		heart_1.play("full_heart")
		heart_2.play("full_heart")
		heart_3.play("no_heart")
		heart_4.play("no_heart")
		heart_5.play("no_heart")
	elif health == 5:
		heart_1.play("full_heart")
		heart_2.play("full_heart")
		heart_3.play("half_heart")
		heart_4.play("no_heart")
		heart_5.play("no_heart")
	elif health == 6:
		heart_1.play("full_heart")
		heart_2.play("full_heart")
		heart_3.play("full_heart")
		heart_4.play("no_heart")
		heart_5.play("no_heart")
	elif health == 7:
		heart_1.play("full_heart")
		heart_2.play("full_heart")
		heart_3.play("full_heart")
		heart_4.play("half_heart")
		heart_5.play("no_heart")
	elif health == 8:
		heart_1.play("full_heart")
		heart_2.play("full_heart")
		heart_3.play("full_heart")
		heart_4.play("full_heart")
		heart_5.play("no_heart")
	elif health == 9:
		heart_1.play("full_heart")
		heart_2.play("full_heart")
		heart_3.play("full_heart")
		heart_4.play("full_heart")
		heart_5.play("half_heart")
	elif health == 10:
		heart_1.play("full_heart")
		heart_2.play("full_heart")
		heart_3.play("full_heart")
		heart_4.play("full_heart")
		heart_5.play("full_heart")
