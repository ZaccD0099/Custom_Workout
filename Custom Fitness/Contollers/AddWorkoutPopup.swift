//
//  AddWorkoutFormViewController.swift
//  Custom Fitness
//
//  Created by Zach Davis on 7/29/22.
//

import UIKit
import RealmSwift

class AddWorkoutPopup: UIViewController {
    
    let realm = try! Realm()
//
    var workoutViewCollection : WorkoutCollectionViewController?
    
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

    }
    
//    get the first touch and if it is the background it will dismiss this view
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
        {
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
            self.workoutViewCollection?.loadWorkouts()
        }
        
    }
    
    
    //MARK: - Data Manipualtion Methods
    
    func addWorkout(){
        
        let newWorkout = Workout()
        
        newWorkout.title = nameTextField.text ?? ""
        newWorkout.type = typeTextField.text ?? ""
        
        let durationInt : Int = Int(durationTextField.text!) ?? 0
        newWorkout.duration = durationInt
        
        do {
            try realm.write({
                realm.add(newWorkout)
            })
        } catch {
            print("error adding new workout \(error)")
        }
        
    }
    
}

