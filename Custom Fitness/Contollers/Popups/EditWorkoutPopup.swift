//
//  EditWorkoutPopup.swift
//  Custom Fitness
//
//  Created by Zach Davis on 8/1/22.
//

import UIKit
import RealmSwift

class EditWorkoutPopup: UIViewController {

    @IBOutlet weak var popUpView: UIView!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var typeTextField: UITextField!
    
    @IBOutlet weak var durationTextField: UITextField!
    
    @IBOutlet var backgroundView: UIView!
    
    var realm = try! Realm()
    
    var workoutCollectionView : WorkoutCollectionViewController?
    
    var cellSelectedWorkout : Workout?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        popUpView.layer.cornerRadius = 15.0
        popUpView.layer.borderWidth = 1.0
        popUpView.layer.borderColor = UIColor(named: "custom_dark")?.cgColor
        
        if let workout = cellSelectedWorkout {
            nameTextField.text = workout.title
            typeTextField.text = workout.type
            durationTextField.text = String(workout.duration)
        }
        

        // Do any additional setup after loading the view.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
        {
            let touch = touches.first
            if touch?.view == self.backgroundView {
                self.dismiss(animated: true, completion: nil)
            }
        }
    
    @IBAction func saveChangedButtonPressed(_ sender: UIButton) {
        
        if let workout = cellSelectedWorkout {
            do {
                try realm.write {
                    
                    workout.title = nameTextField.text ?? ""
                    workout.type = typeTextField.text ?? ""
                    workout.duration = Int(durationTextField.text!) ?? 0
                }
            }
            catch {
                print("error deleting workout \(error)")
            }
        }
        
        returnToWorkouts()
        
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        if let workout = cellSelectedWorkout {
            do {
                try realm.write {
                    realm.delete(workout)
                }
            }
            catch {
                print("error deleting workout \(error)")
            }
        }
        
        returnToWorkouts()
    }
    
    
    func returnToWorkouts(){
        
        dismiss(animated: true) {
            self.workoutCollectionView?.loadWorkouts()
        }
    }
    
    
}
