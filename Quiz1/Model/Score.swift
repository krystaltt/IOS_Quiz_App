//
//  Score.swift
//  Quiz1
//
//  Created by Krystal Teng on 11/15/23.
//

import Foundation

class Score {
    static let shared = Score()

    private init() {}

    var userScore = 0

    func resetScore() {
        userScore = 0
    }

    func updateScore(withPoints points: Int) {
        userScore += points
    }
    
    var answeredQuestionsCount = 0
    
    func incrementAnsweredQuestionsCount() {
        answeredQuestionsCount += 1
    }
    
    var incorrectScore = 0
        
    func incrementIncorrectScore() {
        incorrectScore += 1
    }
}
