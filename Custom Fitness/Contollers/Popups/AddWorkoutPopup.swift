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
        
        self.setupKeyboardHiding()
        
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
}

extension AddWorkoutPopup : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
}
