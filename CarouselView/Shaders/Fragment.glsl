uniform lowp vec4 SourceColor;

varying lowp vec2 TexCoordOut;
uniform sampler2D Texture;

uniform int DisplayType;

void main(void) {
    if (DisplayType == 0) {
        gl_FragColor = SourceColor;
    } else {
        gl_FragColor = texture2D(Texture, TexCoordOut);
    }
}