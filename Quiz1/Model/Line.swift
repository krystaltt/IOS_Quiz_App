//
//  Line.swift
//  Quiz4
//
//  Created by Krystal Teng on 11/24/23.
//

import Foundation
import CoreGraphics
import UIKit


import UIKit

struct Line: Codable {
    var begin = CGPoint.zero
    var end = CGPoint.zero
    var lineColor: UIColor = .black // Default color
    
    // Define custom keys for encoding and decoding
    enum CodingKeys: String, CodingKey {
        case begin
        case end
        case lineColor
    }
    
    init(from: CGPoint, begin: CGPoint, end: CGPoint, lineColor: UIColor) {
        self.begin = begin
        self.end = end
        self.lineColor = lineColor
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        begin = try container.decode(CGPoint.self, forKey: .begin)
        end = try container.decode(CGPoint.self, forKey: .end)
        
        // Decode UIColor from a custom representation
        if let colorData = try container.decodeIfPresent(Data.self, forKey: .lineColor),
           let decodedColor = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(colorData) as? UIColor {
            lineColor = decodedColor
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(begin, forKey: .begin)
        try container.encode(end, forKey: .end)
        
        // Encode UIColor to a custom representation
        let colorData = try NSKeyedArchiver.archivedData(withRootObject: lineColor, requiringSecureCoding: false)
        try container.encode(colorData, forKey: .lineColor)
    }
}
