//
//  Presenter.swift
//  Mesh to SDF
//
//  Created by Adellar Irankunda on 10/19/24.
//
import MetalKit
import Metal
import SwiftUI


struct MetalView : NSViewRepresentable {
    var renderer: Renderer
    
    class Coordinator : NSObject, MTKViewDelegate {
        var parent : MetalView
        var renderer : Renderer
        var device : MTLDevice
        var commandQueue : MTLCommandQueue
        
        init(_parent : MetalView, _renderer: Renderer)
        {
            self.parent = _parent
            self.renderer = _renderer
            self.device = renderer.device
            self.commandQueue = renderer.commandQueue
            
        }
        
        
        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize)
        {
            
        }
        
        
        func draw(in view : MTKView)
        {
            guard let drawable = view.currentDrawable else { return }
            
        }
        
    }
    
    func makeNSView(context: Context) -> MTKView
    {
        let metalView = MTKView()
        metalView.delegate = context.coordinator
        metalView.device = renderer.device
        metalView.framebufferOnly = false
        metalView.delegate = context.coordinator
        
        return metalView
    }
    
    func updateNSView(_ nsView: MTKView, context: Context)
    {
        
    }
    
    func makeCoordinator() -> Coordinator
    {
        return Coordinator(_parent: self, _renderer: renderer)
    }
    
}
