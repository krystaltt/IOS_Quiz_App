//
//  MCQViewController.swift
//  Quiz1
//
//  Created by Krystal Teng on 11/15/23.
//

import UIKit

class MCQViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var questionLabel: UILabel!
    
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBOutlet weak var submitButton: UIButton!
    
    
        let questions = ["What is Lionel Messi's nationality?", "Which club did Lionel Messi join as a youth player and spent his entire senior career until 2021?", "Which national team did Lionel Messi represent in his youth before choosing to play for Argentina?"]
        let answers = [
            ["Portuguese", "Argentine", "Brazilian", "Uruguayan"],
            ["Real Madrid", "Manchester City", "Barcelona", "Paris Saint-Germain"],
            [" Italy", "Spain", "France", "Portugal"]
        ]
        
    var currentQuestionIndex = 0
    var answeredStatus: [Bool] = [] // Declare the array to mark if it is marked for next button
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.dataSource = self
        pickerView.delegate = self
        loadQuestion()
        answeredStatus = [false, false, false]
    }
    
    func loadQuestion() {
        questionLabel.text = questions[currentQuestionIndex]
        pickerView.reloadAllComponents()
        submitButton.isEnabled = false // Disable submit button initially
    }
    // MARK: - UIPickerViewDataSource methods
    @objc(numberOfComponentsInPickerView:) func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1 // For single column
        }
        
    @objc func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return answers[currentQuestionIndex].count
        }
        
    // MARK: - UIPickerViewDelegate method
    @objc func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return answers[currentQuestionIndex][row]
        }
        
    @objc func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            // Enable submit button when an option is selected
            submitButton.isEnabled = true
        }
    
    
    @IBAction func submitButtonTapped(_ sender: UIButton) {
        let selectedRow = pickerView.selectedRow(inComponent: 0)
        let selectedAnswer = answers[currentQuestionIndex][selectedRow]
        
        let correctAnswer = getCorrectAnswer() // Replace with actual correct answer fetching logic
        
        // Display "CORRECT" or "INCORRECT" based on the answer
        let isCorrect = selectedAnswer == correctAnswer
        if isCorrect {
            Score.shared.updateScore(withPoints: 1)
            Score.shared.incrementAnsweredQuestionsCount()
            displayResult("CORRECT", color: UIColor(red: 0.42, green: 0.61, blue: 0.54, alpha: 1.00))
        } else {
            Score.shared.incrementIncorrectScore()
            Score.shared.incrementAnsweredQuestionsCount()
            displayResult("INCORRECT", color: UIColor(red: 0.69, green: 0.38, blue: 0.38, alpha: 1.00))
        }
        answeredStatus[currentQuestionIndex] = true
        
        // Check if all questions have been answered
        let allQuestionsAnswered = answeredStatus.allSatisfy { $0 }
            
        // Disable text field editing and submit button if all questions are answered
        if allQuestionsAnswered {
            pickerView.isUserInteractionEnabled = false
            submitButton.isEnabled = false
            }
    }
    
    func getCorrectAnswer() -> String {
        let correctAnswers = [
            "Argentine", // Answer for Question 1
            "Barcelona", // Answer for Question 2
            "Spain", // Answer for Question 3
        ]
        return correctAnswers[currentQuestionIndex]
    }
    
    func displayResult(_ resultText: String, color: UIColor) {
            let resultLabel = UILabel()
            resultLabel.text = resultText
            resultLabel.textColor = color
            resultLabel.font = UIFont.systemFont(ofSize: 40, weight: .bold)
            resultLabel.textAlignment = .center
            resultLabel.translatesAutoresizingMaskIntoConstraints = false
            
            view.addSubview(resultLabel)
            
            // Center the label in the view
            NSLayoutConstraint.activate([
                resultLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                resultLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
            
            // Remove the label after a certain duration (e.g., 2 seconds)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                resultLabel.removeFromSuperview()
                // Move to the next question or perform additional actions
                self.moveToNextQuestion()
            }
        }
    
    func moveToNextQuestion() {
        currentQuestionIndex += 1
        if currentQuestionIndex < questions.count {
            loadQuestion()
        } else {
            // All questions answered, disable "Next" button
            nextButton.isEnabled = false
        }
    }
    
    
    @IBAction func nextQuestion(_ sender: Any) {
        var nextIndex = currentQuestionIndex + 1
        // Find the next unanswered question index
        while nextIndex < answeredStatus.count {
            if !answeredStatus[nextIndex] {
                currentQuestionIndex = nextIndex
                loadQuestion()
                return
            }
            nextIndex += 1
        }
        
        // If all questions are answered, reset to the first unanswered question
        nextIndex = 0
        while nextIndex < currentQuestionIndex {
            if !answeredStatus[nextIndex] {
                currentQuestionIndex = nextIndex
                loadQuestion()
                return
            }
            nextIndex += 1
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
