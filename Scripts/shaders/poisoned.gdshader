shader_type canvas_item;

void fragment() {
	// gets starting color
	vec4 starting_color = texture(TEXTURE, UV);
	// adjust the color
	float green_add = 0.3;
	vec4 new_color = vec4(0, 0, 0, 0);
	if (starting_color.g + green_add != 1.0)
	{
		new_color = vec4(starting_color.r, starting_color.g + green_add, starting_color.b+0.1, starting_color.a);
	}
	else
	{
		new_color = vec4(starting_color.r, 1.0, starting_color.b, starting_color.a);
	}
	// sets the new color
	COLOR = new_color;
}
