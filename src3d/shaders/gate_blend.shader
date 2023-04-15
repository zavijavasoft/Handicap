shader_type spatial;

uniform sampler2D texture_albedo;
uniform sampler2D texture_blend;

uniform float mix_amount;

void fragment() {
    vec4 albedo = texture(texture_albedo, UV);
    vec4 blend = texture(texture_blend, UV);

    // Use tex.albedo instead of vec3(1.0)
    //ALBEDO = mix(albedo.rgb, blend.rgb, blend.a * mix_amount) * albedo.rgb;
	ALBEDO = blend.rgb;
	ALPHA = blend.a;
}