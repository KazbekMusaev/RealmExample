//
//  Note.swift
//  RealmExample
//
//  Created by apple on 12.01.2024.
//

import Foundation
import RealmSwift

final class Note: Object {
    @Persisted(primaryKey: true) var id = UUID().uuidString
    @Persisted var title = ""
    @Persisted var noteText = ""
    @Persisted var date: Date = Date()
    @Persisted var image = ""
    var isActive: Bool = false
}


