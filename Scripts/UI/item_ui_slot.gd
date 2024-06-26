extends Control

# object references
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var grey_out_sprite = $GreyOut_sprite
@onready var cooldown_label = $GreyOut_sprite/cooldown_Label
@onready var stack_label = $stack_Label

var item_type : ItemType.type

# variables
var timer = 0.0

# on start
func _ready():
	# hide the cooldown
	hide_cooldown()
	# set the stack amount
	adjust_stack(1)

func set_item_type(item: ItemType.type):
	item_type = item

func get_item_type():
	return item_type

# every frame
func _process(delta):
	# if the timer is greater than 0
	if timer > 0:
		# remove time from timer
		timer -= delta
		# set the cooldown label
		cooldown_label.text = str("%1.1f" % timer)
		# if the timer is now over
		if timer <= 0:
			# hide the cooldown
			hide_cooldown()

# return the animated sprite
func get_animated_sprite():
	return animated_sprite_2d

# shows the cooldown timer for the timer
func show_cooldown_timer(time):
	# sets the timer
	timer = time
	# show the greyed out sprite
	grey_out_sprite.show()
	# show the timer
	cooldown_label.show()
	cooldown_label.text = str("%1.1f" % timer)

 # hides the cooldown
func hide_cooldown():
	# hide the greyed out sprite
	grey_out_sprite.hide()
	# reset the label and hide the timer
	cooldown_label.text = str("%1.1f" % 0.0)
	cooldown_label.hide()

func adjust_stack(stack_amount : int):
	if stack_amount <= 1:
		stack_label.hide()
	else:
		stack_label.show()
		stack_label.text = str(stack_amount)
