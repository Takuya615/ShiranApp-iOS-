//
//  VideoCaptureView.swift
//  ShiranApp
//
//  Created by user on 2021/07/31.
//

import SwiftUI

struct VideoCaptureView: View {
    @EnvironmentObject var appState: AppState
    @State var isrecording = false
    @State var count = 3
    
    @State var nowD:Date = Date()
    var setDate: Date
    var timer: Timer {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {_ in
            if isrecording {
                self.nowD = Date()
                count = count-1
            }
        }
    }
    
    
    func TimerFunc(from date:Date)->String{
        let cal = Calendar(identifier: .japanese)
        let timeVal = cal.dateComponents([.minute,.second],from: nowD ,to: setDate)
        
        if isrecording {
            
            if count == 0 {
                SystemSounds().BeginVideoRecording()
                
                
                
                
                
                
            }else if count < 1 {
                return String(format: "%02d:%02d",
                        timeVal.minute ?? 00,
                        timeVal.second ?? 00)
            }else{
                return String(count)
            }
        
        }
        return ""
    }
    
    
    var body: some View {
        VStack{
            HStack{
                
                
                //.frame(width: 60, height: 60, alignment: .center)
                //.padding(.readLine())
                Spacer()
                Text(TimerFunc(from: setDate))
                    .font(.largeTitle)
                    .onAppear(perform: { _ = self.timer})
                    
                Spacer()
                Spacer()
                
            }
            ZStack{
                
                VideoCameraView123()
                /*VStack{
                    Spacer()
                    Button(action: {self.isrecording.toggle()}, label: {
                        if self.isrecording{
                                                                                
                        Image(systemName: "stop.circle")
                            .foregroundColor(.gray)
                            .background(Color.white)
                            .clipShape(Circle())
                            .font(.system(size: 60))
                            .frame(width: 100, height: 150, alignment: .center)
                                                                            
                        }else{
                        Image(systemName:"circle")
                            .foregroundColor(.white)
                            .background(Color.red)
                            .clipShape(Circle())
                            .font(.system(size: 60))
                            .frame(width: 100, height: 150, alignment: .center)
                        }
                                                    
                    }).buttonStyle(MyButtonStyle())
                }*/
                
                
            }
            
            
            
        }
    }
    
}


struct MyButtonStyle: ButtonStyle {
  func makeBody(configuration: Self.Configuration) -> some View {
    configuration.label
        //.padding()
        //.foregroundColor(Color.white)
        //.background(configuration.isPressed ? Color.red : Color.blue)
        //.cornerRadius(50.0)
        .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
        .opacity(configuration.isPressed ? 0.4 : 1)
    }
}

struct VideoCaptureView_Previews: PreviewProvider {
    static var previews: some View {
        VideoCaptureView(setDate: Date())
            //.environmentObject(DataCounter())
    }
}

