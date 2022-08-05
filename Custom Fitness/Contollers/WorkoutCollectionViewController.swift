//
//  WorkoutCollectionViewController.swift
//  Custom Fitness
//
//  Created by Zach Davis on 7/27/22.
//

import UIKit
import RealmSwift

protocol workoutDataDelegate {
    func loadWorkouts()
}

class WorkoutCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, WorkoutCollectionViewCellProtocol{

    @IBOutlet weak var collectionView: UICollectionView!
    
    let realm = try! Realm()
    
    var workouts : Results<Workout>?
    var cellSelectedWorkout : Workout?
    var selectedWorkoutIP : Int?
    let celldentifier = "WorkoutCell"
    let cellName = "WorkoutCollectionViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.dataSource = self
        collectionView?.delegate = self
        collectionView?.register(UINib(nibName: cellName, bundle: nil), forCellWithReuseIdentifier: celldentifier)
        collectionView.collectionViewLayout = createLayout()
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor(named: "custom_dark")
//        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance

        loadWorkouts()
    }
    
    //MARK: - Navigation
    
    @IBAction func addWorkoutPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "popupAddWorkout", sender: self)
    }
    
    func pullEditWorkoutScreen() {
        performSegue(withIdentifier: "popupEditWorkout", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "popupAddWorkout") {
            let vc = segue.destination as! AddWorkoutPopup
            vc.delegate = self
        }
        
        if (segue.identifier == "goToActivity") {
            let vc = segue.destination as! ExerciseTableViewController
            
            if let indexPathRow = selectedWorkoutIP {
                print(indexPathRow)
                vc.selectedWorkout = workouts?[indexPathRow]
            }
        }
        if (segue.identifier == "popupEditWorkout") {
            let vc = segue.destination as! EditWorkoutPopup
            vc.delegate = self
        }
    }

    // MARK: UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return workouts?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: celldentifier, for: indexPath) as! WorkoutCollectionViewCell
        let currentWorkout = workouts?[indexPath.row]
        
        cell.delegate = self
        cell.cellWorkout = currentWorkout
        cell.workoutTitleLabel.text = currentWorkout?.title
        cell.workoutType.text = currentWorkout?.type
        
        let workoutDuration = String(currentWorkout?.duration ?? 0)
        
        if workoutDuration != "0" {
            cell.workoutDuration.text = workoutDuration
        }
        else {
            cell.workoutDuration.text = ""
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        should detect cell selected and segue to the workout
        selectedWorkoutIP = indexPath.row
        performSegue(withIdentifier: "goToActivity", sender: self)
    }
    
    
//    setting layout for cells
    func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                             heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalWidth(0.5))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        let spacing = CGFloat(20)
        group.interItemSpacing = .fixed(spacing)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 10, bottom: 0, trailing: 10)

        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}

//MARK: - Data Manipulation Methods

extension WorkoutCollectionViewController : EditWorkoutPopupProtocol, AddWorkoutPopupProtocol {
    
    func getWorkout() -> Workout? { return cellSelectedWorkout }
    
    func setSelectedWorkout(_ selectedWorkout : Workout) {
        cellSelectedWorkout = selectedWorkout
    }
    
    func loadWorkouts() {
        workouts = realm.objects(Workout.self)
        collectionView.reloadData()
    }
    
    func saveWorkout(_ selectedWorkout : Workout?) {
        if let updatedWorkout = selectedWorkout {
            do {
                try realm.write({
                    realm.add(updatedWorkout, update: .modified)
                })
            }
            catch {
                print("error updating workout \(error)")
            }
        }
    }
    
    func removeWorkout(_ selectedWorkout : Workout?) {
        if let removableWorkout = selectedWorkout {
            do {
                try realm.write({
                    realm.delete(removableWorkout)
                })
            }
            catch {
                print("error deleting a workout from popup \(error)")
            }
        }
    }
    
}
