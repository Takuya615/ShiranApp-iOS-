//
//  RootView.swift
//  aaa
//
//  Created by user on 2021/06/18.
//

import SwiftUI
import Firebase

struct RootView: View {
    @EnvironmentObject var appState: AppState
    
    
    var body: some View {
        Group{
            if appState.isLogin{
                ContentView()
            }else{
                LoginView()
            }
        }
    }
    

}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
