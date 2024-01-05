//
//  ItemsViewController.swift
//  Quiz2
//
//  Created by Krystal Teng on 11/17/23.
//

import UIKit

class ItemsViewController: UITableViewController {
    
    var questionItemStore: QuestionItemStore = QuestionItemStore.shared
    var imageStore: ImageStore = ImageStore.shared
    
    @IBAction func addNewItem(_ sender: UIBarButtonItem) {
        
        //create a new item and add it to the store
        let newQuestionItem = questionItemStore.createItem()
        
        //figure out where that item is in the array
        if let index = questionItemStore.allItems.firstIndex(of: newQuestionItem) {
            let indexPath = IndexPath(row: index, section: 0)
            //insert this new row into the table
            tableView.insertRows(at: [indexPath], with: .automatic)
        }
    }
    
    //left edit button
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
        
        navigationItem.leftBarButtonItem = editButtonItem
    }


    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // #warning Incomplete implementation, return the number of rows
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        let questionItem = questionItemStore.allItems[indexPath.row]
        
        //display adjustment on textLabel
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.textLabel?.minimumScaleFactor = 0.5
        
        //display adjustment on detailTextLabel
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.textLabel?.minimumScaleFactor = 0.5
        
        
        //assign the text content of each label
        cell.textLabel?.text = questionItem.question
        cell.detailTextLabel?.text = questionItem.answer
        
        //font adjustment
        let questionFont = UIFont.systemFont(ofSize: 16.0, weight: .regular) // Change the font size and weight as needed
        let answerFont = UIFont.systemFont(ofSize: 14.0, weight: .light) // Change the font size and weight as needed

        cell.textLabel?.font = questionFont
        cell.detailTextLabel?.font = answerFont
        
        //color adjustment
        cell.textLabel?.textColor = UIColor.white
        cell.detailTextLabel?.textColor = UIColor.gray
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questionItemStore.allItems.count
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath){
        //if the tableview is asking to commit a delete command..
        if editingStyle == .delete{
            let item = questionItemStore.allItems[indexPath.row]
            //remove the item from store
            questionItemStore.removeItem(item)
            
            //remove the item's image from the image store
            imageStore.deleteImage(forkey: item.itemKey)
            
            //also remove that row from the label view with an animation
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath){
        //update model
        questionItemStore.moveItem(from: sourceIndexPath.row, to: destinationIndexPath.row)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //If the triggered segue is the "showItem" segue
        switch segue.identifier {
        case "showItem":
            //Figure out which row was just trapped
            if let row = tableView.indexPathForSelectedRow?.row{
                
                //get the item associated woth this row and pass it along
                let questionItem = questionItemStore.allItems[row]
                let detailViewController = segue.destination as! DetailViewController
                detailViewController.questionItem = questionItem
                detailViewController.imageStore = imageStore
            }
        default:
            preconditionFailure("unexpected segue identifier")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }



}
