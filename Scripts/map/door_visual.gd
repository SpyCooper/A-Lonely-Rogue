extends TileMap


@export var locked = false

func is_locked():
	return locked

func unlock():
	locked = false

func lock():
	locked = true
