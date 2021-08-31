//
//  CoachMarks2.swift
//  ShiranApp
//
//  Created by user on 2021/08/27.
//

import Foundation
import SwiftUI
import Instructions

extension ViewController2: CoachMarksControllerDataSource {
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: (UIView & CoachMarkBodyView), arrowView: (UIView & CoachMarkArrowView)?) {
        
        self.messages = ["""
                        タイマー
                        その日のタイムリミットが表示されます(初回は５秒)
                        """,
                        """
                        タップしてはじめる
                        ３秒後にスタート。タイムリミットまでスコアを記録します。
                        (録画機能はありません)
                        """,
                        """
                        スコア
                        開閉ジャンプやバーピーなど、全身運動でよりハイスコアを目指しましょう！
                        """
        
        ]
        
        let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation)
        coachViews.bodyView.hintLabel.text = self.messages[index] // ここで文章を設定
                coachViews.bodyView.nextLabel.text = "了解" // 「次へ」などの文章

                return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
    }
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 3//self.messages.count
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        let rect = self.view.bounds.size
        let UIscore = UILabel(frame: CGRect(x: 0, y: 0, width: 250, height: 50))
        UIscore.layer.position = CGPoint(x: UIscore.frame.width/2, y: rect.height + UIscore.frame.height/2)
        
        views = [self.textTimer,self.recordButton,UIscore]
        //self.coachController.overlay.backgroundColor = UIColor.init(.accentColor)//(white: 000000, alpha: 0.3)
        return self.coachController.helper.makeCoachMark(for: self.views[index], pointOfInterest: nil, cutoutPathMaker: nil)
                // for: にUIViewを指定すれば、マークがそのViewに対応します
    }
    
}
