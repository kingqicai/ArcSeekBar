//
//  CustomCircleView.swift
//  ArcSeekbar
//
//  Created by TapplockiOS on 2024/6/20.
//

import SwiftUI

extension View {
    func applyBG(_ imageName: String) -> some View {
        self.background(
            Image(imageName)
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .overlay(Color.black.opacity(0.4)) // 添加透明度叠加层
                .blur(radius: 2) // 添加模糊效果
        )
    }
}

class CircularSliderViewModel: ObservableObject {
    @Published var rotationAngle: Angle = Angle(degrees: 0)
    @Published var progress: Double = 0

    func updateRotationAngle(newAngle: Angle) {
        rotationAngle = newAngle
    }

    func changeAngle(location: CGPoint) {
        // ... 计算新的角度和进度 ...
        // 为位置创建一个向量（在 iOS 上反转 y 坐标系统）
        let vector = CGVector(dx: location.x, dy: -location.y)

        // 计算向量的角度
        let angleRadians = atan2(vector.dx, vector.dy)
        //print("angle: \(angleRadians)")

        // 将角度转换为 0 到 360 的范围（而不是负角度）
        let positiveAngle = angleRadians < 0 ? .pi : angleRadians
        
        // 根据角度更新滑块进度值
        progress = ((positiveAngle / (1.0 * .pi)) )
        updateRotationAngle(newAngle: Angle(radians: positiveAngle))
        //updateRotationAngle(newAngle: Angle(radians: positiveAngle))
    }
}

struct ArcView:View {
    var body : some View {
        Canvas { context, size in
            let centerX = size.width/2
            let centerY = size.height / 2
            let radius:CGFloat = 200
            let startAngle:Angle = .degrees(0)
            let endAngle:Angle = .degrees(180)
            
            var path = Path()
            path.addArc(center:CGPoint(x:centerX, y:centerY),
                        radius: radius,
                        startAngle: startAngle,
                        endAngle: endAngle,
                        clockwise: false)
            context.stroke(path, with: .color(.blue), lineWidth: 25)
        }
        .frame(height:400)
        .padding()
    }
}

struct CustomCircleView: View {
    //@Binding var isSlideEnded:Bool = false
    @StateObject private var viewModel = CircularSliderViewModel()
    
    let gradient = AngularGradient(gradient: Gradient(colors: [Color.clear, Color.white, Color.clear]), center: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, startAngle:.degrees(0), endAngle:.degrees(180))
    
    let gradient2 = AngularGradient(gradient: Gradient(colors: [Color.clear, Color.blue, Color.clear]), center: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, startAngle:.degrees(0), endAngle:.degrees(180))
    
    let gradient1 = LinearGradient(gradient: /*@START_MENU_TOKEN@*/Gradient(colors: [Color.red, Color.blue])/*@END_MENU_TOKEN@*/, startPoint: /*@START_MENU_TOKEN@*/.leading/*@END_MENU_TOKEN@*/, endPoint: /*@START_MENU_TOKEN@*/.trailing/*@END_MENU_TOKEN@*/)
    
    var body: some View {
        GeometryReader { gr in
            let radius = (min(gr.size.width, gr.size.height) / 2.0) * 0.9
            let sliderWidth = radius * 0.1
            //Color(hue: 0.0, saturation: 0.0, brightness: 0.9)
            
            VStack(spacing:0) {
                ZStack {
                    
                    Circle()
                        .trim(from:0, to:0.5)
                        .stroke(gradient,
                                style: StrokeStyle(lineWidth:20, dash:[5]))
                        .rotationEffect(Angle(degrees: 90))
                        .overlay() {
                            let txt = "30 °C"
                            Text(txt)
                                .font(.system(size: radius * 0.4, weight: .bold, design:.rounded))
                                .foregroundColor(.white)
                        }
                    
                    Circle()
                        .trim(from:0.13, to:0.138)
                        .stroke(.white,
                                style: StrokeStyle(lineWidth:30, dash:[5]))
                        .rotationEffect(Angle(degrees: 90))
                        
                        
                    
                    Circle()
                        .trim(from: 0, to: viewModel.progress*0.5)//
                        .stroke(gradient2,
                                style: StrokeStyle(lineWidth: 20, dash:[5])
                        )
                        .rotationEffect(Angle(degrees: 90))
                    
                    Circle()
                        .fill(Color.black)
                        .overlay(
                            Circle()
                                .stroke(Color.blue, lineWidth:4)
                            )
                        .shadow(radius: (sliderWidth * 0.3))
                        .frame(width: 40, height: 40)
                        .offset(y:-radius)
                        .rotationEffect(viewModel.rotationAngle + Angle(degrees: 180))
                        .gesture(
                            DragGesture(minimumDistance: 0.0)
                                .onChanged() { value in
                                    //changeAngle(location: value.location) value.location
                                    let rotatedLocation = value.location.rotate(by: Angle(degrees: -180))
                                    viewModel.changeAngle(location: rotatedLocation)
                                    //isSlideEnded = false
                                }
                                .onEnded() { value in
                                    //isSlideEnded = true
                                }
                        )
                    
                    //ArcView()
                }
                .frame(width: radius * 2.0, height: radius * 2.0, alignment: .center)
                .padding(.leading, radius)
                .padding(.top, 60)
            }
            .onAppear {
                viewModel.updateRotationAngle(newAngle: Angle(degrees: viewModel.progress * 180.0))
            }
        }
        .applyBG("bg")
    }
}

extension CGPoint {
    func rotate(by angle: Angle) -> CGPoint {
        let radians = angle.radians
        let x = self.x * CoreGraphics.cos(radians) - self.y * CoreGraphics.sin(radians)
        let y = self.x * CoreGraphics.sin(radians) + self.y * CoreGraphics.cos(radians)
        return CGPoint(x: x, y: y)
    }
}

#Preview {
    CustomCircleView()
}
