//
//  ShiranAppApp.swift
//  ShiranApp
//
//  Created by user on 2021/07/19.
//

import SwiftUI
import Firebase

@main
struct ShiranAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(AppState())
                .environmentObject(DataCounter())
            
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        FirebaseApp.configure()
        //EditByOpenCV().register(url: nil)//バックグラウンドの準備！
        
        return true
    }

}


class DataCounter: ObservableObject {
    // Key
    let totalDay = "totalDay"
    let continuedDay = "cDay"
    let continuedWeek = "wDay"
    let retry = "retry"
    let _LastTimeDay = "LastTimeDay"
    let taskTime = "TaskTime"
    
    
    @Published var coachMark1: Bool = UserDefaults.standard.bool(forKey: "CoachMark1")//Save on CoachMarks-37
    @Published var coachMark2: Bool = UserDefaults.standard.bool(forKey: "CoachMark2")//Save on ViewController2 -82
    @Published var continuedDayCounter: Int = UserDefaults.standard.integer(forKey: "cDay")//めいんViewに表示する用
    @Published var continuedRetryCounter: Int = UserDefaults.standard.integer(forKey: "retry")//めいんViewに表示する用
    //@Published var capStart: Bool = false//??

    //日時の差分を計算するメソッド
    func scoreCounter(){
        let totalDay: Int = UserDefaults.standard.integer(forKey: self.totalDay)//読み込み
        
        let today = Date()
        //let modifiedDate = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let LastTimeDay: Date? = UserDefaults.standard.object(forKey: self._LastTimeDay) as? Date
    
        if LastTimeDay == nil{
            print("記念すべき第一回目")
            UserDefaults.standard.set(1, forKey: self.totalDay)//総日数
            UserDefaults.standard.set( 1, forKey: self.continuedDay)//継続日数
            UserDefaults.standard.set(today, forKey: self._LastTimeDay)//デイリー更新
            updateTaskTime(total: 181)//TaskTime初期値を５秒に修正する
            return
        }
                    
        let cal = Calendar(identifier: .gregorian)
        let todayDC = Calendar.current.dateComponents([.year, .month,.day], from: today)
        let lastDC = Calendar.current.dateComponents([.year, .month,.day], from: LastTimeDay!)
        let diff = cal.dateComponents([.day], from: lastDC, to: todayDC)
        print("todayDC:\(todayDC)")
        print("dt1DC:\(lastDC)")
        print("差は \(diff.day!) 日")
                
        
        //var calenderList:[ Int] = UserDefaults.standard.object(forKey: self.calender) as? [Int] ?? []//値が無ければ空のリスト
        let continuedDay = UserDefaults.standard.integer(forKey: self.continuedDay)
        let retry = UserDefaults.standard.integer(forKey: self.retry)
        
        if diff.day == 0{
            print("デイリー達成済み")
            return
        }else if(diff.day == 1){
            print("毎日記録更新")
            
            UserDefaults.standard.set(continuedDay + 1, forKey: self.continuedDay)
            continuedDayCounter = continuedDay + 1
            
        }else{
            print("記録リセット")
            UserDefaults.standard.set(0, forKey: self.continuedDay)
            continuedDayCounter = 0
            UserDefaults.standard.set(retry + 1, forKey: self.retry)//値の書き込み　↓表示の更新
            continuedRetryCounter = retry + 1
        }
        print("ここまで来てるよ")
        updateTaskTime(total: totalDay+1)
        UserDefaults.standard.set(totalDay + 1, forKey: self.totalDay)
        UserDefaults.standard.set(today, forKey: self._LastTimeDay)
        
        
    }

    func updateTaskTime(total:Int){
        if total%2 == 0{return}//偶数なら見送り
        var tt = UserDefaults.standard.integer(forKey: self.taskTime)
        
        switch total {
        case 0 ..< 61:
            tt = tt + 1
        case 61 ..< 91:
            tt = tt + 2
        case 91 ..< 121:
            tt = tt + 3
        case 121 ..< 151:
            tt = tt + 4
        case 151 ..< 181:
            tt = tt + 5
        default://   over 181
            tt = tt + 5
        }
        print("タスクタイム＝\(tt)")
        UserDefaults.standard.set(tt, forKey: self.taskTime)
    }
    
    
}

class AppState: ObservableObject {
    @Published var isLogin = false
    @Published var isVideoPlayer = false
    @Published var isPrivacyPolicy = false
    @Published var playUrl = ""
    
    init() {
        //FirebaseApp.configure()//FireBaseの初期化
        if Auth.auth().currentUser != nil {
            self.isLogin = true
        }
    }
    
    func signup(email:String, password:String){//email:String,password:String
        
        if(email.isEmpty || password.isEmpty){

            print("No mailAdrress or password")

        }else{
            Auth.auth().createUser(withEmail: email, password: password) { [weak self]authResult, error in
                guard self != nil else { return }
                print("登録メアドは\(email)")
                print("登録パスワードは\(password)")
                if authResult != nil && error == nil{
                    self?.isLogin = true
                    print("アカウント作成に成功しました")
                }else{
                    self?.isLogin = false
                    print("アカウント作成失敗")
                }
            }
        }
        
    }
    
    
    func loginMethod(email:String, password:String){
        if(email.isEmpty || password.isEmpty){
            print("No mailAdrress or password")
      
        }else{
            
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                guard self != nil else { return }
                print("ログインメルアドは\(email)")
                print("ログインパスワードは\(password)")
                if error == nil{
                    
                    print("ログインに成功しました")
                    self?.isLogin = true
               
                }else{
                    print("ログイン失敗")
                    self?.isLogin = false
                }
                //self?.appState.isLogin = true
            }
        }
    }
    
    func logout(){
        do {
          try Auth.auth().signOut()
            print("ログアウトしました")
            self.isLogin = false
        } catch let signOutError as NSError {
          print ("ログアウトできてませんError signing out: %@", signOutError)
          //UserDefaults.standard.set({true}, forKey:"login")
        }
    }
    
}

