//
//  Pencil.swift
//  DrawItNow
//
//  Created by Steven J. Selcuk on 4.08.2020.
//  Copyright © 2020 Steven J. Selcuk. All rights reserved.
//

import PencilKit
import SwiftUI
import UIKit

let canvas = PKCanvasView(frame: screen)
let imgRect = CGRect(x: 0, y: 0, width: screen.width, height: screen.height)

struct PKCanvas: UIViewRepresentable {
    class Coordinator: NSObject, PKCanvasViewDelegate {
        var pkCanvas: PKCanvas

        init(_ pkCanvas: PKCanvas) {
            self.pkCanvas = pkCanvas
             
        }
    }

    var color: UIColor
    @Binding var clear: Bool
    var state = settings.data(forKey: "drawingState2")

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> PKCanvasView {
        canvas.tool = PKInkingTool(.pen, color: color, width: 10)
        canvas.delegate = context.coordinator
    //    canvas.becomeFirstResponder()
        canvas.isOpaque = false
        canvas.isScrollEnabled = false
        canvas.backgroundColor = .clear
      //  canvas.backgroundColor = self.bg
      //  canvas.overrideUserInterfaceStyle = .light
        
        
        do {
            if ((self.state) != nil) {
                canvas.drawing = try PKDrawing(data: self.state!)
            }
            
    } catch {
    print("error")
    }
        canvas.becomeFirstResponder()

        if let window = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first,
            let toolPicker = PKToolPicker.shared(for: window) {
            toolPicker.addObserver(canvas)

            toolPicker.setVisible(true, forFirstResponder: canvas)
        }

        return canvas
    }

    func updateUIView(_ canvasView: PKCanvasView, context: Context) {
        if clear != context.coordinator.pkCanvas.clear {
           // canvasView.drawing = PKDrawing()
            print("hi")
        }
        
        if (clear == true) {
            canvasView.drawing = PKDrawing()
        }
        
        canvasView.tool = PKInkingTool(.pen, color: color, width: 10)
    }
}
