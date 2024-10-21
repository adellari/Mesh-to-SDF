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
        var library = try device.makeDefaultLibrary(bundle: .main)
        var tracerFunc = library.makeFunction(name: "Tracer")!
        tracer = try device.makeComputePipelineState(function: tracerFunc)
        commandQueue = device.makeCommandQueue()!
    }
}
