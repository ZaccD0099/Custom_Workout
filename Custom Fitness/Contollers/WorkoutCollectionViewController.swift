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

class WorkoutCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    

    let realm = try! Realm()
    
    var workouts : Results<Workout>?
    
    var selectedWorkoutIP : Int?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let celldentifier = "WorkoutCell"

    let cellName = "WorkoutCollectionViewCell"
    
    var cellSelectedWorkout : Workout?
    

    @IBOutlet weak var barButtonItem: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.dataSource = self
        collectionView?.delegate = self

//        view.addSubview(collectionView!)
        
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
    
    func pullEditWorkoutScreen(cellWorkout : Workout) {
        
        cellSelectedWorkout = cellWorkout
        
        performSegue(withIdentifier: "popupEditWorkout", sender: self)
        

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "popupAddWorkout") {
            let vc = segue.destination as! AddWorkoutPopup
            vc.workoutViewCollection = self
        }
        
        if (segue.identifier == "goToActivity") {
            let vc = segue.destination as! ExerciseTableViewController
            
            if let indexPathRow = selectedWorkoutIP {
                print(indexPathRow)
                vc.selectedWorkout = workouts?[indexPathRow]
            }
            
        }
        
        if(segue.identifier == "popupEditWorkout") {
            let vc = segue.destination as! EditWorkoutPopup
            
            if let cellSelectedWorkout = cellSelectedWorkout {
                vc.cellSelectedWorkout = cellSelectedWorkout
                vc.workoutCollectionView = self
            }
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
        
        print("going cell ")
        let currentWorkout = workouts?[indexPath.row]
        
        cell.workoutTitleLabel.text = currentWorkout?.title
        
        cell.workoutType.text = currentWorkout?.type
        
        cell.WorkoutCollectionView = self
        cell.cellWorkout = currentWorkout
        
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
        print("cell detected")
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
    
    
    //MARK: - Data Manipulation Methods
    
    func loadWorkouts() {
        workouts = realm.objects(Workout.self)
        
        collectionView.reloadData()
    }
    
    
    

    
}
