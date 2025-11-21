//
//  Item.swift
//  PhotoStream
//
//  Created by Caleb Tetteh on 11/13/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
