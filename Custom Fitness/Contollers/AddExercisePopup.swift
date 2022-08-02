//
//  AddExercisePopup.swift
//  Custom Fitness
//
//  Created by Zach Davis on 7/29/22.
//

import UIKit
import RealmSwift

class AddExercisePopup: UIViewController {
    
    var exerciseViewController : ExerciseTableViewController?
    
    var selectedWorkout : Workout?
    
    let realm = try! Realm()

    @IBOutlet var backgroundView: UIView!
    
    @IBOutlet weak var popUpView: UIView!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var durationTextField: UITextField!
    
    @IBOutlet weak var setsTextField: UITextField!
    
    @IBOutlet weak var repsTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        popUpView.layer.cornerRadius = 15.0
        popUpView.layer.borderWidth = 1.0
        popUpView.layer.borderColor = UIColor(named: "custom_dark")?.cgColor

        // Do any additional setup after loading the view.
    }
    
    
    //    get the first touch and if it is the background it will dismiss this view
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
        {
            let touch = touches.first
            if touch?.view == self.backgroundView {
                self.dismiss(animated: true, completion: nil)
            }
        }
    
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        
        addExercise()
        
        self.dismiss(animated: true) {
            self.exerciseViewController?.loadExercises()
        }
    }
    
    func addExercise() {
        
        if let selectedWorkout = self.selectedWorkout {
            do {
                try realm.write({
                    
                    let newExercise = Exercise()
                    
                    newExercise.name = nameTextField.text ?? ""
                    
                    let durationInt = Int(durationTextField.text!) ?? 0
                    newExercise.duration = durationInt
                    
                    let setsInt = Int(setsTextField.text!) ?? 0
                    newExercise.sets = setsInt
                    
                    let repsInt = Int(repsTextField.text!) ?? 0
                    newExercise.reps = repsInt
                    
                    realm.add(newExercise)
                    
                    selectedWorkout.workoutExcercises.append(newExercise)
                    print("added exercise \(newExercise.name) to \(selectedWorkout.title)")
                    
                })
            }
            catch {
                print("error adding exercise \(error)")
            }
        }
    }
    
}
