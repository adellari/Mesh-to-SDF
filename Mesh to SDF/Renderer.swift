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
    var voxelGroups : MTLSize?
    var trisCount : Int?
    
    init(_device : MTLDevice, sharedQueue : MTLCommandQueue?) throws
    {
        self.device = _device
        let library = try device.makeDefaultLibrary(bundle: .main)
        let voxelFunc = library.makeFunction(name: "MeshToVoxel")!
        let sdfFunc = library.makeFunction(name: "JFAPreprocess")!
        voxelizer = try device.makeComputePipelineState(function: voxelFunc)
        sdfer = try device.makeComputePipelineState(function: sdfFunc)
        self.commandQueue = sharedQueue ?? device.makeCommandQueue()!
        
        let volumeDesc = MTLTextureDescriptor()
        volumeDesc.pixelFormat = .rgba16Float
        volumeDesc.textureType = .type3D
        volumeDesc.width = 64; volumeDesc.height = 64; volumeDesc.depth = 64;
        volumeDesc.usage = MTLTextureUsage([.shaderRead, .shaderWrite])
        voxelTex = device.makeTexture(descriptor: volumeDesc)!
        sdfTex = device.makeTexture(descriptor: volumeDesc)!
        
        LoadMesh()
    }
    
    func LoadMesh()
    {

        var model : ModelImporter?
        model = ModelImporter("vr_hand_simple") { success in
            
            if success{
                self.triangles = model!.triangles!
                print("loaded \(self.triangles!.count) triangles")
                self.trisCount = self.triangles!.count
                let root = sqrt(Double(self.trisCount!))
                let groupSize = ceil(root / 16)
                self.voxelGroups = MTLSize(width: Int(groupSize), height: Int(groupSize), depth: 1)
                print("voxel groups: \(self.voxelGroups!.width) x \(self.voxelGroups!.height) x \(self.voxelGroups!.depth)")
                
                do {
                    let captureManager = MTLCaptureManager.shared()
                    let descriptor = MTLCaptureDescriptor()
                    descriptor.captureObject = self.commandQueue.device
                    try captureManager.startCapture(with: descriptor)
                }
                
                catch {
                    print("could not create capture manager \(error)")
                }
                
                self.Voxelize(sharedBuffer: nil);
                
                MTLCaptureManager.shared().stopCapture()
            }
            else {
                fatalError("failed to load model and triangles")
            }
            
        }
        
    }
    
    func Voxelize(sharedBuffer : MTLCommandBuffer?)
    {
        
        let commandBuffer = sharedBuffer ?? commandQueue.makeCommandBuffer()!
        let voxelEncoder = commandBuffer.makeComputeCommandEncoder()!
        let trisBuffer = device.makeBuffer(bytes: self.triangles!, length: self.triangles!.count * MemoryLayout<Triangle>.stride, options: [])
        
        voxelEncoder.setComputePipelineState(voxelizer)
        voxelEncoder.label = "Mesh to Voxels"
        voxelEncoder.setBuffer(trisBuffer, offset: 0, index: 1)
        voxelEncoder.setBytes(&self.trisCount!, length: MemoryLayout<Int>.size, index: 0)
        voxelEncoder.setTexture(voxelTex, index: 0)
        voxelEncoder.dispatchThreadgroups(voxelGroups!, threadsPerThreadgroup: MTLSize(width: 16, height: 16, depth: 1))
        voxelEncoder.endEncoding()
        commandBuffer.commit();
        
        
    }
    
}
