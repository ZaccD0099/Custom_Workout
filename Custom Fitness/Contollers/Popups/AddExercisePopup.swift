//
//  AddExercisePopup.swift
//  Custom Fitness
//
//  Created by Zach Davis on 7/29/22.
//

import UIKit
import RealmSwift
import DropDown

protocol AddExercisePopupProtocol {
    func addExercise(_ newExercise: Exercise)
    func loadExercises()
}

class AddExercisePopup: UIViewController {
    
    let realm = try! Realm()
    var delegate : AddExercisePopupProtocol?
    
    @IBOutlet weak var selectedTypeLabel: UILabel!
    @IBOutlet weak var exerciseTypeDropdown: UIView!
    @IBOutlet var backgroundView: UIView!
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var nameTextField: UITextField!

    @IBOutlet weak var setsTextField: UITextField!
    @IBOutlet weak var repsTextField: UITextField!
    
    @IBOutlet weak var durationMinTextField: UITextField!
    @IBOutlet weak var durationSecTextField: UITextField!
    
    @IBOutlet weak var intervalNumField: UITextField!
    @IBOutlet weak var intervalActiveMinField: UITextField!
    @IBOutlet weak var intervalActiveSecField: UITextField!
    @IBOutlet weak var intervalRestMinField: UITextField!
    @IBOutlet weak var intervalRestSecField: UITextField!
    
    @IBOutlet weak var durationFields: UIStackView!
    @IBOutlet weak var setRepsFields: UIStackView!
    @IBOutlet weak var intervalFields: UIStackView!
    
    let menu: DropDown = {
        let menu = DropDown()
        menu.dataSource = [
            ExerciseType.singleDuration.rawValue,
            ExerciseType.setsReps.rawValue,
            ExerciseType.interval.rawValue
        ]
        return menu
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        popUpView.layer.cornerRadius = 15.0
        popUpView.layer.borderWidth = 1.0
        popUpView.layer.borderColor = UIColor(named: "custom_dark")?.cgColor
        
        menu.anchorView = exerciseTypeDropdown
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapDropdown))
        gesture.numberOfTouchesRequired = 1
        gesture.numberOfTapsRequired = 1
        exerciseTypeDropdown.addGestureRecognizer(gesture)
        
        menu.selectionAction = {index, title in
            self.selectedTypeLabel.text = title
            self.selectedTypeLabel.textColor = .black
            self.setupTypeView(title)
        }
        
//        removes all ui specific to an exercise type until it is set
        setupTypeView("hideAll")
    }
    

    @objc func didTapDropdown() {
        menu.show()
    }

    //    get the first touch and if it is the background it will dismiss this view
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            let touch = touches.first
            if touch?.view == self.backgroundView {
                self.dismiss(animated: true, completion: nil)
            }
        }
    
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        
        let newExercise = Exercise()
        newExercise.name = nameTextField.text ?? ""
        newExercise.duration = minutesSecondsToSeconds(durationMinTextField.text!, durationSecTextField.text!)
        newExercise.sets = Int(setsTextField.text!) ?? 0
        newExercise.reps = Int(repsTextField.text!) ?? 0
        newExercise.intervals = Int(intervalNumField.text!) ?? 0
        newExercise.intervalActiveTime = minutesSecondsToSeconds(intervalActiveMinField.text!, intervalActiveSecField.text!)
        newExercise.intervalRestTime = minutesSecondsToSeconds(intervalRestMinField.text!, intervalRestSecField.text!)
        
        if let typeText = selectedTypeLabel.text {
//            not sure how to replace the placeholder here so making logic conform to it: "Select Type" is placeholder
            if typeText != "Select Type"{
                newExercise.type = typeText
            }
            else {
                newExercise.type = nil
            }
        }
        
        delegate?.addExercise(newExercise)
        
        self.dismiss(animated: true) {
            self.delegate?.loadExercises()
        }
    }
    
//    hiding or unhiding ui elements relating to the exercise type
    func setupTypeView(_ exerciseType : String) {
        switch exerciseType {
        case ExerciseType.setsReps.rawValue:
            durationFields.isHidden = true
            intervalFields.isHidden = true
            setRepsFields.isHidden = false
        case ExerciseType.singleDuration.rawValue:
            durationFields.isHidden = false
            intervalFields.isHidden = true
            setRepsFields.isHidden = true
        case ExerciseType.interval.rawValue:
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
    
    func minutesSecondsToSeconds(_ minutes : String, _ seconds : String) -> Int {
        let minutesToSeconds = (Int(minutes) ?? 0) * 60
        let secondsToInt = Int(seconds) ?? 0
        let totalSeconds = minutesToSeconds + secondsToInt
        
        return totalSeconds
    }
}
