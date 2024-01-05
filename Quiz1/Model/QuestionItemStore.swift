//
//  QuestionItemStore.swift
//  Quiz2
//
//  Created by Krystal Teng on 11/17/23.
//

import UIKit

class QuestionItemStore{
    static let shared = QuestionItemStore()
//    private init() {
//        }
    
    var allItems: [QuestionItem] = [QuestionItem(question: "Lionel Messi has won the FIFA Ballon d'Or award ____ times (as of 2023)?", answer: "8"), QuestionItem(question: "In year  ____ , Lionel Messi made his first-team debut for FC Barcelona?(which year)", answer: "2003"), QuestionItem(question: "Lionel Messi's preferred jersey number , No. ____, in most of his career at Barcelona and Argentina?(jersey number)", answer: "10"), QuestionItem(question: "Lionel Messi won his first FIFA Ballon d'Or award in the year _____.", answer: "2009"), QuestionItem(question: "Lionel Messi became Barcelona's all-time top scorer in year _____.", answer: "2014"), QuestionItem(question: "Lionel Messi won the FIFA World Cup _____ times with the Argentina national team.", answer: "1")]
    
    func removeItem(_ item: QuestionItem){
        if let index = allItems.firstIndex(of: item){
            allItems.remove(at: index)
        }
    }
    
    func moveItem(from fromIndex:Int, to toIndex:Int){
        //Get reference to object being moved so we can reinsert it
        let movedItem = allItems[fromIndex]
        //remove item from array
        allItems.remove(at: fromIndex)
        //insert item in array at new location
        allItems.insert(movedItem, at: toIndex)
    }
    
    func createItem() -> QuestionItem {
        let emptyItem = QuestionItem(question: "new question", answer: "")
        allItems.append(emptyItem)
        
        return emptyItem
        }
    
    //saving data to the disk so the data adjustment will be kept
    @objc func saveChange() -> Bool {
        print("Saving items to: \(itemArchiveURL)")
        do{
            let encoder = PropertyListEncoder()
            let data = try encoder.encode(allItems)
            try data.write(to:itemArchiveURL, options: [.atomic])
            print("Saved all of the items")
            return true
        }catch let encodingError {
            print("Error encoding allItems: \(encodingError)")
            return false
        }
        
    }
    
    let  itemArchiveURL: URL = {
        let documentsDirectories = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        var documentDirectory = documentsDirectories.first!
        return documentDirectory.appendingPathComponent("items.plist")
    }()
    
    
    init() {
        print("initializing all item")
        //loading items
        do {
            let data = try Data(contentsOf: itemArchiveURL)
            let unarchiver = PropertyListDecoder()
            let items = try unarchiver.decode([QuestionItem].self, from: data)
            allItems = items
        }catch {
            print("Error reading in saved items: \(error)")
        }
        
        //adding notification observer
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(saveChange), name: UIScene.didEnterBackgroundNotification, object: nil)
        print("notification center added")
    }
    
}
