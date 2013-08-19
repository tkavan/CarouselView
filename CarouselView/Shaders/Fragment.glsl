uniform lowp vec4 SourceColor;

varying lowp vec2 TexCoordOut;
uniform sampler2D Texture;

void main(void) {
    gl_FragColor = SourceColor * texture2D(Texture, TexCoordOut);
}