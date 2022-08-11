//
//  AddWorkoutFormViewController.swift
//  Custom Fitness
//
//  Created by Zach Davis on 7/29/22.
//

import UIKit
import RealmSwift

protocol AddWorkoutPopupProtocol {
    func saveWorkout(_ selectedWorkout : Workout?)
    func loadWorkouts()
}

class AddWorkoutPopup: UIViewController{
    
    let realm = try! Realm()

    var delegate : AddWorkoutPopupProtocol?
    
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet var backgroundView: UIView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var typeTextField: UITextField!
    @IBOutlet weak var durationTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        popUpView.layer.cornerRadius = 15.0
        popUpView.layer.borderWidth = 1.0
        popUpView.layer.borderColor = UIColor(named: "custom_dark")?.cgColor
        
        self.hideKeyboardWhenTappedAround()
        
//        for Keyboard Mgmt (UITextFieldDelegate)
        nameTextField.delegate = self
        typeTextField.delegate = self
        durationTextField.delegate = self
        
        durationTextField.keyboardType = .numberPad
    }
    
//    get the first touch and if it is the background it will dismiss this view.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            let touch = touches.first
            if touch?.view == self.backgroundView {
                self.dismiss(animated: true, completion: nil)
            }
        }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        
        addWorkout()
        
        print("1")
          //before dismissing the ViewController, passed the data inside the closure. used because viewwillappear will not fire on popover dismissal
        dismiss(animated: true) {
            self.delegate?.loadWorkouts()
        }
        
    }
    
    
    //MARK: - Data Manipualtion Methods
    
    func addWorkout(){
        let newWorkout = Workout()
        
        newWorkout.title = nameTextField.text ?? ""
        newWorkout.type = typeTextField.text ?? ""
        newWorkout.duration = Int(durationTextField.text!) ?? 0
        
        delegate?.saveWorkout(newWorkout)
    }


//MARK: - Keyboard Management
func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

@objc func dismissKeyboard() {
    view.endEditing(true)
    }
}

extension AddWorkoutPopup : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    
}




