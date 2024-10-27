//
//  ContentView.swift
//  Mesh to SDF
//
//  Created by Adellar Irankunda on 10/18/24.
//

import SwiftUI
import Metal

struct ContentView: View {
    var Viewport : MetalView?

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            
        }
        .padding()
    }
    
    init()
    {
        do
        {
            let device = MTLCreateSystemDefaultDevice()!
            //let renderer = try Renderer(_device: device)
            let sdf = try MeshSDF(_device: device, sharedQueue: nil)
        }
        catch {
            fatalError("failed to create renderer and sdf manager: \(error)")
        }
    }
}

#Preview {
    ContentView()
}
