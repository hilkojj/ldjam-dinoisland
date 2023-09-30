precision mediump float;
precision mediump sampler2DShadow;

#define PI 3.14159265359
#define RGB(r,g,b) vec3(float(r) / 255.0f, float(g) / 255.0f, float(b) / 255.0f)


struct PointLight
{
    vec3 position;

//    float constant;
//    float linear;
//    float quadratic;
    vec3 attenuation; // x: constant, y: linear, z: quadratic

    vec3 color;
};

struct DirectionalLight
{
    vec3 direction;
    vec3 color;
};

#if SHADOWS
struct DirectionalShadowLight
{
    mat4 shadowSpace;
    DirectionalLight light;
};
#endif

in vec3 v_position;
in vec2 v_textureCoord;
in mat3 v_TBN;

#if FOG
in float v_fog;
#endif

layout (location = 0) out vec4 colorOut;
#if BLOOM
layout (location = 1) out vec4 brightColor;
#endif

uniform float time;

uniform vec3 diffuse;
uniform vec2 metallicRoughnessFactors;

uniform int useDiffuseTexture;
uniform sampler2D diffuseTexture;

uniform int useMetallicRoughnessTexture;
uniform sampler2D metallicRoughnessTexture;

uniform int useNormalMap;
uniform sampler2D normalMap;

uniform int useShadows; // todo: different shader for models that dont receive shadows? Sampling shadowmaps is expensive

uniform samplerCube irradianceMap;
uniform samplerCube prefilterMap;
uniform sampler2D brdfLUT;

uniform vec3 camPosition;

#ifndef NR_OF_DIR_LIGHTS
#define NR_OF_DIR_LIGHTS 0
#endif

#ifndef NR_OF_DIR_SHADOW_LIGHTS
#define NR_OF_DIR_SHADOW_LIGHTS 0
#endif

#ifndef NR_OF_POINT_LIGHTS
#define NR_OF_POINT_LIGHTS 0
#endif

#if NR_OF_DIR_LIGHTS
uniform DirectionalLight dirLights[NR_OF_DIR_LIGHTS];    // TODO: uniform buffer object?
#endif

#if NR_OF_DIR_SHADOW_LIGHTS
uniform DirectionalShadowLight dirShadowLights[NR_OF_DIR_SHADOW_LIGHTS];    // TODO: uniform buffer object?
uniform sampler2DShadow dirShadowMaps[NR_OF_DIR_SHADOW_LIGHTS];
#endif

#if NR_OF_POINT_LIGHTS
uniform PointLight pointLights[NR_OF_POINT_LIGHTS];    // TODO: uniform buffer object?
#endif


// --------------------------------------------

float mod289(float x){return x - floor(x * (1.0f / 289.0f)) * 289.0f;}
vec4 mod289(vec4 x){return x - floor(x * (1.0f / 289.0f)) * 289.0f;}
vec4 perm(vec4 x){return mod289(((x * 34.0f) + 1.0f) * x);}

float noise(vec3 p){
    vec3 a = floor(p);
    vec3 d = p - a;
    d = d * d * (3.0f - 2.0f * d);

    vec4 b = a.xxyy + vec4(0.0f, 1.0f, 0.0f, 1.0f);
    vec4 k1 = perm(b.xyxy);
    vec4 k2 = perm(k1.xyxy + b.zzww);

    vec4 c = k2 + a.zzzz;
    vec4 k3 = perm(c);
    vec4 k4 = perm(c + 1.0f);

    vec4 o1 = fract(k3 * (1.0f / 41.0f));
    vec4 o2 = fract(k4 * (1.0f / 41.0f));

    vec4 o3 = o2 * d.z + o1 * (1.0f - d.z);
    vec2 o4 = o3.yw * d.x + o3.xz * (1.0f - d.x);

    return o4.y * d.y + o4.x * (1.0 - d.y);
}

vec3 mix3(vec3 a, vec3 b, vec3 c, float t) {
    if (t < 0.5f)
    return mix(a, b, t*2.0f);
    else
    return mix(b, c, (t-0.5f)*2.0f);
}

void main()
{
    vec3 color_1 = RGB(196, 254, 252);
    vec3 color_2 = RGB(58,  185, 252);
    vec3 color_3 = RGB(20,  100, 188);


    vec2 waterScale1 = vec2(0.5, 0.05);
    vec2 waterScale2 = vec2(0.1, 0.1);
    vec2 waterScroling = vec2(-time, 0.01);
    float waterfomeScale = time * 0.3;

    vec3 pos_seaScolling_fome1 = vec3((v_position.xz * waterScale1 + waterScroling), waterfomeScale);
    vec3 pos_seaScolling_fome2 = vec3((v_position.zx * waterScale2 + waterScroling * 0.3) * 3.5, waterfomeScale);
    float gradient = 0.8 *noise(pos_seaScolling_fome1) + 0.2 * noise(pos_seaScolling_fome2);

    // gamma correction:
    colorOut.rgb = mix3(color_1, color_2, color_3, gradient);

    #if FOG
    // fog:
    colorOut.a = v_fog;
    #else
    colorOut.a = 1.;
    #endif

    #if BLOOM
    brightColor = vec4(0.0);
    #endif
}

