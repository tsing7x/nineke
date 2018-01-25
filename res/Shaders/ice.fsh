#ifdef GL_ES
precision mediump float;
#endif

varying vec4 v_fragmentColor;
varying vec2 v_texCoord;

void main()
{
	vec4 c = texture2D(CC_Texture0, v_texCoord) * v_fragmentColor;
	float brightness = (c.r + c.g + c.b) * (1. / 3.);
	float gray = (1.5) * brightness;
	c = vec4(gray, gray, gray, c.a) * vec4(0.8,1.2,1.5,1);
	gl_FragColor =c;
}