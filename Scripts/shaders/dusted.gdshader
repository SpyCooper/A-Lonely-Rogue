shader_type canvas_item;


void fragment() {
	vec4 starting_color = texture(TEXTURE, UV);
	vec4 new_color = vec4(starting_color.r + 108.0/255.0, starting_color.g + 74.0/255.0, starting_color.b + 58.0/255.0, starting_color.a-0.1);
	COLOR = new_color;
}
