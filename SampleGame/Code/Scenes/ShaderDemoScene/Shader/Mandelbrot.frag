//
//  Shader Code (c) https://www.shadertoy.com/
//


precision mediump float;
uniform lowp sampler2D   u_texture_base;
uniform vec4             u_color_ambient;
uniform vec4             u_color_diffuse;

uniform vec2        u_center;
uniform float       u_scale;
//uniform int         iter;

varying vec4        v_color;
varying vec2        v_texture_coords;

void main ()
{
    vec2 z, c;
    
    float scale     = 0.01 + 3.0 * u_scale;
    int iter        = 60;
    
    c.x = 1.5 * (v_texture_coords.x - 0.5) * scale - u_center.x;
    c.y = (v_texture_coords.y - 0.5) * scale - u_center.y;
    
    int i;
    z = c;
    for (i = 0; i < iter; i++)
    {
        float x = (z.x * z.x - z.y * z.y) + c.x;
        float y = (z.y * z.x + z.x * z.y) + c.y;
        
        if ((x * x + y * y) > 4.0)
            break;
        
        z.x = x;
        z.y = y;
    }
    
    float xPos = (i == iter ? 0.0 : float(i)) / 100.0;
    vec2 pos = vec2(xPos, 0.0);
  
    gl_FragColor = texture2D(u_texture_base, pos);
    
//    if (xPos == 0.0)
//        gl_FragColor = vec4(0.1);
//    else
//        gl_FragColor = texture2D(u_texture_base, pos);
}