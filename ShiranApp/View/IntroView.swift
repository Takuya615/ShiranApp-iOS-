//
//  IntroView.swift
//  ShiranApp
//
//  Created by user on 2021/08/27.
//

import SwiftUI

struct IntroView: View {
    var imageName: String
    var number: Int
    init(imageName: String,number: Int) {
        self.imageName = imageName
        self.number = number
    }
    
    
    //@Environment(\.presentationMode) var presentationMode
    var titles: [String] = ["カメラの機能",""]
    var scripts: [String] = [
        """
あなたの動きを検出し、運動量をスコア化します.
写真のように全身が見えるように撮影しましょう.
"""
        ,""]
    
    var body: some View {
        VStack{
            Text(titles[self.number]).font(.title)
            Image(self.imageName)
                .resizable()
                .frame(width: 250, height: 400, alignment: .center)
            Text(scripts[self.number])
            /*Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }, label: {
                Text("OK")
            })*/
        
        }
    }
}

struct IntroView_Previews: PreviewProvider {
    static var previews: some View {
        IntroView(imageName: "", number: 0)
    }
}
