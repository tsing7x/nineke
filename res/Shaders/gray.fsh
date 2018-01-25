#ifdef GL_ES
    precision mediump float;
#endif
varying vec4 v_fragmentColor; 
varying vec2 v_texCoord; 

void main(void)
{
    vec4 c = texture2D(CC_Texture0, v_texCoord);
    
    float gray = dot(c.rgb,vec3(0.299,0.587,0.114));
    gl_FragColor = vec4(gray, gray, gray, c.a);
}