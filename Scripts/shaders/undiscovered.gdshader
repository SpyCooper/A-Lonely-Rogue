shader_type canvas_item;

void fragment() {
	vec4 starting_color = texture(TEXTURE, UV);
	vec4 new_color = vec4(69.0/255.0, 69.0/255.0, 69.0/255.0, starting_color.a - 0.2);
	COLOR = new_color;
}