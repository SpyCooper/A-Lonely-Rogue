shader_type canvas_item;

void fragment() {
	// gets starting color
	vec4 starting_color = texture(TEXTURE, UV);
	// adjust the color
	vec4 new_color = vec4(starting_color.r + 88.0/255.0, starting_color.g + 64.0/255.0, starting_color.b + 38.0/255.0, starting_color.a);
	// sets the new color
	COLOR = new_color;
}
