//
//  DetailViewController.swift
//  Quiz3
//
//  Created by Krystal Teng on 11/20/23.
//

import UIKit

class DetailViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var questionField: UITextField!
    @IBOutlet weak var answerField: UITextField!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var deleteImageButton: UIButton!
    @IBOutlet weak var canvasView: UIView!
    @IBOutlet weak var drawingButton: UIBarButtonItem!

    @IBAction func deleteImage(_ sender: UIButton) {
        imageStore.deleteImage(forkey: questionItem.itemKey)
        deleteImageButton.isHidden = true // Hide the button after deleting the image
        imageView.image = nil // Clear the imageView
    }
    
    var isDrawingModeEnabled = false // Flag to track if drawing mode is enabled
    var drawingCanvas: DrawingView? // Variable to hold the DrawingView
    
    
    
    
    @IBAction func drawingCanvas(_ sender: UIBarButtonItem) {
        isDrawingModeEnabled.toggle() // Toggle drawing mode flag
        updateUIForDrawingMode() // Update UI based on the drawing mode
    }
    
    
    @IBAction func choosePhotoSource(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        //setting the model presentation style
        alertController.modalPresentationStyle = .popover
        //indicate where the pop over should point to
        alertController.popoverPresentationController?.barButtonItem = sender
        
        //add action choices
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let cameraAction = UIAlertAction(title: "Camera", style: .default) {_ in
                
                let imagePicker = self.imagePicker(for: .camera)
                self.present(imagePicker, animated: true, completion: nil)
            }
            alertController.addAction(cameraAction)
        }
        
        
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) {_ in

            let imagePicker = self.imagePicker(for: .photoLibrary)
            imagePicker.modalPresentationStyle = .popover
            imagePicker.popoverPresentationController? .barButtonItem = sender
            self.present(imagePicker, animated: true, completion: nil)
        }
        alertController.addAction(photoLibraryAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
        
        
    }
    
    @IBAction func backgroundTapped(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        questionField.delegate = self
        answerField.delegate = self
        answerField.placeholder = "(numbers, periods, and dashes only)"
        
        //setting the canvas for the drawing
        drawingCanvas = DrawingView(frame: canvasView.bounds)
        drawingCanvas?.backgroundColor = .white
        canvasView.addSubview(drawingCanvas!)
        canvasView.isUserInteractionEnabled = true


        // Check for existing image and configure UI accordingly
        configureDrawingMode()

        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Check if the text field is the answerField
        if textField == answerField {
            // Define allowed characters: digits, decimal point, and minus sign
            let allowedCharacters = CharacterSet(charactersIn: "0123456789.-")
            let characterSetFromString = CharacterSet(charactersIn: string)
            
            // Ensure the input only contains allowed characters
            if !allowedCharacters.isSuperset(of: characterSetFromString) {
                return false
            }
            
            return true
        } else {
            // For other text fields, allow any input
            return true
        }
    }
    
    //setting drawing function
    func configureDrawingMode() {
        if let existingImage = imageStore.image(forkey: questionItem.itemKey) {
            // An image already exists, display it in the imageView
            imageView.image = existingImage
            isDrawingModeEnabled = false
            navigationItem.rightBarButtonItem?.isEnabled = false // Disable the "Draw" button
            drawingCanvas?.isHidden = true
            canvasView.isHidden = true // Hide the canvas view when an image exists
        } else {
            // No existing image, enable drawing mode
            isDrawingModeEnabled = true
            navigationItem.rightBarButtonItem?.isEnabled = true
            canvasView.isHidden = false // Show the canvas view when there's no image
        }
    }

    
    func updateUIForDrawingMode() {
        if let canvas = drawingCanvas {
            if let drawingView = canvas as? DrawingView {
                let numberOfFinishedLines = drawingView.finishedLines.count
                if numberOfFinishedLines > 0 {
                    // Show the canvas if there are saved lines
                    canvas.isHidden = false
                    canvas.isUserInteractionEnabled = true // Enable interaction
                    
                    canvasView.isHidden = false
                    navigationItem.rightBarButtonItem?.isEnabled = true // Enable the "Draw" button
                } else {
                    // Show the canvas even if there are no saved lines
                    canvas.isHidden = false
                    canvas.isUserInteractionEnabled = true // Enable interaction
                    
                    canvasView.isHidden = false
                    navigationItem.rightBarButtonItem?.isEnabled = false // Disable the "Draw" button
                }
            }
        } else {
            // No existing canvas, create a new one
            drawingCanvas = DrawingView(frame: canvasView.bounds)
//            drawingCanvas?.backgroundColor = .white
            canvasView.addSubview(drawingCanvas!)
            
            // Show and enable the newly created canvas
            drawingCanvas?.isHidden = false
            drawingCanvas?.isUserInteractionEnabled = true
            
            canvasView.isHidden = false
            navigationItem.rightBarButtonItem?.isEnabled = true // Enable the "Draw" button
        }
    }
    
    
    var questionItem: QuestionItem!
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        questionField.text = questionItem.question
        answerField.text = questionItem.answer
        dateLabel.text = dateFormatter.string(from: questionItem.dateCreated)
    
        
        //retrieving the image from Imagestore
        let key = questionItem.itemKey
        //display the associated image
        let imageToDisplay = imageStore.image(forkey: key)
        imageView.image = imageToDisplay
        
        // Check if an image exists for the item key
        if imageToDisplay != nil {
            deleteImageButton.isHidden = false // Show the delete button
        } else {
            deleteImageButton.isHidden = true // Hide the delete button
        }
        
        
        //loading lines on canvas
        drawingCanvas?.loadLinesFromUserDefaults(for: questionItem.itemKey)
        
        // Check if the canvas is empty, if yes then hide the canvas
        if let canvas = drawingCanvas {
            if let drawingView = canvas as? DrawingView {
                let numberOfFinishedLines = drawingView.finishedLines.count
                if numberOfFinishedLines == 0 {
                    canvasView.isHidden = true // Hide the canvas view if there are no saved lines
                } else {
                    canvasView.isHidden = false // Show the canvas view if there are saved lines
                    canvasView.addSubview(canvas)
                    canvas.loadLinesFromUserDefaults(for: questionItem.itemKey)
                }
            }
        } else {
            print("drawingCanvas is nil")
            canvasView.isHidden = true // Hide the canvas view if the drawingCanvas is nil
        }
        //check if image there, if yes, disable draw button
        if imageToDisplay != nil {
            // An image exists for the item key
            deleteImageButton.isHidden = false // Show the delete button
            drawingButton.isHidden = true // Disable the "Draw" button
        } else {
            // No image for the item key
            deleteImageButton.isHidden = true // Hide the delete button
            isDrawingModeEnabled = true // Ensure drawing mode is enabled when no image exists
            drawingButton.isHidden = false // Enable the "Draw" button
        }
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //"Save" changes to questionItem
        questionItem.question = questionField.text ?? ""
        questionItem.answer = answerField.text ?? ""
        //Clear first responder (dismiss the keyboard)
        view.endEditing(true)

        drawingCanvas?.saveLinesToUserDefaults(for: questionItem.itemKey)
        
    }
    
    //dismiss keyboard by pressing return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
        
    }
    
    
    //adding image picker controller creation method
    func imagePicker(for sourceType: UIImagePickerController.SourceType)-> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        return imagePicker
    
  
    //check if camera is available
        func isSourceTypeAvailble(_ type: UIImagePickerController.SourceType)-> Bool{
            return UIImagePickerController.isSourceTypeAvailable(type)
                }
        }
    
    var imageStore: ImageStore = ImageStore.shared
    
    //accessing the selected image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]){
        
        //get picked image from info dictionary
        let image = info[.originalImage] as! UIImage
        
        //store the image in the imageStore for the item's key
        imageStore.setImage(image, forkey: questionItem.itemKey)
        
        // Update questionItem's dateCreated with the current date and time
        questionItem.dateCreated = Date()
        // Update dateLabel in the UI with the new date and time
        dateLabel.text = dateFormatter.string(from: questionItem.dateCreated)
        
        //put that image on the screen in the image view
        imageView.image = image
        
        //show the delete button with the image presented
        deleteImageButton.isHidden = false
        
        //take image picker off the screen - call dismiss method
        dismiss(animated: true, completion: nil)
        
    }
    


}
