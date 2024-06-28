shader_type canvas_item;

void fragment() {
	vec4 starting_color = texture(TEXTURE, UV);
	float blue_red_add = 0.5;
	// adjust the color
	vec4 new_color = vec4(starting_color.r + 0.2, starting_color.g +0.2, starting_color.b + 0.5, starting_color.a);
	// checks if the color is from a shadow
	vec4 shadow_color = vec4(23.0/255.0, 14.0/255.0, 25.0/255.0, 149.0/255.0);
	if (starting_color == shadow_color)
	{
		new_color = shadow_color;
	}
	// sets the new color
	COLOR = new_color;
}
