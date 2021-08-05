//
//  PrivacyPolicyView.swift
//  ShiranApp
//
//  Created by user on 2021/07/21.
//

import SwiftUI

struct PrivacyPolicyView: View {
    @EnvironmentObject var appState: AppState
    var body: some View {
        HStack{
                        Button(action: {self.appState.isPrivacyPolicy = false},
                               label: {Text("  ＜Back").font(.system(size: 20))
                        })
                        Spacer()
                    }
        ScrollView(.vertical){
            Group{
                Spacer()
                Text("当社は、個人情報保護方針を定め、個人情報保護の仕組みを構築し、その重要性を認識したうえで、個人情報の保護を徹底致します。")
                Spacer()
                Spacer()
                Spacer()
                Text("利用者情報の取得と利用目的")
                    .font(.title)
                Text("""
                    本サービスで取得するユーザー情報・取得方法・目的は以下のとおりです。
                    
                    □ユーザー情報
                    　　メールアドレスとパスワード
                    □取得方法
                    　　お客様の操作による取得
                    □利用者情報の利用目的
                    　　本サービス内でのアカウント作成およびログインのため

                    
                    □ユーザー情報
                    　　動画と音声
                    □取得方法
                    　　お客様の操作による取得
                    □利用者情報の利用目的
                    　　お客様ご本人またはお客様が許可する他ユーザーが、それらを活動記録として視聴するため

                    
                    □ユーザー情報
                    　　​アプリケーション内の各操作の件数、容量、処理時間、設定情報、クラッシュ情報等の利用実績情報
                    □取得方法
                    　　アプリケーションによる自動取得
                    □利用者情報の利用目的
                    　　サービス利用実態の分析によるサービス性向上に役立てるため

                    
                    □ユーザー情報
                    　　​動画のメタデータ、撮影日時、各種サービスの利用頻度などの実績情報
                    □取得方法
                    　　アプリケーションによる自動取得
                    □利用者情報の利用目的
                    　　お客様への各種フィードバックによるサービス性向上に役立てるため
                    
                    
                    
                    """)
                
                Text("利用者情報の第三者提供").font(.title)
                Text("""
                    当社が管理を委託するホスティング会社のサーバーに送信されます。また次のような場合にも第三者に情報の開示をすることがあります。
                    
                    ・統計的なデータなどユーザーを識別することができない状態で提供する場合
                    ・法令に基づき開示・提供を求められた場合
                    
                    
                    
                    """)
                Spacer()
            }
            Group{
                Text("お問い合わせ").font(.title)
                Text("ご不明な点がございましたらお問い合わせください")
                Link("shiran.app.club@gmail.com",
                      destination: URL(string: "mailto:shiran.app.club@gmail.com")!)
                    .foregroundColor(.blue)
                Spacer()
                Text("詳細プライバシーポリシーは下記URLから")
                Link("しらんプリ　プライバシーポリシー", destination: URL(string: "https://shiranapp.weebly.com/12503125211245212496124711254012509125221247112540.html")!)
                    .foregroundColor(.blue)
                Spacer()
                Spacer()
            }
        }
    }
}

struct PrivacyPolicyView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyPolicyView()
    }
}
