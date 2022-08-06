//
//  EditExercisePopup.swift
//  Custom Fitness
//
//  Created by Zach Davis on 8/2/22.
//

import UIKit
import RealmSwift
import DropDown

protocol EditWorkoutPopupDelegate {
    func getExercise() -> Exercise?
    func loadExercises()
    func updateExercise(_ saveableExercise : Exercise?)
}

class EditExercisePopup: UIViewController {
    
    let realm = try! Realm()
    
    var delegate : EditWorkoutPopupDelegate?
    
    var selectedExercise : Exercise?
    
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet var backgroundView: UIView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var durationTextField: UITextField!
    @IBOutlet weak var setsTextField: UITextField!
    @IBOutlet weak var repsTextField: UITextField!
    
    //MARK: - dropdown
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        popUpView.layer.cornerRadius = 15.0
        popUpView.layer.borderWidth = 1.0
        popUpView.layer.borderColor = UIColor(named: "custom_dark")?.cgColor
        
        selectedExercise = delegate?.getExercise()
        setTextFields()
    }
    

    
    
    @IBAction func saveChangesPressed(_ sender: UIButton) {
        if let selectedExercise = selectedExercise {
            selectedExercise.name = nameTextField.text ?? ""
            selectedExercise.duration = Int(durationTextField.text!) ?? 0
            selectedExercise.sets = Int(setsTextField.text!) ?? 0
            selectedExercise.reps = Int(repsTextField.text!) ?? 0
            
            delegate?.updateExercise(selectedExercise)
        }
        
        dismiss(animated: true) {
            self.delegate?.loadExercises()
        }
    }
    
    
    func setTextFields() {
        if let selectedExercise = selectedExercise {
            nameTextField.text = selectedExercise.name
            durationTextField.text = String(selectedExercise.duration)
            setsTextField.text = String(selectedExercise.sets)
            repsTextField.text = String(selectedExercise.reps)
        }
    }


//    dismisses popup when press out main view
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
        {
            let touch = touches.first
            if touch?.view == self.backgroundView {
                self.dismiss(animated: true, completion: nil)
            }
        }
    
    
    
    
}
