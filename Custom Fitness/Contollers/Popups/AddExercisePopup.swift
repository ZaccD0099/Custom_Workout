//
//  AddExercisePopup.swift
//  Custom Fitness
//
//  Created by Zach Davis on 7/29/22.
//

import UIKit
import RealmSwift

protocol AddExercisePopupProtocol {
    func addExercise(_ newExercise: Exercise)
    func loadExercises()
}

class AddExercisePopup: UIViewController {
    
    let realm = try! Realm()
    var delegate : AddExercisePopupProtocol?
    
    @IBOutlet var backgroundView: UIView!
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var durationTextField: UITextField!
    @IBOutlet weak var setsTextField: UITextField!
    @IBOutlet weak var repsTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        popUpView.layer.cornerRadius = 15.0
        popUpView.layer.borderWidth = 1.0
        popUpView.layer.borderColor = UIColor(named: "custom_dark")?.cgColor
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
        newExercise.duration = Int(durationTextField.text!) ?? 0
        newExercise.sets = Int(setsTextField.text!) ?? 0
        newExercise.reps = Int(repsTextField.text!) ?? 0
        
        delegate?.addExercise(newExercise)
        
        self.dismiss(animated: true) {
            self.delegate?.loadExercises()
        }
    }
}
