shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    vec4 current_color = texture(TEXTURE, UV);
    vec4 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV);

    vec3 white = vec3(1.0, 1.0, 1.0);
    vec3 black = vec3(0.0, 0.0, 0.0);

    vec3 color_20293b = vec3(0.125, 0.161, 0.231);
    vec3 color_3d364f = vec3(0.239, 0.212, 0.31);
    vec3 color_4e5570 = vec3(0.306, 0.333, 0.439);
    vec3 color_7189c9 = vec3(0.443, 0.537, 0.788);
    vec3 color_1a1e31 = vec3(0.102, 0.118, 0.192);

    if (distance(current_color.rgb, white) < 0.1) {
        if (distance(screen_color.rgb, color_4e5570) < 0.1) {
            COLOR.rgb = color_7189c9;
        }
        else if (distance(screen_color.rgb, color_7189c9) < 0.1) {
            COLOR.rgb = color_7189c9;
        }
        else if (distance(screen_color.rgb, color_3d364f) < 0.1) {
            COLOR.rgb = color_4e5570;
        }
        else if (distance(screen_color.rgb, color_20293b) < 0.1) {
            COLOR.rgb = color_3d364f;
        }
        else {
            COLOR.rgb = current_color.rgb;
        }
    }

    else if (distance(current_color.rgb, black) < 0.1) {
        if (distance(screen_color.rgb, color_20293b) < 0.1) {
            COLOR.rgb = color_1a1e31;
        }
        else if (distance(screen_color.rgb, color_3d364f) < 0.1) {
            COLOR.rgb = color_20293b;
        }
        else if (distance(screen_color.rgb, color_4e5570) < 0.1) {
            COLOR.rgb = color_3d364f;
        }
        else if (distance(screen_color.rgb, color_7189c9) < 0.1) {
            COLOR.rgb = color_4e5570;
        }
        else {
            COLOR.rgb = current_color.rgb;
        }
    }
    else {
        COLOR.rgb = current_color.rgb;
    }

    COLOR.a = current_color.a;
}