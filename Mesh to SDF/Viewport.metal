//
//  Viewport.metal
//  Mesh to SDF
//
//  Created by Adellar Irankunda on 11/1/24.
//

#include <metal_stdlib>
using namespace metal;


kernel void Render(texture2d<float, access::read_write> output [[texture(0)]], const uint2 position [[thread_position_in_grid]])
{
    
}
