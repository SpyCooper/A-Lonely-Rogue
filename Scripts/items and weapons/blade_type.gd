extends Node

enum blade_type
{
	default,
	posioned,
	shadow,
	glass,
	shadow_flame,
	dust,
}

@export var current_blade_type = blade_type.default
