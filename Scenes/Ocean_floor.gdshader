shader_type spatial;
render_mode unshaded;

uniform sampler2D noise_texture;
uniform float displacement_amount = 0.1;

uniform vec4 color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void vertex() {
    // Retrieve the noise texture sample
    vec2 uv = UV;
    vec4 noise = texture(noise_texture, uv);
    
    // Displace the vertex position on the Y-axis
    VERTEX.y += noise.r * displacement_amount;
}

void fragment() {
    // Output the final color
    ALBEDO = color.rgb;
}