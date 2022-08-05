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
    @Persisted var completed : Bool = false
    @Persisted var order : Int = 0

    
    var parentCategory = LinkingObjects(fromType: Workout.self, property: "workoutExcercises")
    
    override static func primaryKey() -> String? {
        return "id"
    }

//    func dragItems(_ exerciseList: List<Exercise>, for indexPath: IndexPath) -> [UIDragItem] {
//        let exercise = exerciseList[indexPath.row]
//
//        let itemProvider = NSItemProvider(object: exerciseList[indexPath.row])
//
//        return [
//            UIDragItem(itemProvider: itemProvider)
//        ]
//    }
}
