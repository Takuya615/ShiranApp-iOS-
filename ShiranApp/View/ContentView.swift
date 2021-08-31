//
//  ContentView.swift
//  ShiranApp
//
//  Created by user on 2021/07/19.
//

import SwiftUI
import Firebase


struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataCounter: DataCounter
    @State var push = false
    @State var isVideo = false
    
    let modifiedDate = Calendar.current.date(byAdding: .second, value: 30, to: Date())!
    
    var body: some View {
        Group{if self.appState.isPrivacyPolicy{
            PrivacyPolicyView()
        }else if self.isVideo {
            VStack{
                HStack{
                    Button(action: {isVideo = false}, label: {
                        Text("  ＜Back").font(.system(size: 20))
                    })
                    Spacer()
                }
                VideoCameraView2(isVideo: $isVideo)
                    .onDisappear(perform: {
                        self.dataCounter.scoreCounter()
                    })
            }
        }else {
                ZStack{
                    if !dataCounter.coachMark1 {// get true when push fab
                        CoachMarkView()
                    }
                    fragment
                    fab
                }
            }
        }
    }
    var fragment:some View {
        TabView {
            FirstView()
             .tabItem {
                Image(systemName: "homekit")
                Text("ホーム")
              }
            SecondView()
                .tabItem {
                    Image(systemName: "pencil")
                    Text("活動記録")
                }
            ThirdView()
             .tabItem {
                 Image(systemName: "questionmark")
                 Text("？？？")
               }
        }
    }
    
    var fab: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                
                Button(action:{
                    self.isVideo = true
                    self.dataCounter.coachMark1 = true
                }, label: {
                    Image(systemName: "flame")//"video.fill.badge.plus")
                        .foregroundColor(.white)
                        .font(.system(size: 40))
                })
                .frame(width: 60, height: 60, alignment: .center)
                .background(Color.orange)
                .cornerRadius(30.0)
                .shadow(color: .gray, radius: 3, x: 3, y: 3)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 60.0, trailing: 16.0))
                /*.fullScreenCover(isPresented: self.$isVideo, content: {
                    VideoCameraView2(isVideo: $isVideo)
                })*/
            
            }
        }
    
        
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            //.environmentObject(AppState())
    }
}


struct FirstView: View{
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataCounter: DataCounter
    @State var isOpenSideMenu = false

    var body: some View {
        NavigationView{
            HStack{
                VStack{
                    Text("リトライ数")
                        .font(.system(size: 20, weight: .black, design: .default))
                        .foregroundColor(.blue)
                    
                    Text(String(self.dataCounter.continuedRetryCounter))
                        
                        .font(.system(size: 100, weight: .black, design: .default))
                        .frame(width: 130, height: 200, alignment: .center)
                        .foregroundColor(.blue)
                }
                VStack{
                    Text("継続日数")
                        .font(.system(size: 20, weight: .black, design: .default))
                        .foregroundColor(.blue)
                    Text(String(self.dataCounter.continuedDayCounter))
                        .font(.system(size: 100, weight: .black, design: .default))
                        .frame(width: 130, height: 200, alignment: .center)
                        .foregroundColor(.blue)
                }
            }
            .navigationTitle("ホーム")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                ToolbarItem(placement: .navigationBarTrailing){
                    Menu{
                        /*Button(action: {}) {
                            Text("設定")
                            Image(systemName: "gearshape")
                                            }*/
                        
                        Button(action: {
                            appState.logout()
                        }) {
                            Text("ログアウト")
                            Image(systemName: "person")
                                            }
                        
                        Button(action: {
                            appState.isPrivacyPolicy = true
                        }) {
                            Text("プライバシーポリシー")
                            Image(systemName: "shield")
                                            }
                    }label: {
                        Image(systemName: "line.horizontal.3")
                    }
                }
            }
            
        }
        /*SideMenuView(isOpen: $isOpenSideMenu)
            .edgesIgnoringSafeArea(.all)
        }*/
    }
}

struct SecondView: View{
    @EnvironmentObject var appState: AppState
    struct Videos: Identifiable {
        var id = UUID()     // ユニークなIDを自動で設定¥
        var date: String
        var url: String
        var score: Int
    }
    @State var videos:[Videos] = []
    
    
    var body: some View {
        NavigationView{
            List{
                ForEach(videos) {video in
                    HStack{
                        Text(video.date)
                        Spacer()
                        Text("スコア\(video.score)")
                    }
                    /*Text(video.date)
                        .contentShape(RoundedRectangle(cornerRadius: 5))
                        .onTapGesture {
                            print("タップされました\(video.date)")
                            self.appState.playUrl = video.url
                            //self.appState.isVideoPlayer = true
                        }*/
                    
                }.onDelete(perform: delete)
            }
            .onAppear(perform: VideoList)//リストの更新をここでできる
            .navigationTitle("活動記録")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    // FireBaseから、動画のデータを取り出し　リストかする
    func VideoList() {
        videos = []//reset
        guard let user = Auth.auth().currentUser else {return}
        let uid = String(user.uid)//uidの設定
        
        let db = Firestore.firestore()
        db.collection(uid).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                //print("VideoList動いている\(querySnapshot!.documents.count)")
                for document in querySnapshot!.documents {
                    let date = document.data()["date"]
                    //let url = document.data()["url"]
                    let score = document.data()["score"]
                    //print("取得　date=\(date) url=\(url) score=\(score)")
                    if date == nil || score == nil {continue}
                    videos.append(Videos(date: (date as? String)!, url: "", score: (score as? Int)!))
                    videos.reverse()
                }
            }
        }
    }
    func delete(at offsets: IndexSet){
        let selectDate = offsets.map{ self.videos[$0].date }[0]
        print("削除するデータは\(selectDate)")
        
        let uid = Auth.auth().currentUser?.uid
        let db = Firestore.firestore()
        db.collection(uid!).document(selectDate).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("項目の削除成功　Document successfully removed!")
                /*let storageRef = Storage.storage().reference()
                let desertRef = storageRef.child("\(uid!) /\(selectDate).mp4")
                desertRef.delete { error in
                  if let error = error {
                    print("動画の削除　しっぱい\(error)")
                    // Uh-oh, an error occurred!
                  } else {
                    // File deleted successfully
                    print("動画の削除も　せいこう！")
                  }
                }*/
                
            }
        }
        videos.remove(atOffsets: offsets)
        
    }
    
    
}
    


struct ThirdView: View {
    var body: some View {
        NavigationView{
            Text("ただいま工事中")
            .navigationTitle("？？？")
            .navigationBarTitleDisplayMode(.inline)
        }
        
    }
}
