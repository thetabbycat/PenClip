//
//  Utils.swift
//  DrawItNow
//
//  Created by Steven J. Selcuk on 4.08.2020.
//  Copyright © 2020 Steven J. Selcuk. All rights reserved.
//

import Foundation
import PencilKit
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
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveError), nil)
    }

    @objc func saveError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        //   UIApplication.shared.open(URL(string:"photos-redirect://")!)
    }
}


class UIActivityViewControllerHost: UIViewController {
    var message = ""
    var completionWithItemsHandler: UIActivityViewController.CompletionWithItemsHandler?

    override func viewDidAppear(_ animated: Bool) {
        share()
    }

    func share() {
        // set up activity view controller
        let textToShare = [message]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)

        activityViewController.completionWithItemsHandler = completionWithItemsHandler
        activityViewController.popoverPresentationController?.sourceView = view // so that iPads won't crash

        // present the view controller
        present(activityViewController, animated: true, completion: nil)
    }
}

struct ActivityViewController: UIViewControllerRepresentable {
    @Binding var text: String
    @Binding var showing: Bool

    func makeUIViewController(context: Context) -> UIActivityViewControllerHost {
        // Create the host and setup the conditions for destroying it
        let result = UIActivityViewControllerHost()

        result.completionWithItemsHandler = { _, _, _, _ in
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

struct ShareSheet: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIActivityViewController

    var sharing: [Any]

    func makeUIViewController(context: UIViewControllerRepresentableContext<ShareSheet>) -> UIActivityViewController {
        UIActivityViewController(activityItems: sharing, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ShareSheet>) {
    }
}


extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xFF0000) >> 16
        let g = (rgbValue & 0xFF00) >> 8
        let b = rgbValue & 0xFF
        
        self.init(red: Double(r) / 0xFF, green: Double(g) / 0xFF, blue: Double(b) / 0xFF)
    }
}
