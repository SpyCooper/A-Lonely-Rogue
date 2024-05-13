extends Control

@onready var heart_1 = $Heart_1
@onready var heart_2 = $Heart_2
@onready var heart_3 = $Heart_3
@onready var heart_4 = $Heart_4
@onready var heart_5 = $Heart_5

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func refresh_hearts(health):
	if health == 6:
		heart_1.play("full_heart")
		heart_2.play("full_heart")
		heart_3.play("full_heart")
		heart_4.hide()
		heart_5.hide()
	elif health == 5:
		heart_1.play("full_heart")
		heart_2.play("full_heart")
		heart_3.play("half_heart")
		heart_4.hide()
		heart_5.hide()
	elif health == 4:
		heart_1.play("full_heart")
		heart_2.play("full_heart")
		heart_3.hide()
		heart_4.hide()
		heart_5.hide()
	elif health == 3:
		heart_1.play("full_heart")
		heart_2.play("half_heart")
		heart_3.hide()
		heart_4.hide()
		heart_5.hide()
	elif health == 2:
		heart_1.play("full_heart")
		heart_2.hide()
		heart_3.hide()
		heart_4.hide()
		heart_5.hide()
	elif health == 1:
		heart_1.play("half_heart")
		heart_2.hide()
		heart_3.hide()
		heart_4.hide()
		heart_5.hide()
	else:
		heart_1.hide()
		heart_2.hide()
		heart_3.hide()
		heart_4.hide()
		heart_5.hide()
