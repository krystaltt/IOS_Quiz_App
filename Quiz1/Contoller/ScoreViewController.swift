//
//  ScoreViewController.swift
//  Quiz1
//
//  Created by Krystal Teng on 11/15/23.
//

import UIKit

class ScoreViewController: UIViewController {

    @IBOutlet weak var corretLabel: UILabel!
    
    @IBOutlet weak var answeredLabel: UILabel!
    
    @IBOutlet weak var incorrectLabel: UILabel!
    
    //if not using viewWillAppear(_ animated: Bool), the score will only update from one view or interrupted, and not update from time to time. this help to refresh everytime we enter this view
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
        // Update the displayed score and answered questions count whenever the view appears
        updateDisplayedScore()
        updateBackgroundColor()
        }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Initial setup - setting up the displayed values
        updateDisplayedScore()
        updateBackgroundColor()
    }
    
    func updateDisplayedScore() {
        // Update the labels with the current score and answered questions count
        corretLabel.text = String(Score.shared.userScore)
        incorrectLabel.text = String(Score.shared.incorrectScore)
        answeredLabel.text = String(Score.shared.answeredQuestionsCount)
    }

    func updateBackgroundColor() {
        let score = Score.shared
        
        if score.userScore > score.incorrectScore {
            view.backgroundColor = UIColor(red: 0.42, green: 0.61, blue: 0.54, alpha: 1.00) // More correct answers
        } else if score.userScore < score.incorrectScore {
            view.backgroundColor = UIColor(red: 0.69, green: 0.38, blue: 0.38, alpha: 1.00) // More incorrect answers
        } else {
            view.backgroundColor = UIColor(red: 1.00, green: 0.98, blue: 0.96, alpha: 1.00) // Equal correct and incorrect answers
        }
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
