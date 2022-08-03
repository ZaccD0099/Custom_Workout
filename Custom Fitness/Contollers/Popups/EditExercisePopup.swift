//
//  EditExercisePopup.swift
//  Custom Fitness
//
//  Created by Zach Davis on 8/2/22.
//

import UIKit
import RealmSwift

class EditExercisePopup: UIViewController {
    
    let realm = try! Realm()
    
    var exerciseViewController : ExerciseTableViewController?
    var selectedExercise : Exercise?
    
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet var backgroundView: UIView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var durationTextField: UITextField!
    @IBOutlet weak var setsTextField: UITextField!
    @IBOutlet weak var repsTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTextFields()
        
        popUpView.layer.cornerRadius = 15.0
        popUpView.layer.borderWidth = 1.0
        popUpView.layer.borderColor = UIColor(named: "custom_dark")?.cgColor
    }
    
    
    
    @IBAction func saveChangesPressed(_ sender: UIButton) {
        saveExerciseChanges()
        
        dismiss(animated: true) {
            self.exerciseViewController?.loadExercises()
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
    
    
    func saveExerciseChanges() {
        
        if let selectedExercise = selectedExercise {
            
            do {
                try realm.write({
                    selectedExercise.name = nameTextField.text ?? ""
                    selectedExercise.duration = Int(durationTextField.text!) ?? 0
                    selectedExercise.sets = Int(setsTextField.text!) ?? 0
                    selectedExercise.reps = Int(repsTextField.text!) ?? 0
                })
            }
            catch {
                print("error savinf exercise edits \(error)")
            }
        }
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
        {
            let touch = touches.first
            if touch?.view == self.backgroundView {
                self.dismiss(animated: true, completion: nil)
            }
        }
    
    
    
    
}
