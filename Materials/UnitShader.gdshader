shader_type canvas_item;

uniform float whiteness = 0.0;

void fragment() {
  vec4 texture_color = texture(TEXTURE, UV);
  COLOR = texture_color + texture_color * whiteness;
 }