
package game


vshader_src3 :: `
#version 330

// Input vertex attributes
in vec3 vertexPosition;
in vec2 vertexTexCoord;
in vec2 vertexTexCoord2;
in vec4 vertexColor;

// Input uniform values
uniform mat4 mvp;
uniform mat4 matModel;

// Output vertex attributes (to fragment shader)
out vec3 fragPosition;
out vec2 fragTexCoord;
out vec2 fragTexCoord2;
out vec4 fragColor;

void main()
{
    // Send vertex attributes to fragment shader
    fragPosition = vec3(matModel*vec4(vertexPosition, 1.0));
    fragTexCoord = vertexTexCoord;
    fragTexCoord2 = vertexTexCoord2;
    fragColor = vertexColor;

    // Calculate final vertex position
    gl_Position = mvp*vec4(vertexPosition, 1.0);
}
`


fshader_src3 :: `
#version 330


// Input vertex attributes (from vertex shader)
in vec2 fragTexCoord;
in vec2 fragTexCoord2;
in vec3 fragPosition;
in vec4 fragColor;

// Input uniform values
uniform sampler2D texture0;
uniform sampler2D texture1;

// Output fragment color
out vec4 finalColor;

void main()
{
    // Texel color fetching from texture sampler
    vec4 texelColor = texture(texture0, fragTexCoord);
    vec4 texelColor2 = texture(texture1, fragTexCoord2);

    finalColor = texelColor * texelColor2;
}
`
vshader_src :: `
#version 100
attribute vec3 vertexPosition;
attribute vec3 vertexNormal;

uniform mat4 model;
uniform mat4 mvp;

varying vec3 fragNormal;
varying vec3 fragPosition;

void main() {
    vec4 worldPos = model * vec4(vertexPosition, 1.0);
    fragPosition = worldPos.xyz;
    fragNormal = mat3(model) * vertexNormal;
    gl_Position = mvp * vec4(vertexPosition, 1.0);
}
`


fshader_src :: `
#version 100
precision mediump float;

varying vec3 fragNormal;
varying vec3 fragPosition;

void main() {
    vec3 normal = normalize(fragNormal);

    // Hardcoded light properties
    vec3 lightDir = normalize(vec3(-0.5, -1.0, -0.3));
    vec3 viewPos = vec3(4.0, 4.0, 4.0); // assumed camera position
    vec3 lightColor = vec3(1.0, 1.0, 1.0);
    vec3 objectColor = vec3(0.3, 1.0, 0.5);

    // Ambient
    float ambientStrength = 0.2;
    vec3 ambient = ambientStrength * lightColor;

    // Diffuse
    float diff = max(dot(normal, -lightDir), 0.0);
    vec3 diffuse = diff * lightColor;

    // Specular
    float specularStrength = 0.5;
    vec3 viewDir = normalize(viewPos - fragPosition);
    vec3 reflectDir = reflect(lightDir, normal);
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), 16.0);
    vec3 specular = specularStrength * spec * lightColor;

    vec3 result = (ambient + diffuse + specular) * objectColor;
    gl_FragColor = vec4(result, 1.0);
}
`
