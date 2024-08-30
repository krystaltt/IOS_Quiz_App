//
//  DrawingView.swift
//  Quiz4
//
//  Created by Krystal Teng on 11/24/23.
//

import UIKit

class DrawingView: UIView, UIGestureRecognizerDelegate {
    
    var currentLines = [NSValue:Line]()
    var currentLine: Line?
    var finishedLines = [Line]()
    var selectedLineIndex: Int? {
        //we do so since if we select a line and delete all line, the menu will still be there
        didSet{
            if selectedLineIndex == nil {
                let menu = UIMenuController.shared
                menu.setMenuVisible(false, animated: true)
            }
        }
    }
    var moveRecognizer: UIPanGestureRecognizer!
    var penColor: UIColor = .black
    
    func stroke(_ line: Line){
        let path = UIBezierPath()
        path.lineWidth = 10
        path.lineCapStyle = .round

        
        path.move(to: line.begin)
        path.addLine(to: line.end)
        path.stroke()
    }
    
    override func draw(_ rect: CGRect){
        //Draw finished lines in black
        penColor.setStroke()
        for line in finishedLines {
            //set the color so we can change line color later
            line.lineColor.setStroke()
            stroke(_: line)
        }
        
        if let line = currentLine {
            //if there is a line currently being drawn, do it in red
            UIColor.red.setStroke()
            stroke(_: line)
        }
        
        //holding on the index for tapping to select one line
        if let index = selectedLineIndex {
            UIColor.green.setStroke()
            let selectedLine = finishedLines[index]
            stroke(selectedLine)
        }
        
        
  
    }
    
    //return the index of the line closest
    func indexOfLine(at point: CGPoint) -> Int? {
        //find a line close to the point
        for (index, line) in finishedLines.enumerated() {
            let begin = line.begin
            let end = line.end
            
            //check a few points on the line
            for t in stride(from: CGFloat(0), to: 1.0, by: 0.05){
                let x = begin.x + ((end.x - begin.x)*t)
                let y = begin.y + ((end.y - begin.y)*t)
                
                //if the tapped point is within 20 points, return this line
                if hypot(x-point.x, y-point.y)<20.0 {
                    return index
                }
            }
        }
        //If nothing is close enough to the tapped point, then we did not select a line
        return nil
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        
        //get location of the touch in view's coordinate system
        let location = touch.location(in: self)
        
        currentLine = Line(from: location, begin: location, end: location, lineColor: penColor)
        
        setNeedsDisplay()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self)
        
        currentLine?.end = location
        
