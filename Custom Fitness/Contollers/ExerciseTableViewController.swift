//
//  ActivityTableViewController.swift
//  Custom Fitness
//
//  Created by Zach Davis on 7/27/22.
//

import UIKit
import RealmSwift

class ExerciseTableViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let realm = try! Realm()
    
    var exercises : Results<Exercise>?
    
    var selectedWorkout : Workout?
     
    let cellNibName = "ActivityCell"
    let cellReuseID = "activityCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        setting navbar UI
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor(named: "custom_dark")
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: cellNibName, bundle: nil), forCellReuseIdentifier: cellReuseID)
        
        if selectedWorkout != nil {
            loadExercises()
        }
    }
    

    //MARK: - reset action
    
    @IBAction func resetButtonPressed(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Reset Workout", message: "Are you sure you want to reset all progress?", preferredStyle: .alert)
        
        let resetAction = UIAlertAction(title: "Reset", style: .default) { (action) in
//            reset workout code here
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
//            cancel action code here
        }
        
        alert.addAction(resetAction)
        
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: - Adding workouts popup segue
    
    @IBAction func addWorkoutButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "popupAddExercise", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "popupAddExercise") {
            let vc = segue.destination as! AddExercisePopup
            vc.exerciseViewController = self
            vc.selectedWorkout = self.selectedWorkout
        }
    }
    
    //MARK: - Data Manipulation
    
    func loadExercises() {
//        change sorting later

        exercises = selectedWorkout?.workoutExcercises.sorted(byKeyPath: "name", ascending: true)

        tableView.reloadData()
    }

}

//MARK: - table view delegate methods
extension ExerciseTableViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}


//MARK: - table view datasource methods
extension ExerciseTableViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let exerciseCount = exercises?.count {
            if exerciseCount != 0 {
                return exerciseCount
            }
        }

        return 0
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseID, for: indexPath) as! ActivityCell
        
        if let currentExercise = exercises?[indexPath.row] {
            
            cell.cellExercise = currentExercise
            cell.setCheckButton(currentExercise.completed)
            cell.activityTitle.text = currentExercise.name
            cell.addCellDetails(currentExercise.duration, currentExercise.sets, currentExercise.reps)
        }
        
        return cell
    }
}
