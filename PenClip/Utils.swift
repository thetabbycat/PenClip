//
//  Utils.swift
//  DrawItNow
//
//  Created by Steven J. Selcuk on 4.08.2020.
//  Copyright © 2020 Steven J. Selcuk. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit
extension UserDefaults {
    
    public func optionalString(forKey defaultName: String) -> String? {
        let defaults = self
        if let value = defaults.value(forKey: defaultName) {
            return value as? String
        }
        return nil
    }
    
    
    public func optionalInt(forKey defaultName: String) -> Int? {
        let defaults = self
        if let value = defaults.value(forKey: defaultName) {
            return value as? Int
        }
        return nil
    }
    
    public func optionalBool(forKey defaultName: String) -> Bool? {
        let defaults = self
        if let value = defaults.value(forKey: defaultName) {
            return value as? Bool
        }
        return nil
    }
}

class ImageSaver: NSObject {
    let scale = UnsafeMutableRawPointer(bitPattern: Int(UIScreen.main.scale / 2))
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveError), scale)
    }
    
    @objc func saveError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        print("Image Saved.")
     //   UIApplication.shared.open(URL(string:"photos-redirect://")!)
    }
}

class UIActivityViewControllerHost: UIViewController {
    var message = ""
    var completionWithItemsHandler: UIActivityViewController.CompletionWithItemsHandler? = nil
    
    override func viewDidAppear(_ animated: Bool) {
        share()
    }
    
    func share() {
        // set up activity view controller
        let textToShare = [ message ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        
        
        activityViewController.completionWithItemsHandler = completionWithItemsHandler
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }
}


struct ActivityViewController: UIViewControllerRepresentable {
    @Binding var text: String
    @Binding var showing: Bool
    
    func makeUIViewController(context: Context) -> UIActivityViewControllerHost {
        // Create the host and setup the conditions for destroying it
        let result = UIActivityViewControllerHost()
        
        result.completionWithItemsHandler = { (activityType, completed, returnedItems, error) in
            // To indicate to the hosting view this should be "dismissed"
            self.showing = false
        }
        
        return result
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewControllerHost, context: Context) {
        // Update the text in the hosting controller
        uiViewController.message = text
    }
    
}

extension UIView {
    func asImage(rect: CGRect) -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: rect)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}


struct RectGetter: View {
    @Binding var rect: CGRect
    
    var body: some View {
        GeometryReader { proxy in
            self.createView(proxy: proxy)
        }
    }
    
    func createView(proxy: GeometryProxy) -> some View {
        DispatchQueue.main.async {
            self.rect = proxy.frame(in: .global)
        }
        
        return Rectangle().fill(Color.clear)
    }
}

extension UIImage {
    func imageWithColor(tintColor: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, true, scale)
        
        guard let ctx = UIGraphicsGetCurrentContext(), let image = cgImage else { return self }
        defer { UIGraphicsEndImageContext() }
        
        let rect = CGRect(origin: .zero, size: size)
        ctx.setFillColor(tintColor.cgColor)
        ctx.fill(rect)
        ctx.concatenate(CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: size.height))
        ctx.draw(image, in: rect)
        
        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }
}
