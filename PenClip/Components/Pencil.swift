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
            if state != nil {
                canvas.drawing = try PKDrawing(data: state!)
            }

        } catch {
            print("error")
        }
        canvas.becomeFirstResponder()


            let toolPicker = PKToolPicker.init()
            toolPicker.addObserver(canvas)

            toolPicker.setVisible(true, forFirstResponder: canvas)
        

        return canvas
    }

    func updateUIView(_ canvasView: PKCanvasView, context: Context) {
        if clear != context.coordinator.pkCanvas.clear {
            //  print("hi")
        }

        if clear == true {
            canvasView.drawing = PKDrawing()
        }

        canvasView.tool = PKInkingTool(.pen, color: color, width: 10)
    }
}



struct CanvasView {
    @Binding var canvasView: PKCanvasView
    @State var toolPicker = PKToolPicker()
    var state = settings.data(forKey: "drawingState2")
}

// MARK: - UIViewRepresentable
extension CanvasView: UIViewRepresentable {
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.tool = PKInkingTool(.pen, color: .gray, width: 10)
        #if targetEnvironment(simulator)
        canvasView.drawingPolicy = .anyInput
        #endif
        canvasView.delegate = context.coordinator
        canvasView.isOpaque = false
        canvasView.isScrollEnabled = false
        canvasView.backgroundColor = .clear
        do {
            if state != nil {
                canvasView.drawing = try PKDrawing(data: self.state!)
            }
        } catch {
            print("error")
        }
        showToolPicker()
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(canvasView: $canvasView)
    }
}

// MARK: - Private Methods
private extension CanvasView {
    func showToolPicker() {
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        canvasView.becomeFirstResponder()
    }
}

// MARK: - Coordinator
class Coordinator: NSObject {
    var canvasView: Binding<PKCanvasView>
    
    // MARK: - Initializers
    init(canvasView: Binding<PKCanvasView>) {
        self.canvasView = canvasView
    }
}

// MARK: - PKCanvasViewDelegate
extension Coordinator: PKCanvasViewDelegate {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
    }
}
