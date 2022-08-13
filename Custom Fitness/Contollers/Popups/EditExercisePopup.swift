//
//  EditExercisePopup.swift
//  Custom Fitness
//
//  Created by Zach Davis on 8/2/22.
//

import UIKit
import RealmSwift
import DropDown

protocol EditExercisePopupProtocol {
    func getExercise() -> Exercise?
    func loadExercises()
    func updateExercise(_ selectedExercise : Exercise, _ name : String, _ duration : Int, _ sets : Int, _ reps : Int, _ intervals : Int, _ intervalActiveTime : Int, _ intervalRestTime : Int)
}

class EditExercisePopup: UIViewController {
    
    let realm = try! Realm()
    var delegate : EditExercisePopupProtocol?
    private var selectedExercise : Exercise?
    
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet var backgroundView: UIView!
    @IBOutlet weak var nameTextField: UITextField!

    @IBOutlet weak var durationFields: UIStackView!
    @IBOutlet weak var setRepsFields: UIStackView!
    @IBOutlet weak var intervalFields: UIStackView!
    
    @IBOutlet weak var durationMinField: UITextField!
    @IBOutlet weak var durationSecField: UITextField!

    @IBOutlet weak var setsTextField: UITextField!
    @IBOutlet weak var repsTextField: UITextField!
    
    @IBOutlet weak var intervalsField: UITextField!
    @IBOutlet weak var activeMinField: UITextField!
    @IBOutlet weak var activeSecField: UITextField!
    @IBOutlet weak var restMinField: UITextField!
    @IBOutlet weak var restSecField: UITextField!
    
    
    //MARK: - Dropdown
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupKeyboardHiding()
        
        popUpView.layer.cornerRadius = 15.0
        popUpView.layer.borderWidth = 1.0
        popUpView.layer.borderColor = UIColor(named: "custom_dark")?.cgColor
        
        selectedExercise = delegate?.getExercise()
        setTextFields()
        
//        for keyboard management (UITextFieldDelegate)
        self.hideKeyboardWhenTappedAround()
        nameTextField.delegate = self
        setsTextField.delegate = self
        repsTextField.delegate = self
        durationMinField.delegate = self
        durationSecField.delegate = self
        intervalsField.delegate = self
        activeMinField.delegate = self
        activeSecField.delegate = self
        restMinField.delegate = self
        restSecField.delegate = self
        
//        setting numbers keypad for necessary text fields
        setsTextField.keyboardType = .numberPad
        repsTextField.keyboardType = .numberPad
        durationMinField.keyboardType = .numberPad
        durationSecField.keyboardType = .numberPad
        intervalsField.keyboardType = .numberPad
        activeMinField.keyboardType = .numberPad
        activeSecField.keyboardType = .numberPad
        restMinField.keyboardType = .numberPad
        restSecField.keyboardType = .numberPad
    }
    
    @IBAction func saveChangesPressed(_ sender: UIButton) {
        if let selectedExercise = selectedExercise {
            let name = nameTextField.text ?? ""
            let duration = minutesSecondsToSeconds(durationMinField.text!, durationSecField.text!)
            let sets = Int(setsTextField.text!) ?? 0
            let reps = Int(repsTextField.text!) ?? 0
            let intervals = Int(intervalsField.text!) ?? 0
            let intervalActiveTime = minutesSecondsToSeconds(activeMinField.text!, activeMinField.text!)
            let intervalRestTime = minutesSecondsToSeconds(restMinField.text!, restSecField.text!)
            
            delegate?.updateExercise(selectedExercise, name, duration, sets, reps, intervals, intervalActiveTime, intervalRestTime)
        }
        
        dismiss(animated: true) {
            self.delegate?.loadExercises()
        }
    }
    
    func setTextFields() {
        if let selectedExercise = selectedExercise {
            
            let activeTimes = secondsToMinutesSeconds(selectedExercise.intervalActiveTime)
            let restTimes = secondsToMinutesSeconds(selectedExercise.intervalRestTime)
            let durationTimes = secondsToMinutesSeconds(selectedExercise.duration)
            
            nameTextField.text = selectedExercise.name
            
            switch selectedExercise.type {
            case ExerciseType.setsReps.rawValue:
                setsTextField.text = String(selectedExercise.sets)
                repsTextField.text = String(selectedExercise.reps)
                durationFields.isHidden = true
                intervalFields.isHidden = true
                setRepsFields.isHidden = false
            case ExerciseType.singleDuration.rawValue:
                durationMinField.text = String(durationTimes.0)
                durationSecField.text = String(durationTimes.1)
                durationFields.isHidden = false
                intervalFields.isHidden = true
                setRepsFields.isHidden = true
            case ExerciseType.interval.rawValue:
                
                intervalsField.text = String(selectedExercise.intervals)
                activeMinField.text = String(activeTimes.0)
                activeSecField.text = String(activeTimes.1)
                restMinField.text = String(restTimes.0)
                restSecField.text = String(restTimes.1)
                durationFields.isHidden = true
                intervalFields.isHidden = false
                setRepsFields.isHidden = true
            case "hideAll":
                durationFields.isHidden = true
                intervalFields.isHidden = true
                setRepsFields.isHidden = true
            default:
                fatalError("could not set exercise type labels")
            }
        }
    }
    
    func minutesSecondsToSeconds(_ minutes : String, _ seconds : String) -> Int {
        let minutesToSeconds = (Int(minutes) ?? 0) * 60
        let secondsToInt = Int(seconds) ?? 0
        let totalSeconds = minutesToSeconds + secondsToInt
        
        return totalSeconds
    }
    
    func secondsToMinutesSeconds(_ seconds : Int) -> (Int, Int) {
        return (seconds / 60, seconds % 60)
    }

//    dismisses popup when press out main view
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            let touch = touches.first
            if touch?.view == self.backgroundView {
                self.dismiss(animated: true, completion: nil)
            }
        }
    //MARK: - Keyboard Mgmt. Methods
    
    private func setupKeyboardHiding() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private func hideKeyboardWhenTappedAround() {
            let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
            view.addGestureRecognizer(tap)
        }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
        }

    @objc private func keyboardWillShow(sender: NSNotification) {
        guard let userInfo = sender.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
              let currentTextField = UIResponder.currentFirst() as? UITextField else { return }


        // check if the top of the keyboard is above the bottom of the currently focused textbox
        let keyboardTopY = keyboardFrame.cgRectValue.origin.y
        let convertedTextFieldFrame = view.convert(currentTextField.frame, from: currentTextField.superview)
        let textFieldBottomY = convertedTextFieldFrame.origin.y + (convertedTextFieldFrame.size.height * 2)
        
//        print("foo - convertedTextFieldFrame: \(convertedTextFieldFrame.origin.y), textFieldBootomY: \(textFieldBottomY), keyboardTopY: \(keyboardTopY)")

        // if textField bottom is below keyboard bottom - bump the frame up
        if textFieldBottomY > keyboardTopY {
            print("if state true")
            let textBoxY = convertedTextFieldFrame.origin.y
            let newFrameY = (textBoxY - keyboardTopY / 1.5) * -1
            view.frame.origin.y = newFrameY
        }

    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension EditExercisePopup : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
