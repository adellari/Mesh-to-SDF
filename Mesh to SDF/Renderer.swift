//
//  Renderer.swift
//  Mesh to SDF
//
//  Created by Adellar Irankunda on 10/20/24.
//
import Metal


class Renderer
{
    var device : MTLDevice
    var commandQueue : MTLCommandQueue
    var tracer : MTLComputePipelineState
    
    init(_device : MTLDevice) throws
    {
        self.device = _device
        let library = try device.makeDefaultLibrary(bundle: .main)
        let tracerFunc = library.makeFunction(name: "Tracer")!
        tracer = try device.makeComputePipelineState(function: tracerFunc)
        commandQueue = device.makeCommandQueue()!
    }
}

class MeshSDF
{
    var device : MTLDevice
    var voxelizer : MTLComputePipelineState
    var sdfer : MTLComputePipelineState
    var voxelTex : MTLTexture
    var sdfTex : MTLTexture
    var commandQueue : MTLCommandQueue
    var triangles : [Triangle]?

    
    init(_device : MTLDevice, sharedQueue : MTLCommandQueue?) throws
    {
        self.device = _device
        let library = try device.makeDefaultLibrary(bundle: .main)
        let voxelFunc = library.makeFunction(name: "MeshToVoxel")!
        let sdfFunc = library.makeFunction(name: "VoxelToSDF")!
        voxelizer = try device.makeComputePipelineState(function: voxelFunc)
        sdfer = try device.makeComputePipelineState(function: sdfFunc)
        self.commandQueue = sharedQueue ?? device.makeCommandQueue()!
        
        let volumeDesc = MTLTextureDescriptor()
        volumeDesc.pixelFormat = .r16Float
        volumeDesc.textureType = .type3D
        volumeDesc.width = 64; volumeDesc.height = 64; volumeDesc.depth = 64;
        volumeDesc.usage = MTLTextureUsage([.shaderRead, .shaderWrite])
        voxelTex = device.makeTexture(descriptor: volumeDesc)!
        sdfTex = device.makeTexture(descriptor: volumeDesc)!
        
        loadMesh()
    }
    
    func loadMesh()
    {

        var model : ModelImporter?
        model = ModelImporter("vr_hand_simple") { success in
            
            if success{
                self.triangles = model!.triangles!
            }
            else {
                fatalError("failed to load model and triangles")
            }
            
        }
        
    }
    
}
