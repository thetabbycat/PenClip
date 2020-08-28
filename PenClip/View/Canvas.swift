//
//  Canvas.swift
//  DrawItNow
//
//  Created by Steven J. Selcuk on 4.08.2020.
//  Copyright © 2020 Steven J. Selcuk. All rights reserved.
//

import SwiftUI
import UIKit

struct Canvas: View {
    @State var color = UIColor.black
    @State var clear = false
    @State var savePopup = false
    @State var showShareSheet = false
    @State private var rect2: CGRect = screen
    @State private var uiimage: UIImage? = nil
    let imageSaver = ImageSaver()

    var isIpad = UIDevice.current.model.hasPrefix("iPad")
    var today = Date()
    var dateFormatter = DateFormatter()
    
    @State var show = false
    @State var editMode = false
    @State var currentScale: CGFloat = 1
    @State var previousScale: CGFloat = 1.0
    @State var currentOffset = CGSize.zero
    @State var previousOffset = CGSize.zero
    @State var degree = 0.0

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
                            .border(Color.gray, width: 0.5)
                            .simultaneousGesture(DragGesture()
                                .onChanged { value in
                                    let deltaX = value.translation.width - self.previousOffset.width
                                    let deltaY = value.translation.height - self.previousOffset.height
                                    self.previousOffset.width = value.translation.width
                                    self.previousOffset.height = value.translation.height

                                    //  let newOffsetWidth = self.currentOffset.width + deltaX / self.currentScale
                                    //  if newOffsetWidth <= geometry.size.width - 50.0 && newOffsetWidth > -50.0 {
                                    withAnimation(.linear(duration: 0.3)) { self.currentOffset.width = self.currentOffset.width + deltaX * self.currentScale }
                                    //   }

                                    withAnimation(.linear(duration: 0.3)) { self.currentOffset.height = self.currentOffset.height + deltaY * self.currentScale }
                                }
                                .onEnded { _ in self.previousOffset = CGSize.zero })
                            .simultaneousGesture(MagnificationGesture()
                                .onChanged { value in
                                    let delta = value / self.previousScale
                                    self.previousScale = value
                                    withAnimation(.easeInOut(duration: 0.5)) { self.currentScale = self.currentScale * delta }
                                }
                                .onEnded { _ in withAnimation(.easeInOut(duration: 0.5)) { self.previousScale = 1.0 } })
                            .simultaneousGesture(RotationGesture()
                                .onChanged({ angle in
                                    withAnimation(.linear(duration: 2)) { self.degree = angle.degrees }
                                }))
                    }
                }
            }
            .aspectRatio(contentMode: .fit)
            .offset(x: self.currentOffset.width, y: self.currentOffset.height)
            .scaleEffect(max(self.currentScale, 0.6))
            .rotationEffect(Angle.degrees(self.degree))
            .animation(.linear(duration: 1))

            HStack(alignment: .center, spacing: 0) {
                Button(action: {
                    self.editMode.toggle()
                    //     self.saveImage()
                    //       self.savePopup = true
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
                    //   self.uiimage = UIApplication.shared.windows[0].rootViewController?.view.asImage(rect: self.rect2)
                    //    self.showShareSheet.toggle()
                    self.saveImage()

                    //      self.saveImage()
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

                //      Button(action: {
                //            self.showShareSheet.toggle()
                //       }) {
                //            VStack(alignment: .center) {
                //                Image("Export")
                //                   .resizable()
                //                   .aspectRatio(contentMode: .fit)
                //                    .frame(width: isIpad ? 32 : 28, height: isIpad ? 32 : 28)
                //                  .contentShape(Circle())
                //                Text("Share")
                //                    .font(.callout)
                //                   .foregroundColor(Color("TextColor"))
                //            }
                //       }
                //       .buttonStyle(GoodButtonStyle())

            }.offset(x: screen.width / 2 - (isIpad ? 180 : 200), y: -screen.height / 2 + (isIpad ? 100 : 80))
        }
        .alert(isPresented: $savePopup) {
            Alert(title: Text("🎉 You are awesome! "), message: Text("Your masterpiece has been saved. "), primaryButton: .default(Text("See image")) {
                UIApplication.shared.open(URL(string: "photos-redirect://")!)
            }, secondaryButton: .cancel())
        }
        .background(Color("BGColor"))
        .edgesIgnoringSafeArea(.all)
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
