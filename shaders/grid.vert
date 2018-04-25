#version 330
in vec2 inPosition;
out vec3 vertColor;
out vec2 texCoord;
out vec3 worldPos; //pozice bodu na povrchu telesa ve scene
out vec3 worldNormal; //normala ve scene

uniform mat4 mat;
uniform int surfaceModel;

const float PI = 3.14159265359;

// Převody soustav
// r - poloměr, azimut - phi, zenit - theta
vec3 spherialToCartesian(float r, float phi, float theta) {
return vec3(
        r * sin(phi) * cos(theta),
        r * sin(phi) * sin(theta),
        r * cos(phi)
    );
}

// r - poloměr, phi - azimut, výška - z
vec3 cylindricToCartesian(float r, float phi, float z){
return vec3(
        r * cos(phi),
        r * sin(phi),
        z
    );
}

//Modely
vec3 cartesianModel(vec2 param){
    float s = param.x * PI * 2;
    float t = param.y * PI;

    return vec3(
        sin(t) * cos(s),
        sin(t) * sin(s),
        cos(t)
    );
}
vec3 cartesianModel2(vec2 param){
    float s = param.x * PI * 2;
    float t = param.y * PI;

    return vec3(
        cos(s),
        cos(t)*2,
        sin(s)
    );
}

// sloní hlava
vec3 spherialModel(vec2 param){
    float s = param.x * PI * 2;
    float t = param.y * PI;

    float r = 3 + cos(4*s);
    float azimut = s; // phi
    float zenit = t;  // theta

    return spherialToCartesian(r, azimut, zenit);
}

// sombrero
vec3 cylindricModel(vec2 param){
    float s = param.x * PI * 2;
    float t = param.y * PI * 2;

    float r = t;
    float azimut = s;
    float z = 2 * sin(t);

    return cylindricToCartesian(r, azimut, z);
}

vec3 surface(vec2 param) {
    vec3 result;
    switch(surfaceModel){
        case 0:
            result.x = param.y;
            result.y = param.x;
            result.z = 0;
            break;
        case 1:
            result = cartesianModel(param);
            break;
        case 2:
            result = cartesianModel2(param);
            break;
        case 3:
            result = spherialModel(param);
            break;
        case 4:
            result = spherialModel(param);
            break;
        case 5:
            result = cylindricModel(param);
            break;
        case 6:
            result = cylindricModel(param);
            break;
    }

    return result;
}

vec3 surfaceNormal(vec2 param) {
//    vec3 tx = vec3(0,1,0);//parcialni derivace podle param.x;
//    vec3 ty = vec3(1,0,0);//parcialni derivace podle param.y;
    float delta = 1e-5;
    vec3 tx = (surface(param + vec2(delta, 0))
                - surface(param - vec2(delta, 0))) / (2 * delta);
    vec3 ty = (surface(param + vec2(0, delta))
                - surface(param - vec2(0, delta))) / (2 * delta);
    return cross(ty, tx);
}

void main() {
    vec3 position = surface(inPosition);
    vec3 normal = surfaceNormal(inPosition);
	gl_Position = mat * vec4(position, 1.0);
	vertColor = normal * 0.5 + 0.5;
	worldPos = position;
	worldNormal = normal;
	texCoord = inPosition;
}