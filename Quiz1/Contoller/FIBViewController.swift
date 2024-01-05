//
//  FIBViewController.swift
//  Quiz1
//
//  Created by Krystal Teng on 11/15/23.
//

import UIKit

class FIBViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var NextButton: UIButton!
    
    @IBOutlet weak var questionLabel: UILabel!
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var questionImageView: UIImageView!
    @IBOutlet weak var canvasView: UIView!
    @IBOutlet weak var parentView: UIView!
    
    
    let questionItemStore = QuestionItemStore.shared
    
    var currentQuestionIndex = 0
    
    var imageStore: ImageStore = ImageStore.shared
    var drawingCanvas: DrawingView?
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard !questionItemStore.allItems.isEmpty else {
            questionLabel.text = "No question, please add question"
            textField.isUserInteractionEnabled = false
            submitButton.isHidden = true
            NextButton.isHidden = true
            parentView.isHidden = true
            return
        }
        
        // Update the displayed score and answered questions count whenever the view appears
        parentView.isHidden = false
        questionLabel.text = questionItemStore.allItems[currentQuestionIndex].question
        textField.delegate = self
        submitButton.isEnabled = false // Disable submit button initially
        setupUI()
        
        // Initialize drawingCanvas on canvasView to display
        drawingCanvas = DrawingView(frame: canvasView.bounds)
        drawingCanvas?.backgroundColor = .white // Set canvas background color
        
        // Configure other properties of the canvas view
        canvasView.addSubview(drawingCanvas!)
        
        loadQuestionImage()
        loadQuestion()
        NextButton.isHidden = false
        
        
        
        
        }
    
    
    func loadQuestionImage() {
        // Fetch the current QuestionItem from your data source based on the currentQuestionIndex
        let currentQuestionItem = questionItemStore.allItems[currentQuestionIndex].itemKey
        let imageToDisplay = imageStore.image(forkey: currentQuestionItem)
        
        let canvasToDisplay = drawingCanvas?.loadLinesFromUserDefaults(for: currentQuestionItem)
          
            print("Image to display: \(currentQuestionItem)")
            print("Image to display: \(imageToDisplay)")
            print("Canvas to display: \(canvasToDisplay)")
            
            // Hide both canvas and image view initially
            canvasView.isHidden = true
            questionImageView.isHidden = true

        // Within loadQuestionImage() or wherever you decide to handle this logic
        // Show image if available, otherwise check for canvas data
        if let imageToDisplay = imageStore.image(forkey: currentQuestionItem) {
                questionImageView.image = imageToDisplay
                questionImageView.isHidden = false
                canvasView.isHidden = true
            } else {
                // Check if the DrawingView has lines saved
                if drawingCanvas?.hasLinesSaved(for: currentQuestionItem) ?? false {
                    canvasView.isHidden = false
                    questionImageView.isHidden = true
                } else {
                    questionImageView.isHidden = true
                    canvasView.isHidden = true
                }
            }

        
//        print("Image to display: \(currentQuestionItem)")
//        print("Image to display: \(imageToDisplay)")
//       
//        questionImageView.image = imageToDisplay
        
        
        }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard !questionItemStore.allItems.isEmpty else {
            questionLabel.text = "No question, please add question"
            textField.isUserInteractionEnabled = false
            submitButton.isHidden = true
            NextButton.isHidden = true
            return
        }
        parentView.isHidden = false
        questionLabel.text = questionItemStore.allItems[currentQuestionIndex].question
        textField.delegate = self
        submitButton.isEnabled = false // Disable submit button initially
        setupUI()
        // Add tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
        parentView.backgroundColor = UIColor.clear
        
        // Initialize drawingCanvas to canvasView to display
        drawingCanvas = DrawingView(frame: canvasView.bounds)
        drawingCanvas?.backgroundColor = .white // Set canvas background color
        
        // Configure other properties of the canvas view
        canvasView.addSubview(drawingCanvas!)
        
    
    }
    func setupUI() {
            textField.delegate = self
            textField.placeholder = "Enter your answer"
            textField.textColor = .blue
            textField.clearButtonMode = .always
            textField.isUserInteractionEnabled = true
        }
    //dismiss keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    //dismiss keyboard through tap blank space
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
            view.endEditing(true)
        }
    
    func loadQuestion() {
        questionLabel.text = questionItemStore.allItems[currentQuestionIndex].question
        submitButton.isEnabled = false // Disable submit button initially
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
            
            // Define a character set that allows only digits, '.', and '-'
            let allowedCharacters = CharacterSet(charactersIn: "0123456789.-")
            let replacementStringIsValid = string.rangeOfCharacter(from: allowedCharacters.inverted) == nil
            
            // Ensure the replacement string contains only allowed characters
            if replacementStringIsValid {
                submitButton.isEnabled = !text.isEmpty
                return true
            } else {
                return false
            }
        }

    
    @IBAction func submitButtonTapped(_ sender: Any) {
        
        guard let enteredText = textField.text else {
                // Handle the case when text field text is nil
                return
            }
        let correctAnswer = getCorrectAnswer() // Replace with actual correct answer fetching logic
        
        // Display "CORRECT" or "INCORRECT" based on the answer
        let isCorrect = enteredText == "\(correctAnswer)"
        if isCorrect {
            Score.shared.updateScore(withPoints: 1)
            Score.shared.incrementAnsweredQuestionsCount()
            displayResult("CORRECT", color: UIColor(red: 0.42, green: 0.61, blue: 0.54, alpha: 1.00))
        } else {
            Score.shared.incrementIncorrectScore()
            Score.shared.incrementAnsweredQuestionsCount()
            displayResult("INCORRECT", color: UIColor(red: 0.69, green: 0.38, blue: 0.38, alpha: 1.00))
        }
        questionItemStore.allItems[currentQuestionIndex].answeredStatus = true
        // Clear the text field after submitting the answer
        textField.text = ""
        
        // Check if all questions have been answered
        let allQuestionsAnswered = questionItemStore.allItems.allSatisfy { $0.answeredStatus }
            
        // Disable text field editing and submit button if all questions are answered
        if allQuestionsAnswered {
            textField.isEnabled = false
            submitButton.isEnabled = false
            }
    }
    
    func getCorrectAnswer() -> String {
        let correctAnswers = questionItemStore.allItems[currentQuestionIndex].answer
        return correctAnswers
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
        if currentQuestionIndex < questionItemStore.allItems.count {
            loadQuestion()
            loadQuestionImage()
        } else {
            currentQuestionIndex = 0
            // All questions answered, disable "Next"
            NextButton.isEnabled = false // assuming
        }
    }
    
    
    @IBAction func nextQuestion(_ sender: Any) {
        var nextIndex = currentQuestionIndex + 1
            
        // Find the next unanswered question index or loop back to the first question
        //while: ensures that the loop continues as long as the nextIndex doesn't return to the initial question.
        while nextIndex != currentQuestionIndex {
            if nextIndex >= questionItemStore.allItems.count {
                nextIndex = 0
            }
            
            
            if !questionItemStore.allItems[nextIndex].answeredStatus {
                currentQuestionIndex = nextIndex
                loadQuestion()
                loadQuestionImage()
                textField.text = "" // Clear the text field
                return
            }
            //make it loop back
            nextIndex += 1
            if nextIndex >= questionItemStore.allItems.count {
                nextIndex = 0
            }
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
