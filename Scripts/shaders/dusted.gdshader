shader_type canvas_item;

void fragment() {
	// gets starting color
	vec4 starting_color = texture(TEXTURE, UV);
	// adjust the color
	vec4 new_color = vec4(starting_color.r + 88.0/255.0, starting_color.g + 64.0/255.0, starting_color.b + 38.0/255.0, starting_color.a);
	// checks if the color is from a shadow
	vec4 shadow_color = vec4(23.0/255.0, 14.0/255.0, 25.0/255.0, 149.0/255.0);
	if (starting_color == shadow_color)
	{
		new_color = shadow_color;
	}
	// sets the new color
	COLOR = new_color;
}
