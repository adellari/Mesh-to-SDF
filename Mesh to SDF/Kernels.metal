//
//  Kernels.metal
//  Mesh to SDF
//
//  Created by Adellar Irankunda on 10/26/24.
//
#include <metal_stdlib>
using namespace metal;
#define samples 16

struct Triangle
{
    float3 v1;
    float3 v2;
    float3 v3;
    float3 c;
};


kernel void VoxelToSDF(const uint3 position [[thread_position_in_grid]])
{
    
}

kernel void MeshToVoxel(texture3d<float, access::write> voxelTex [[texture(0)]], constant Triangle* triangles [[buffer(0)]], const uint3 position [[thread_position_in_grid]])
{
    const uint triIdx = (position.y * 80) + (position.x);
    if (triIdx >= 5652)
        return;
    const Triangle tri = triangles[triIdx];
    const float3 ab = tri.v1 - tri.v2;
}
