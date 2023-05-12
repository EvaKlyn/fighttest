/*
	魔法防御シェーダー 2 by あるる（きのもと 結衣）
	Magical Shield Shader 2 by Yui Kinomoto @arlez80

	MIT License
*/

shader_type spatial;
render_mode unshaded;

uniform vec4 barrier_color: source_color = vec4( 0.05, 1.0, 0.5, 1.0 );
uniform float barrier_force = 1.0;
uniform float barrier_interval = 50.0;
uniform float barrier_speed = 10.0;

void fragment( )
{
	vec3 v = ( INV_VIEW_MATRIX * vec4( VERTEX, 1.0 ) ).xyz;
	float f = sin( v.y * barrier_interval + TIME * barrier_speed );
	ALBEDO = barrier_color.rgb;
	ALPHA = clamp( ( 1.0 - dot( NORMAL, VIEW ) ) * f * barrier_force, 0.0, 1.0 );
}
