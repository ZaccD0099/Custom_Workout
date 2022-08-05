//
//  EditWorkoutPopup.swift
//  Custom Fitness
//
//  Created by Zach Davis on 8/1/22.
//

import UIKit
import RealmSwift

protocol EditWorkoutPopupProtocol {
    func getWorkout() -> Workout?
    func removeWorkout(_ selectedWorkout : Workout?)
    func saveWorkout(_ selectedWorkout : Workout?)
    func loadWorkouts()
}

class EditWorkoutPopup: UIViewController {

    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var typeTextField: UITextField!
    @IBOutlet weak var durationTextField: UITextField!
    @IBOutlet var backgroundView: UIView!
    
    var realm = try! Realm()
    var delegate : EditWorkoutPopupProtocol?
    var selectedWorkout : Workout?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        popUpView.layer.cornerRadius = 15.0
        popUpView.layer.borderWidth = 1.0
        popUpView.layer.borderColor = UIColor(named: "custom_dark")?.cgColor
        
        selectedWorkout = delegate?.getWorkout()
        
        if let workout = selectedWorkout {
            nameTextField.text = workout.title
            typeTextField.text = workout.type
            durationTextField.text = String(workout.duration)
        }
    }
    
//    dismissing popup on touch outside popup
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
        {
            let touch = touches.first
            if touch?.view == self.backgroundView {
                self.dismiss(animated: true, completion: nil)
            }
        }
    
    @IBAction func saveChangedButtonPressed(_ sender: UIButton) {
        
        if let workout = selectedWorkout {

            workout.title = nameTextField.text ?? ""
            workout.type = typeTextField.text ?? ""
            workout.duration = Int(durationTextField.text!) ?? 0
            
            delegate?.saveWorkout(workout)
        }
        
        returnToWorkouts()
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        
        delegate?.removeWorkout(selectedWorkout)
     
        returnToWorkouts()
    }
    
    func returnToWorkouts(){
        dismiss(animated: true) {
            self.delegate?.loadWorkouts()
        }
    }
    
    
}
