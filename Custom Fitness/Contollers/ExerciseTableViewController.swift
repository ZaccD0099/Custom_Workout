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
    
    var exercises : List<Exercise>?
    var selectedWorkout : Workout?
    var selectedExercise : Exercise?
    
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
        
        //        for draggable cells:
        tableView.dragDelegate = self
        tableView.dragInteractionEnabled = true
        
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
            vc.delegate = self
        }
        
        if (segue.identifier == "goToEditExercise") {
            let vc = segue.destination as! EditExercisePopup
            vc.delegate = self
        }
    }
}

//MARK: - table view delegate methods
extension ExerciseTableViewController : UITableViewDelegate, UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, dragSessionWillBegin session: UIDragSession) {
        print("drag sesh started")
    }
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let dragItem = UIDragItem(itemProvider: NSItemProvider())
        
        dragItem.localObject = exercises?[indexPath.row]
        return [ dragItem ]
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // Update the model
        if let exercises = exercises {
            let mover : Exercise = exercises[sourceIndexPath.row]
            
            exercises.remove(at: sourceIndexPath.row)
            
            exercises.insert(mover, at: destinationIndexPath.row)
            
            for (index, exercise) in exercises.enumerated() {
                
                do {
                    try realm.write({
                        exercise.order = index
                    })
                } catch {
                    print("error setting exercise order \(error)")
                }
                
            }
        }
    }
}

//MARK: - table view datasource methods
extension ExerciseTableViewController : UITableViewDataSource, ActivityCellDelegate {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
//    Can also do leadingSwipActions for other direction
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { deleteAction, view, handler in
            if let currentExercise = self.exercises?[indexPath.row] {
                do {
                    try self.realm.write({
                        self.realm.delete(currentExercise)
                    })
                } catch {
                    print("error in swiping row \(error)")
                }
                self.loadExercises()
            }
        }
//        Adds image above text
        deleteAction.image = UIGraphicsImageRenderer(size: CGSize(width: 30, height: 40)).image {
            _ in UIImage(named: "trash_icon_dark")!.draw(in: CGRect(x: 0, y: 0, width: 30, height: 40))
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { editAction, view, handler in
            if let selectedWorkout = self.selectedWorkout {
                self.selectedExercise = selectedWorkout.workoutExcercises[indexPath.row]
                self.performSegue(withIdentifier: "goToEditExercise", sender: self)
            }
        }
        
        editAction.image = UIGraphicsImageRenderer(size: CGSize(width: 40, height: 40)).image {
            _ in UIImage(named: "edit_icon_dark")!.draw(in: CGRect(x: 0, y: 0, width: 40, height: 40))
        }
        
//        editAction.backgroundColor = UIColor(named: "activity_background")
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        
//        doesn't delete the cell if fully swiped.
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }

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
            
            cell.delegate = self
        }
        return cell
    }
    
    func tappedCheckButton(_ cell: ActivityCell, _ exercise: Exercise?) {
        if let exercise = exercise {
            do {
                try realm.write({
                    exercise.completed = !exercise.completed
                })
            } catch {
                print("error setting exercise complete \(error)")
            }
            cell.setCheckButton(exercise.completed)
        }
    }
}

//MARK: - Data Manipulation & Delegate
extension ExerciseTableViewController : AddExercisePopupProtocol, EditWorkoutPopupDelegate {
    
    func getExercise() -> Exercise? {
        return selectedExercise
    }
    
    func updateExercise(_ saveableExercise: Exercise?) {
        
        if let exercise = saveableExercise {
            do {
                try realm.write {
                    realm.add(exercise, update: .modified)
                }
            } catch {
                print("error saving updating exercise \(error)")
            }
        }
    }
    
    func loadExercises() {
        if let selectedWorkout = selectedWorkout {
            let exercisesResults = selectedWorkout.workoutExcercises.sorted(byKeyPath: "order", ascending: true)
            
            exercises = exercisesResults.reduce(List<Exercise>()) { (list, element) -> List<Exercise> in
                list.append(element)
                return list
            }
            tableView.reloadData()
            print("reloaded table")
        }
    }
    
    func addExercise(_ newExercise: Exercise) {
        do {
            try realm.write({
                selectedWorkout?.workoutExcercises.append(newExercise)
                print("added item")
            })
        } catch {
            print("error adding exercise \(error)")
        }
    }
}

