shader_type canvas_item;

uniform sampler2D noise_texture: repeat_enable, filter_nearest;

void fragment()
{
	vec2 uv = UV + vec2(0.2, 0.1) * TIME;
	float noise = texture(noise_texture, uv).r;
	vec4 base = texture(TEXTURE, UV);
  	base.a *= noise;
	COLOR = base;
}
