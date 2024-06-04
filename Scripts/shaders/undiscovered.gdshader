shader_type canvas_item;

void fragment() {
	// gets starting color
	vec4 starting_color = texture(TEXTURE, UV);
	// adjust the color
	vec4 new_color = vec4(69.0/255.0, 69.0/255.0, 69.0/255.0, starting_color.a - 0.2);
	// sets the new color
	COLOR = new_color;
}