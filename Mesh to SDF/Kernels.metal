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


kernel void JFAIteration(texture3d<half, access::read_write> cube [[texture(0)]], constant int& iteration [[buffer(0)]], const uint3 position [[thread_position_in_grid]])
{
    half dist = INFINITY;
    const uint3 pos = position;
    half4 closest = half4(cube.read(pos).xyzw * 1.f);
    
    for (uint i = 0; i < 3; i++)
    {
        for (uint j = 0; j < 3; j++)
        {
            for (uint k = 0; k < 3; k++)
            {
                //neighbor position
                uint3 nPos = uint3(i - 1, j - 1, k - 1) + pos;
                if (any(nPos >= 64) || any(nPos < 0)) continue;
                half4 nPix = cube.read(nPos);
                if (nPix.w == 0) continue;
                
                half _dist = distance(nPix.xyz, half3(pos));
                if (_dist < dist) {
                    closest = nPix;
                    dist = _dist;
                }
            }
        }
        
        cube.write(half4(closest), pos);
    }
}

kernel void MeshToVoxel(texture3d<half, access::write> voxelTex [[texture(0)]], constant int& trisCount [[buffer(0)]], constant Triangle* triangles [[buffer(1)]], const uint3 position [[thread_position_in_grid]])
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
        
        if (!any(voxelId < 0) /* || any(voxelId >= 64)*/)
        {
            //float distFromCenter = length(scaled - float3(32.f, 32.f, 32.f));
            half4 addr = half4(voxelId.x / 64.f, voxelId.y / 64.f, voxelId.z / 64.f, 1.f);
            voxelTex.write(addr, voxelId);
        }
    }
}
