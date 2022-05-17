shader_type canvas_item;

uniform float calculatedOffset = 0;

void fragment() {
    vec2 screen_uv = SCREEN_UV;
    screen_uv.y = 1. - screen_uv.y;
    screen_uv.y -= calculatedOffset;
    vec4 texture_color = texture(TEXTURE, UV);
    vec4 screen_color = vec4(texture(SCREEN_TEXTURE, screen_uv));
//    COLOR = vec4(texture(SCREEN_TEXTURE, vec2(uv.x, uv.y)));
    COLOR = (texture_color * 0.5 + screen_color * 0.5) * vec4(1.,1.,1., texture_color.a);
}