//
//  Shader Code (c) https://www.shadertoy.com/
//


uniform mat4        u_matrix_mvp;

attribute vec4      a_position;
attribute vec2      a_texture_coords_0;
attribute vec4      a_color;
attribute vec3      a_normal;

varying vec4        v_color;
varying vec2        v_texture_coords;

void main()
{
    v_color = vec4(1.0, 1.0, 1.0, 1.0);//a_color;
    v_texture_coords = a_texture_coords_0;
    gl_Position = u_matrix_mvp * a_position;
}