//
//  QuestionItem.swift
//  Quiz2
//
//  Created by Krystal Teng on 11/17/23.
//

import UIKit

class QuestionItem: Equatable, Codable {
    var question: String
    var answer: String
    var answeredStatus: Bool //put it here make sure once q has been deleted, the last question still can only be answered once. not using seperate array to store it
    var dateCreated: Date
    var itemKey: String
    var drawingData: Line?
    
    init(question: String, answer: String, answeredStatus: Bool=false) {
        self.question = question
        self.answer = answer
        self.answeredStatus = answeredStatus
        dateCreated = Date()
        self.itemKey = UUID().uuidString
    }
    //implementing equatable so we can use firstIndex()
    static func ==(lhs: QuestionItem, rhs: QuestionItem) -> Bool {
            return lhs.question == rhs.question && lhs.answer == rhs.answer
        }
    
}
