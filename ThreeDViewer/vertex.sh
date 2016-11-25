uniform vec4 u_mvp_matrix;

attribute mediump vec4 Position;
uniform mat4 Model;
uniform mat4 View;
uniform mat4 Projection;

void main() {
    gl_Position = Projection * View * Model * Position;
}
