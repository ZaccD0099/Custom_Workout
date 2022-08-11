//
//  Exercise.swift
//  Custom Fitness
//
//  Created by Zach Davis on 7/30/22.
//

import UIKit
import RealmSwift

class Exercise : Object {
    
    @Persisted(primaryKey: true) var id = UUID().uuidString
    @Persisted var name : String = ""
    @Persisted var duration : Int = 0
    @Persisted var sets : Int = 0
    @Persisted var reps : Int = 0
    @Persisted var intervals : Int = 0
    @Persisted var intervalActiveTime : Int = 0
    @Persisted var intervalRestTime : Int = 0
    @Persisted var completed : Bool = false
    @Persisted var current : Bool = false
    @Persisted var order : Int = 0
    @Persisted var type : String?
    
    var parentCategory = LinkingObjects(fromType: Workout.self, property: "workoutExcercises")
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

enum ExerciseType: String {
    case interval = "Interval"
    case singleDuration = "Single Duration"
    case setsReps = "Sets & Reps"
}


