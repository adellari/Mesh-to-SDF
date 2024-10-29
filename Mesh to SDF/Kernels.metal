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

kernel void MeshToVoxel(texture3d<float, access::write> voxelTex [[texture(0)]], constant int& trisCount [[buffer(0)]], constant Triangle* triangles [[buffer(1)]], const uint3 position [[thread_position_in_grid]])
{
    const uint triIdx = (position.y * 80) + (position.x);
    if (triIdx >= trisCount)
        return;
    
    const Triangle tri = triangles[triIdx];
    const float3 ab = tri.v2 - tri.v1;
    const float3 ac = tri.v3 - tri.v1;
    
    for(int a = 0; a < 32; a++)
    {
        half2 s = half2(fract(0.7548776662466927 * a), fract(0.5698402909980532 * a));
        s = s.x + s.y > 1.f ? 1.f - s : s;
        
        float3 pointOnTris = ab * s.x + ac * s.y + tri.v1;
        uint3 voxelId = uint3(floor(pointOnTris));
        float3 scaled = pointOnTris * 64.f;
        
        if (!any(voxelId < 0) /*|| any(voxelId >= 64)*/)
        {
            float distFromCenter = length(scaled - float3(32.f, 32.f, 32.f));
            voxelTex.write(float4(distFromCenter, distFromCenter, distFromCenter, 1.f), voxelId);
        }
    }
}