        setNeedsDisplay()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if var line = currentLine {
            let touch = touches.first!
            let location = touch.location(in: self)
            line.end = location
            // Set the line's color to the current pen color, so we can change the pen's color in menu
            line.lineColor = penColor
            
            finishedLines.append(line)
        }
        currentLine = nil
        setNeedsDisplay()
    }
    
    //save the drawing in image to imageStore
    func renderAsImage() -> UIImage? {
            let renderer = UIGraphicsImageRenderer(size: bounds.size)
            return renderer.image { context in
                self.layer.render(in: context.cgContext)
            }
        }
    
    func saveLinesToUserDefaults(for itemKey: String) {

        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(finishedLines)
            UserDefaults.standard.set(data, forKey: "LinesKey_\(itemKey)")
        } catch {
            print("Error encoding lines: \(error)")
        }
    }

    func loadLinesFromUserDefaults(for itemKey: String) {
        if let data = UserDefaults.standard.data(forKey: "LinesKey_\(itemKey)") {
            do {
                let decoder = JSONDecoder()
                let lines = try decoder.decode([Line].self, from: data)
                finishedLines = lines
                setNeedsDisplay()
            } catch {
                print("Error decoding lines: \(error)")
            }
        }
    }
    
    func hasLinesSaved(for itemKey: String) -> Bool {
            if let data = UserDefaults.standard.data(forKey: "LinesKey_\(itemKey)") {
                do {
                    let decoder = JSONDecoder()
                    let lines = try decoder.decode([Line].self, from: data)
                    return !lines.isEmpty
                } catch {
                    print("Error decoding lines: \(error)")
                }
            }
            return false
        }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

    }
    
    //settting up for create a frame in detailViewController
    // Two taps to clear all lines
    override init(frame: CGRect) {
        super.init(frame: frame)
        // Initialize the gesture recognizer for double taps
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTap(_:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.delaysTouchesBegan = true
        
        
        addGestureRecognizer(doubleTapRecognizer)
        
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(DrawingView.tap(_:)))
        tapRecognizer.delaysTouchesBegan = true
        tapRecognizer.require(toFail: doubleTapRecognizer)
        addGestureRecognizer(tapRecognizer)
        
        //long press gesture recignizer
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(DrawingView.longPress(_:)))
        addGestureRecognizer(longPressRecognizer)
        
        //pan recognizer with long press
        moveRecognizer = UIPanGestureRecognizer(target: self, action: #selector(DrawingView.moveLine(_:)))
        moveRecognizer.delegate = self
        //default is true which will eat any touch it recognizes, and view won't get a chance to handle the touch via traditional UIResponder, ex: touchBegan(_:with:)
        moveRecognizer.cancelsTouchesInView = false
        addGestureRecognizer(moveRecognizer)
    }
    
    @objc func moveLine(_ gestureRecognizer: UIPanGestureRecognizer) {
        
        //if a line is selected..
        if let index = selectedLineIndex {
            //when the pen recognizer changes its position..
            if gestureRecognizer.state == .changed {
                //how far has the pen moved?
                let translation = gestureRecognizer.translation(in: self)
                
                //add the translation to the current begining and end points of the line
                //make sure there are no copy and paste type
                finishedLines[index].begin.x += translation.x
                finishedLines[index].begin.y += translation.y
                finishedLines[index].end.x += translation.x
                finishedLines[index].end.y += translation.y
                
                gestureRecognizer.setTranslation(CGPoint.zero, in: self)
                
                //redraw the screen
                setNeedsDisplay()
            }
        }else{
            //if no line is selected, do not do anything
            return
        }
    }
    
    func retrieveDrawingData() -> [Line] {
            return finishedLines
        }
    
    //delegate method, allow simultaneous recognition of gestures: long press and moving
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @objc func longPress(_ gestureRecognizer: UIGestureRecognizer) {
        
        
        let point = gestureRecognizer.location(in: self)
            
        // Check if the long press was on an existing line
        if let _ = indexOfLine(at: point) {
            // Long press on an existing line, do selection/deselection logic as before
            //when the recognizer is in began state, we will select the closest line
            if gestureRecognizer.state == .began {
                selectedLineIndex = indexOfLine(at: point)
                if selectedLineIndex != nil {
                    currentLines.removeAll()
                }
            } else if gestureRecognizer.state == .ended {
                selectedLineIndex = nil
            }
        } else {
            // Long press on a blank area, show a menu to change pen color
            let menu = UIMenuController.shared
            becomeFirstResponder()
            let grayItem = UIMenuItem(title: "Gray", action: #selector(DrawingView.changePenColorToGray(_:)))
            let redItem = UIMenuItem(title: "Red", action: #selector(DrawingView.changePenColorToRed(_:)))
            let orangeItem = UIMenuItem(title: "Orange", action: #selector(DrawingView.changePenColorToOrange(_:)))
            let yellowItem = UIMenuItem(title: "Yellow", action: #selector(DrawingView.changePenColorToYellow(_:)))
            
            menu.menuItems = [grayItem, redItem, orangeItem, yellowItem]
            
            //tell the menu where it should come from and show it
            let targetRect = CGRect(x: point.x, y: point.y, width: 2, height: 2)
            menu.setTargetRect(targetRect, in: self)
            menu.setMenuVisible(true, animated: true)
        }
        
        setNeedsDisplay()
    }

    

    
    @objc func tap(_ gestureRecognizer: UIGestureRecognizer){
        
        //hold the selected line
        let point = gestureRecognizer.location(in: self)
        selectedLineIndex = indexOfLine(at: point)
        
        //grab the menu controller
        let menu = UIMenuController.shared
        
        if selectedLineIndex != nil {
            
            //make drawingView the target of menu item action messages
            becomeFirstResponder()
            
            //create a new "delete" UIMenuItem
            let deleteItem = UIMenuItem(title: "Delete", action: #selector(DrawingView.deleteLine(_:)))

            
            //change line color option
            let grayItem = UIMenuItem(title: "Gray", action: #selector(DrawingView.changeLineColorToGray(_:)))
            let redItem = UIMenuItem(title: "Red", action: #selector(DrawingView.changeLineColorToRed(_:)))
            let orangeItem = UIMenuItem(title: "Orange", action: #selector(DrawingView.changeLineColorToOrange(_:)))
            let yellowItem = UIMenuItem(title: "Yellow", action: #selector(DrawingView.changeLineColorToYellow(_:)))
            
            menu.menuItems = [deleteItem, grayItem, redItem, orangeItem, yellowItem]
            
            
            //tell the menu where it should come from and show it
            let targetRect = CGRect(x: point.x, y: point.y, width: 2, height: 2)
            menu.setTargetRect(targetRect, in: self)
            menu.setMenuVisible(true, animated: true)
        }else{
            //hide the menu if no line is selected
            menu.setMenuVisible(false, animated: true)
        }
        
        setNeedsDisplay()
    }
      
    @objc func changeLineColorToRed(_ sender: UIMenuController) {
        if let index = selectedLineIndex {
            var color: UIColor = .red
            finishedLines[index].lineColor = color
            setNeedsDisplay()
        }
    }
    
    @objc func changeLineColorToGray(_ sender: UIMenuController) {
        if let index = selectedLineIndex {
            var color: UIColor = .gray
            finishedLines[index].lineColor = color
            setNeedsDisplay()
        }
    }
    
    @objc func changeLineColorToOrange(_ sender: UIMenuController) {
        if let index = selectedLineIndex {
            var color: UIColor = .orange
            finishedLines[index].lineColor = color
            setNeedsDisplay()
        }
    }
    
    @objc func changeLineColorToYellow(_ sender: UIMenuController) {
        if let index = selectedLineIndex {
            var color: UIColor = .yellow
            finishedLines[index].lineColor = color
            setNeedsDisplay()
        }
    }
    
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    @objc func changePenColorToGray(_ sender: UIMenuController) {
        penColor = .gray
    }
    
    @objc func changePenColorToRed(_ sender: UIMenuController) {
        penColor = .red
    }
    @objc func changePenColorToOrange(_ sender: UIMenuController) {
        penColor = .orange
    }
    @objc func changePenColorToYellow(_ sender: UIMenuController) {
        penColor = .yellow
    }
    
    
    @objc func deleteLine(_ sender: UIMenuController) {
        //remove the selected line from the list of finishedLines
        if let index = selectedLineIndex {
            finishedLines.remove(at: index)
            selectedLineIndex = nil
            
            //redraw everything
            setNeedsDisplay()
        }
    }

    
    @objc func doubleTap(_ gestureRecognizer: UIGestureRecognizer) {
        
        //double check if the user wanna cler all lines using alert
        let alertController = UIAlertController(title: "Clear All Lines", message: "Are you sure you want to clear all lines?", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                // Handle cancellation (do nothing in this case)
            }
            
            let confirmAction = UIAlertAction(title: "Clear", style: .destructive) { [weak self] _ in
                self?.clearAllLines()
                
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(confirmAction)
            
            // Present the alert
            if let viewController = self.window?.rootViewController {
                viewController.present(alertController, animated: true, completion: nil)
            }
        
    }
    
    func clearAllLines() {
        selectedLineIndex = nil
        currentLines.removeAll()
        finishedLines.removeAll()
        setNeedsDisplay()
        
    }
    


    
    
    
    
}
