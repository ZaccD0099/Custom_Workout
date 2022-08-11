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
    func updateWorkout(_ selectedWorkout : Workout, _ title : String, _ type : String, _ duration : Int)
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
        
//        for Keyboard Mgmt (UITextFieldDelegate)
        self.hideKeyboardWhenTappedAround()
        nameTextField.delegate = self
        typeTextField.delegate = self
        durationTextField.delegate = self
        
        durationTextField.keyboardType = .numberPad
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
        
        if let selectedWorkout = selectedWorkout {

            let title = nameTextField.text ?? ""
            let type = typeTextField.text ?? ""
            let duration = Int(durationTextField.text!) ?? 0
            
            delegate?.updateWorkout(selectedWorkout, title, type, duration)
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

    func hideKeyboardWhenTappedAround() {
            let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
            view.addGestureRecognizer(tap)
        }

    @objc func dismissKeyboard() {
        view.endEditing(true)
        }
}

extension EditWorkoutPopup : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


