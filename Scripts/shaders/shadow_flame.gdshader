shader_type canvas_item;

void fragment() {
	vec4 starting_color = texture(TEXTURE, UV);
	float blue_red_add = 0.5;
	// adjust the color
	vec4 new_color = vec4(starting_color.r + 0.2, starting_color.g +0.2, starting_color.b + 0.5, starting_color.a);
	// sets the new color
	COLOR = new_color;
}
