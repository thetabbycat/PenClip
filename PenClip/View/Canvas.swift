//
//  Canvas.swift
//  DrawItNow
//
//  Created by Steven J. Selcuk on 4.08.2020.
//  Copyright © 2020 Steven J. Selcuk. All rights reserved.
//
import SwiftUI
import PencilKit

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
    var state = settings.data(forKey: "drawingState2")
    @State private var canvasView = PKCanvasView()
    @State var show = false
    @State var editMode = false
    @State var currentScale: CGFloat = 1
    @State var previousScale: CGFloat = 1.0
    @State var currentOffset = CGSize.zero
    @State var previousOffset = CGSize.zero
    @State var degree = 0.0
    @State var isSaved = false
    // Default position for draggable circle menu (its now at upper right corner)
    @State private var dragAmount: CGPoint? = CGPoint(x: screen.width - (screen.width / 2 ), y: 80)
    @State var morphing = false
    
    init() {
     
    }
    
    var body: some View {
        let textButtons = [

            AnyView(IconButton(imageName: "trash", color: Color(hex: "DE316A"), buttonText: "Clear")
                .onTapGesture {
                    self.deleteDrawing()
                }),
            AnyView(IconButton(imageName: self.editMode ? "scribble" : "crop.rotate", color: Color(hex: "326BF1"), buttonText: self.editMode ? "Draw" : "Arrange")
                        .onTapGesture {
                            self.saveState()
                            self.editMode.toggle()
                        }),
            AnyView(IconButton(imageName: "tray.2", color: Color(hex: "6F39DE"), buttonText: self.isSaved ? "Saved" : "Save")
                .onTapGesture {
                    self.saveState()
                }),
            AnyView(IconButton(imageName: "square.and.arrow.up", color: Color(hex: "6BDFDB"), buttonText: "Export")
                .onTapGesture {
                    self.saveState()
                    self.saveImage()
                    self.savePopup = true
                }),
        ]

        let mainButton1 = AnyView(MainButton(imageName: "circle.grid.hex", colorHex: "f7b731", dragging: self.morphing, width: 80))

        let menu1 = FloatingButton(mainButtonView: mainButton1, buttons: textButtons)
            .circle()
            .spacing(20)
            .startAngle(6 * .pi)
            .endAngle(1 * .pi)
            .animation(.spring())
            .radius(90)
            .delays(delayDelta: 0.1)
            .initialOpacity(0)
            .initialScaling(0.1)

        ZStack {
            ZStack {
                CanvasView(canvasView: $canvasView)
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
                                    withAnimation(.linear(duration: 1.3)) { self.currentScale = self.currentScale * delta }
                                }
                                .onEnded { _ in withAnimation(.linear(duration: 0.5)) { self.previousScale = 1.0 } })
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

            GeometryReader { gp in
                menu1
                    .scaleEffect(self.morphing ? 1.4 : 1)
                    .animation(.easeInOut)
                    .position(self.dragAmount ?? CGPoint(x: gp.size.width / 2, y: gp.size.height / 2))
                    .highPriorityGesture(
                        DragGesture()
                            .onChanged {
                                self.dragAmount = $0.location
                                self.morphing = true
                            }
                            .onEnded { _ in
                                self.morphing = false
                            }
                    )
            }
        }
        .alert(isPresented: $savePopup) {
            Alert(title: Text("🎉 You are awesome! "), message: Text("Your masterpiece has been saved. "), primaryButton: .default(Text("See image")) {
                UIApplication.shared.open(URL(string: "photos-redirect://")!)
            }, secondaryButton: .cancel())
        }
        .background(Color("BGColor"))
        .edgesIgnoringSafeArea(.all)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            self.saveState()
        }
        .onAppear {
            do {
                if self.state != nil {
                    canvasView.drawing = try PKDrawing(data: self.state!)
                }

            } catch {
                print("error")
            }
        }
    }

    /// This function creates a PNG image
    ///
    /// Usage:
    ///
    ///     saveImage()
    ///
    /// - Parameter subject: The subject to be welcomed.
    ///
    /// - Returns: Creates a PNG file to users Photo album with a background `subject`.
    ///
    ///  - Note:[Reference](https://stackoverflow.com)
    ///
    ///  - Todo: Do stuff
    ///
    ///  - Important: make sure to do something ....
    ///
    ///  - Version: 0.1
    func saveImage() {
        // We gonna get drawing data from canvas. To full supporting mark mode we need to add a background color which depends mode
        // @SEE utils for functions & extensions.
        // @SEE Assets for Paper BG color

        let inputImage = canvasView.drawing.image(from: imgRect, scale: UIScreen.main.scale / 2).imageWithColor(tintColor: UIColor(named: "PaperBG")!)
        imageSaver.writeToPhotoAlbum(image: inputImage)
    }
    
    func deleteDrawing() {
        canvasView.drawing = PKDrawing()
    }
    
    func saveState() {
        let data = canvasView.drawing.dataRepresentation()
        settings.set(data, forKey: "drawingState2")
        isSaved = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.isSaved = false
        }
        //  print("State saved.")
    }
    
}

struct MainButton: View {
    var imageName: String
    var colorHex: String
    var dragging: Bool
    var width: CGFloat = 50

    var body: some View {
        ZStack {
            Color(hex: colorHex)
                .frame(width: width, height: width)
                .cornerRadius(width / 2)
                .shadow(color: Color(hex: colorHex).opacity(self.dragging ? 0.6 :  0.4 ), radius: 12, x: 0, y: 0)
            Image(systemName: imageName)
                .resizable()
                .foregroundColor(.white)
                .frame(minWidth: 28, idealWidth: 32, maxWidth: 32, minHeight: 28, idealHeight: 32, maxHeight: 32, alignment: .center)
        }
    }
}

struct IconButton: View {
    var imageName: String
    var color: Color
    var buttonText: String

    let imageWidth: CGFloat = 20
    let buttonWidth: CGFloat = 45

    var body: some View {
        ZStack {
            ZStack {
                self.color
                Image(systemName: imageName)
                    .frame(width: self.imageWidth, height: self.imageWidth)
                    .foregroundColor(.white)
                    .animation(nil)
            }
            .frame(width: self.buttonWidth, height: self.buttonWidth)
            .cornerRadius(self.buttonWidth / 2)
            Text(buttonText)
                .foregroundColor(Color("MenuItemTextColor"))
                .font(.custom("Jost Medium", size: 12))
                .padding(.top, 65)
                .animation(nil)
        }
    }
}
