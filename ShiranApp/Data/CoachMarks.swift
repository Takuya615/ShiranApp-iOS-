//
//  CoachMarks.swift
//  ShiranApp
//
//  Created by user on 2021/08/27.
//

import Foundation
import SwiftUI
import Instructions

struct CoachMarkView: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> UIViewController {
        return cmViewController()
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
}


class cmViewController: UIViewController, CoachMarksControllerDataSource {
    
    var coachController = CoachMarksController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.coachController.dataSource = self
    }
    override func viewDidAppear(_ animated: Bool) {
        super .viewDidAppear(animated)
        self.coachController.start(in: .window(over: self))//.currentWindow(of: self)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super .viewDidDisappear(animated)
        self.coachController.stop(immediately: true)
        UserDefaults.standard.set(true, forKey: "CoachMark1")//CoachMark
    }
    
    // コーチマークを表示したいUIView
    /*@IBOutlet weak*/ var firstButton: UIButton!
    /*@IBOutlet weak*/ var secondButton: UIButton!

        // マークのメッセージ配列
    private var messages = ["""
        ここをタップ
日々の運動記録をつけることができます。
"""
    ]

        // UIViewを配列にしておきます
    private var views: [UIButton] = []//[firstButton, self.secondButton]
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: (UIView & CoachMarkBodyView), arrowView: (UIView & CoachMarkArrowView)?) {
        let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation)
                coachViews.bodyView.hintLabel.text = self.messages[index] // ここで文章を設定
                coachViews.bodyView.nextLabel.text = "了解" // 「次へ」などの文章

                return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
    }
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return self.messages.count
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        let rect = self.view.bounds
        self.firstButton = UIButton(frame: CGRect(x:0, y:0, width: 300, height: 200))
        self.firstButton.layer.position = CGPoint(x: rect.width/2 , y: rect.height/2 )
        
        self.secondButton = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        let bf = self.secondButton.frame
        self.secondButton.layer.position = CGPoint(x: rect.width - bf.width/2 - 16, y: rect.height - bf.height/2 - 40)
        views = [self.secondButton]
        
        //self.coachController.overlay.backgroundColor = UIColor.init(.blue)//(white: 000000, alpha: 0.3)
        return self.coachController.helper.makeCoachMark(for: self.views[index], pointOfInterest: nil, cutoutPathMaker: nil)
                // for: にUIViewを指定すれば、マークがそのViewに対応します
    }
    
    
}
