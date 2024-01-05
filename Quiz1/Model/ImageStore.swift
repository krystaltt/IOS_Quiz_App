//
//  ImageStore.swift
//  Quiz3
//
//  Created by Krystal Teng on 11/22/23.
//

import UIKit

class ImageStore {
    
    static let shared = ImageStore()
    
    let cache = NSCache<NSString, UIImage>()
    
    private init() {}
    
    //saving image data to disk
    func setImage(_ image: UIImage, forkey key: String) {
        cache.setObject(image, forKey: key as NSString)
        print("Image Set for Key: \(key)")
        
        //create full URL for image
        let url = imageURL(forKey: key)
        
        //turn image into JPEG data
        if let data = image.jpegData(compressionQuality: 0.5){
            //write it to full URL
            try?data.write(to: url)
        }
    }
    
    //fetching the image from the fileSystem if it is not in the cache
    func image(forkey key: String) -> UIImage? {
        if let existImage = cache.object(forKey: key as NSString){
            return existImage
        }
        
        let url = imageURL(forKey: key)
        guard let imageFromDisk = UIImage(contentsOfFile: url.path) else{
            return nil
        }
        
        cache.setObject(imageFromDisk, forKey: key as NSString)
        return imageFromDisk
    }
    
    func deleteImage(forkey key: String){
        cache.removeObject(forKey: key as NSString)
        
        //removing from file system
        let url = imageURL(forKey: key)
        do {
            try FileManager.default.removeItem(at: url)
        }catch {
            print("Error removing the image from disk: \(error)")
        }
    }
    
    //getting a URL for a given image
    func imageURL(forKey key: String)-> URL {
        let documentDirectories = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = documentDirectories.first!
        
        return documentDirectory.appendingPathComponent(key)
    }
    

    
    
}
