#include <metal_stdlib>
using namespace metal;

// Structure to hold vertex data
struct VertexIn {
    float4 position [[attribute(0)]];
    float2 texCoord [[attribute(1)]];
};

// Structure to hold the varying data passed to the fragment function
struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

// Vertex function
vertex VertexOut vertex_main(VertexIn in [[stage_in]]) {
    VertexOut out;
    out.position = in.position;
    out.texCoord = in.texCoord;
    return out;
}

// Uniforms
struct Uniforms {
    float4 colorChange;
};

// Fragment function
fragment float4 fragment_main(VertexOut in [[stage_in]], texture2d<float> texture [[texture(0)]], constant Uniforms &uniforms [[buffer(0)]]) {
    constexpr sampler textureSampler (mag_filter::linear, min_filter::linear);
    float4 texColor = texture.sample(textureSampler, in.texCoord);
    return texColor * uniforms.colorChange;
}
