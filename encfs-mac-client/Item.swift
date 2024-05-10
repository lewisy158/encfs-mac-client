//
//  Item.swift
//  encfs-mac-client
//
//  Created by 应璐暘 on 2024/5/10.
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
