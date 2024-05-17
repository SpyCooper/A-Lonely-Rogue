shader_type canvas_item;


void fragment() {
	vec4 starting_color = texture(TEXTURE, UV);
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
	COLOR = new_color;
}
