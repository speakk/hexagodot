shader_type canvas_item;

//uniform float calculatedOffset = 0;

uniform vec2 scale;
//uniform float y_zoom;

uniform sampler2D noise;
uniform vec2 distortion_scale;
uniform float intensity;
uniform float random_float;

void fragment() {
//  float uv_height = SCREEN_PIXEL_SIZE.y / TEXTURE_PIXEL_SIZE.y;
//  vec2 reflected_screen_uv = vec2(SCREEN_UV.x, SCREEN_UV.y + uv_height * UV.y * y_zoom * scale.y * 2.0);
//
//  COLOR = texture(SCREEN_TEXTURE, reflected_screen_uv);
//
  
  
//    vec2 screen_uv = SCREEN_UV;
//    screen_uv.y = 1. - screen_uv.y;
//    screen_uv.y -= calculatedOffset;
//    vec4 texture_color = texture(TEXTURE, UV);
//    vec4 screen_color = vec4(texture(SCREEN_TEXTURE, screen_uv));
////    COLOR = vec4(texture(SCREEN_TEXTURE, vec2(uv.x, uv.y)));
//    COLOR = (texture_color * 0.5 + screen_color * 0.5) * vec4(1.,1.,1., texture_color.a);

  float distortion = texture(noise, UV*scale*distortion_scale + TIME * 0.1).x * intensity;
  vec2 dist_uv = vec2(UV.x - distortion * 0.5 + 0.25, UV.y);
  
  vec4 texture_color = texture(TEXTURE, dist_uv);
  COLOR = texture_color;
}