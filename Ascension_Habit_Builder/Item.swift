//
//  Item.swift
//  Ascension_Habit_Builder
//
//  Created by Luke Downie on 3/5/26.
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
