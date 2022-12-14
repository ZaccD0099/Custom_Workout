//
//  Workout.swift
//  Custom Fitness
//
//  Created by Zach Davis on 7/27/22.
//

import Foundation
import RealmSwift

class Workout : Object {
    
    @Persisted(primaryKey: true) var id = UUID().uuidString
    
    @Persisted var title : String = ""
    @Persisted var type : String = ""
    @Persisted var duration : Int = 0
    
    @Persisted var workoutExcercises = List<Exercise>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
}
