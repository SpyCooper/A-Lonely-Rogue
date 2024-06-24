extends Node

# declares the blade types
enum blade_type
{
	default,
	posioned,
	shadow,
	glass,
	shadow_flame,
	dust,
	sleek,
}

# sets the current_blade_type to default
@export var current_blade_type = blade_type.default
