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
    private var selectedWorkout : Workout?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupKeyboardHiding()
        
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
        displayDeleteAlert()
    }
    
    func returnToWorkouts(){
        dismiss(animated: true) {
            self.delegate?.loadWorkouts()
        }
    }

    //MARK: - Keyboard Mgmt. Methods
    
    private func setupKeyboardHiding() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func hideKeyboardWhenTappedAround() {
            let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
            view.addGestureRecognizer(tap)
        }

    @objc func dismissKeyboard() {
        view.endEditing(true)
        }
    
    @objc func keyboardWillShow(sender: NSNotification) {
        guard let userInfo = sender.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
              let currentTextField = UIResponder.currentFirst() as? UITextField else { return }

        
        // check if the top of the keyboard is above the bottom of the currently focused textbox
        let keyboardTopY = keyboardFrame.cgRectValue.origin.y
        let convertedTextFieldFrame = view.convert(currentTextField.frame, from: currentTextField.superview)
        let textFieldBottomY = convertedTextFieldFrame.origin.y + (convertedTextFieldFrame.size.height * 2)


        // if textField bottom is below keyboard bottom - bump the frame up
        if textFieldBottomY > keyboardTopY {
            let textBoxY = convertedTextFieldFrame.origin.y
            let newFrameY = (textBoxY - keyboardTopY / 1.5) * -1
            view.frame.origin.y = newFrameY
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
    }
    
    
    func displayDeleteAlert() {
        let deleteWorkoutAlert = UIAlertController(title: "Delete Workout", message: "Are you sure you want to delete this workout?", preferredStyle: .alert)
        
        let deleteWorkoutAction = UIAlertAction(title: "Delete", style: .destructive, handler: { action in
            self.delegate?.removeWorkout(self.selectedWorkout)
            self.returnToWorkouts()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        
        deleteWorkoutAlert.addAction(cancelAction)
        deleteWorkoutAlert.addAction(deleteWorkoutAction)
        present(deleteWorkoutAlert, animated: true)
    }
}

extension EditWorkoutPopup : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


