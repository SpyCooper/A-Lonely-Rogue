extends TileMap

# sets the locked status
@export var locked = false

# return the locked status
func is_locked():
	return locked

# unlock the door
func unlock():
	locked = false

# lock the door
func lock():
	locked = true
