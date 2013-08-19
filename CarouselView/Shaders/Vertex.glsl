attribute vec4 Position;

varying vec4 DestinationColor;

uniform mat4 Modelview;
uniform mat4 Projection;

attribute vec2 TexCoordIn;
varying vec2 TexCoordOut;

void main(void) {
    gl_Position = Projection * Modelview * Position;
    TexCoordOut = TexCoordIn;
}