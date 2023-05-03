shader_type fog;

uniform float density : hint_range(-8, 8, 0.0001) = 1.0;
uniform vec4 albedo : source_color = vec4(1.0);
uniform vec4 emission : source_color = vec4(0, 0, 0, 1);


void fog() {
    DENSITY = density;
	
    ALBEDO = albedo.rgb;
    EMISSION = emission.rgb;
}