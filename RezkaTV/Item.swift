//
//  Item.swift
//  RezkaTV
//
//  Created by Andrii on 13.10.2025.
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
