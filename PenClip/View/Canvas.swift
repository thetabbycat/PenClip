//
//  Canvas.swift
//  DrawItNow
//
//  Created by Steven J. Selcuk on 4.08.2020.
//  Copyright © 2020 Steven J. Selcuk. All rights reserved.
//
import Foundation
import SwiftUI
import UIKit
import PencilKit

struct Canvas: View {
    @State var color = UIColor.black
    @State var clear = false
    @State var savePopup = false
    @State var showShareSheet = false
    @State private var rect2: CGRect = screen
    @State private var uiimage: UIImage? = nil
    let imageSaver = ImageSaver()
    @ObservedObject var saver = AutoSave()

    var isIpad = UIDevice.current.model.hasPrefix("iPad")
    var today = Date()
    var dateFormatter = DateFormatter()
    @State var state = settings.data(forKey: "drawingState2")

    
    @State var show = false
    @State var editMode = false
    @State var currentScale: CGFloat = 1
    @State var previousScale: CGFloat = 1.0
    @State var currentOffset = CGSize.zero
    @State var previousOffset = CGSize.zero
    @State var degree = 0.0
    @State var isSaved = AutoSave().isSaved

    var body: some View {
        ZStack {
            ZStack {
                PKCanvas(color: UIColor(named: "PencilColor")!, clear: self.$clear)
                    .edgesIgnoringSafeArea(.all)
                    .frame(width: screen.width, height: screen.height)
                    .aspectRatio(contentMode: ContentMode.fill)
                    .background(Color("PaperBG"))
                if editMode {
                    GeometryReader { _ in
                        Image("Spacer")
                            .renderingMode(.original)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: screen.width, height: screen.height)
                            .opacity(0.1)
                            .simultaneousGesture(DragGesture()
                                .onChanged { value in
                                    let deltaX = value.translation.width - self.previousOffset.width
                                    let deltaY = value.translation.height - self.previousOffset.height
                                    self.previousOffset.width = value.translation.width
                                    self.previousOffset.height = value.translation.height

                                    //  let newOffsetWidth = self.currentOffset.width + deltaX / self.currentScale
                                    //  if newOffsetWidth <= geometry.size.width - 50.0 && newOffsetWidth > -50.0 {
                                    withAnimation(.linear(duration: 1.3)) { self.currentOffset.width = self.currentOffset.width + deltaX * self.currentScale }
                                    //   }

                                    withAnimation(.linear(duration: 1.3)) { self.currentOffset.height = self.currentOffset.height + deltaY * self.currentScale }
                                }
                                .onEnded { _ in self.previousOffset = CGSize.zero })
                            .simultaneousGesture(MagnificationGesture()
                                .onChanged { value in
                                    let delta = value / self.previousScale
                                    self.previousScale = value
                                    withAnimation(.easeInOut(duration: 1.3)) { self.currentScale = self.currentScale * delta }
                                }
                                .onEnded { _ in withAnimation(.easeInOut(duration: 0.5)) { self.previousScale = 1.0 } })
                            .simultaneousGesture(RotationGesture()
                                .onChanged({ angle in
                                    withAnimation(.linear(duration: 1.3)) { self.degree = angle.degrees }
                                }))
                    }
                }
            }
            .aspectRatio(contentMode: .fit)
            .offset(x: self.currentOffset.width, y: self.currentOffset.height)
            .scaleEffect(max(self.currentScale, 0.6))
            .rotationEffect(Angle.degrees(self.degree))

            HStack(alignment: .center, spacing: 10) {
                
                Text("Menu")
                
                Button(action: {
                    self.saver.saveState()
                    self.editMode.toggle()
                }) {
                    VStack(alignment: .center) {
                        Image(self.editMode ? "Pen" : "Arrange")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: isIpad ? 32 : 28, height: isIpad ? 32 : 28)
                            .contentShape(Circle())
                        Text(self.editMode ? "Draw" : "Arrange")
                            .font(.callout)
                            .foregroundColor(Color("TextColor"))
                    }
                }
                .buttonStyle(GoodButtonStyle())

                Button(action: {
                    self.clear = false
                    if self.clear == false {
                        self.clear = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            self.clear = false
                            self.saver.saveState()
                        }
                   //     if let appDomain = Bundle.main.bundleIdentifier {
                   //         UserDefaults.standard.removePersistentDomain(forName: appDomain)
                   //     }
                    }

                }) {
                    VStack(alignment: .center) {
                        Image("Eraser")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: isIpad ? 32 : 28, height: isIpad ? 32 : 28)
                            .contentShape(Circle())
                        Text("Clear")
                            .font(.callout)
                            .foregroundColor(Color("TextColor"))
                    }
                }
                .buttonStyle(GoodButtonStyle())
                
                Button(action: {
                    self.saver.saveState()
                }) {
                    VStack(alignment: .center) {
                        Image("Export")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: isIpad ? 32 : 28, height: isIpad ? 32 : 28)
                            .contentShape(Circle())
                        Text(self.saver.isSaved ? "Saved" : "Save")
                            .font(.callout)
                            .foregroundColor(Color("TextColor"))
                    }
                }
                .buttonStyle(GoodButtonStyle())

                Button(action: {
                    self.saver.saveState()
                    self.saveImage()
                    self.savePopup = true
                }) {
                    VStack(alignment: .center) {
                        Image("Export")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: isIpad ? 32 : 28, height: isIpad ? 32 : 28)
                            .contentShape(Circle())
                        Text("Export")
                            .font(.callout)
                            .foregroundColor(Color("TextColor"))
                    }
                }
                .buttonStyle(GoodButtonStyle())

            }
            .padding(.all)
            .background(BlurView(style: .systemUltraThinMaterial))
            .cornerRadius(3)
            .offset(x: screen.width / 2 - (isIpad ? self.show ? 260 : -200 : self.show ? 200 : 20), y: -screen.height / 2 + (isIpad ? 100 : 80))
            .animation(.easeInOut(duration: 0.4))
            .gesture(DragGesture(minimumDistance: 10, coordinateSpace: .local)
                        .onEnded({ value in
                            if value.translation.width < 10 {
                                self.show = true
                            }
                            
                            if value.translation.width > 10 {
                                self.show = false
                            }
                            if value.translation.height < 10 {
                                // up
                            }
                            
                            if value.translation.height > 0 {
                                // down
                            }
                        }))
            
            
            
        }
        .alert(isPresented: $savePopup) {
            Alert(title: Text("🎉 You are awesome! "), message: Text("Your masterpiece has been saved. "), primaryButton: .default(Text("See image")) {
                UIApplication.shared.open(URL(string: "photos-redirect://")!)
            }, secondaryButton: .cancel())
        }
        .background(Color("BGColor"))
        .edgesIgnoringSafeArea(.all)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            self.saver.saveState()
        }
        .onAppear {
            do {
                if ((self.state) != nil) {
                    canvas.drawing = try PKDrawing(data: self.state!)
                }
                
            } catch {
                print("error")
            }
        }
    }
    


    func saveImage() {
        let inputImage = canvas.drawing.image(from: imgRect, scale: UIScreen.main.scale / 2).imageWithColor(tintColor: UIColor(named: "PaperBG")!)
        imageSaver.writeToPhotoAlbum(image: inputImage)
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

