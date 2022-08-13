//
//  ActivityTableViewController.swift
//  Custom Fitness
//
//  Created by Zach Davis on 7/27/22.
//

import UIKit
import RealmSwift
import AVFoundation



class ExerciseTableViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var workoutTime: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    
    let realm = try! Realm()
    
    private var exercises : List<Exercise>?
    var selectedWorkout : Workout?
    private var selectedExercise : Exercise?
    
    private var player: AVAudioPlayer?
    private let cellNibName = "ActivityCell"
    private let cellReuseID = "activityCell"
    
    private var currentExerciseSet = false
    private var completedExercise = false
    private var currentExerciseIndex : IndexPath?
    
    private var workoutPlaying : Bool = false
    private var workoutCount : Int = 0
    weak var workoutTimer : Timer?
    
    private var currentExerciseCell : ActivityCell?
    private var exerciseCount : Int = 0
    private var completedIntervals = 0
    private var activeTime = true
    private var currentExc : Exercise?
    
    private var currentIntervalToComplete = 0
    private var currentActiveTime = 0
    private var currentRestTime = 0

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
        
        
//        Playing in background
//        do {
//            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers, .allowAirPlay])
//            print("Playback OK")
//            try AVAudioSession.sharedInstance().setActive(true)
//            print("Session is Active")
//        } catch {
//            print(error)
//        }
        
//        keeping audio playing as other apps play audio

        
        if selectedWorkout != nil {
            loadExercises()
        }
        

    }
    
    
    //MARK: - Add Exercise Button & Segue
    
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
    
    //MARK: - Play Pause, Reset Buttons
    
    @IBAction func playPausedButtonPressed(_ sender: UIButton) {
        workoutPlaying = !workoutPlaying
        
        if workoutPlaying {
            workoutTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(workoutCounter), userInfo: nil, repeats: true)
            playPauseButton.setBackgroundImage(UIImage(named: "pause_icon_dark"), for: .normal)
        }
        else {
            workoutTimer?.invalidate()
            playPauseButton.setBackgroundImage(UIImage(named: "play_icon_dark"), for: .normal)
        }
    }
    
    @IBAction func resetButtonPressed(_ sender: UIButton) {
        print("running")
        let resetAlert = UIAlertController(title: "Reset Workout", message: "Are you sure you want to reset all progress?", preferredStyle: .alert)
        
        let resetAction = UIAlertAction(title: "Reset", style: .default) { (action) in
//            resets overall workout time
            self.workoutCount = 0
            let time = self.secondsToHoursMinutesSeconds(self.workoutCount)
            let timeString = self.makeLongTimeString(time.0, time.1, time.2)
            self.workoutTime.text = timeString
            
//            reseting all exercises in the workout to incomplete status
            if let exercises = self.exercises {
                for exercise in exercises {
                    do {
                        try self.realm.write({
                            exercise.completed = false
                            
                            if exercise.current{
                                exercise.current = false
                                self.currentExerciseSet = false
                            }
                        })
                    } catch {
                        print("error reseting workout \(error)")
                    }
                }
                self.loadExercises()
            }
        }
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            //            cancel action code here
        }
        
        resetAlert.addAction(resetAction)
        resetAlert.addAction(cancelAction)
        present(resetAlert, animated: true, completion: nil)
    }
    
    //MARK: - Timer Methods
    
    @objc func workoutCounter() -> Void {
        self.workoutCount += 1
        let time = secondsToHoursMinutesSeconds(workoutCount)
        let timeString = makeLongTimeString(time.0, time.1, time.2)
        workoutTime.text = timeString
        
        if currentExc?.type == ExerciseType.interval.rawValue {
            exerciseIntervalCounter()
        }
        else if currentExc?.type == ExerciseType.singleDuration.rawValue {
            exerciseDurationCounter()
        }
    }
    
    func exerciseIntervalCounter() {
        exerciseCount += 1
        
        
//        setting default times to total interval times so when one is counting the other is sitting at the total time not 0
        let restTime = secondsToMinutesSeconds(currentRestTime)
        let defaultRestString = makeShortTimeString(restTime.0, restTime.1)
        
        let excTime = secondsToMinutesSeconds(currentActiveTime)
        let defaultExcString = makeShortTimeString(excTime.0, excTime.1)

        
        let completedIntervalsString = "\(completedIntervals)/\(currentIntervalToComplete) intervals completed"
        
        if let currentExerciseCell = currentExerciseCell {
            if activeTime {
                let activeTimeLeft = currentActiveTime - exerciseCount
                let excTime = secondsToMinutesSeconds(activeTimeLeft)
                let excTimeString = makeShortTimeString(excTime.0, excTime.1)
                
                let fullString = "\(completedIntervalsString)\n\(excTimeString) On - \(defaultRestString) Off"
                currentExerciseCell.activityDetails.text = fullString
                
                if exerciseCount == currentActiveTime {
                    exerciseCount = 0
                    activeTime = false
                    playSound(K.soundEffects.startSoundOne)
                }
            }
            else if activeTime == false {
                
                let restTimeLeft = currentRestTime - exerciseCount
                let restTime = secondsToMinutesSeconds(restTimeLeft)
                let restTimeString = makeShortTimeString(restTime.0, restTime.1)
                
                let fullString = "\(completedIntervalsString)\n\(defaultExcString) On - \(restTimeString) Off"
                currentExerciseCell.activityDetails.text = fullString
                
                if exerciseCount == currentRestTime {
                    exerciseCount = 0
                    activeTime = true
                    completedIntervals += 1
                    playSound(K.soundEffects.endSoundOne)
                }
            }
        }
        
        if completedIntervals == currentIntervalToComplete {
            completedIntervals = 0
            
            if let currentExc = currentExc {
                do {
                    try realm.write({
                        currentExc.completed = true
                        currentExc.current = false
                    })
                } catch {
                    print("error completing interval exercise \(error)")
                }
            }
            currentExerciseSet = false
            resetCounterAndVariables()
            loadExercises()
        }
    }
    
//    counting down in this one, different from above that is counting up - to test and see which is better
    func exerciseDurationCounter() {
        exerciseCount += 1
        
        let timeLeft = (currentActiveTime - exerciseCount)

        if timeLeft >= 0 {
            let timesLeft = secondsToMinutesSeconds(timeLeft)
            let timeLeftString = makeShortTimeString(timesLeft.0, timesLeft.1)
            
            let totalTime = secondsToMinutesSeconds(currentActiveTime)
            let totalTimeString = makeShortTimeString(totalTime.0, totalTime.1)
            
            let fullString = "\(timeLeftString)/\(totalTimeString)"
            
            if let currentExerciseCell = currentExerciseCell {
                currentExerciseCell.activityDetails.text = String(fullString)
            }
        }
        
        else if timeLeft < 0 {
            if let currentExc = currentExc {
                do {
                    try realm.write({
                        currentExc.completed = true
                        currentExc.current = false
                    })
                } catch {
                    print("error completing interval exercise \(error)")
                }
            }
            playSound(K.soundEffects.startSoundOne)
            currentExerciseSet = false
            resetCounterAndVariables()
            loadExercises()
            
        }
    }
    
    func resetCounterAndVariables() {
        completedIntervals = 0
        activeTime = true
        currentIntervalToComplete = 0
        currentActiveTime = 0
        currentRestTime = 0
        exerciseCount = 0
    }
        
    //MARK: - Time String Conversion Methods
    func secondsToHoursMinutesSeconds(_ seconds : Int) -> (Int, Int, Int) {
        return ( seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60 )
    }
    
    func secondsToMinutesSeconds(_ seconds : Int) -> (Int, Int) {
        return ( seconds / 60, seconds % 60 )
    }
    
    func makeShortTimeString (_ minutes : Int = 0, _ seconds : Int = 0) -> String {
        var timeString = ""
        
        timeString += String(format: "%02d", minutes)
        timeString += ":"
        timeString += String(format: "%02d", seconds)
        
        return timeString
    }
    
    func makeLongTimeString (_ hours : Int, _ minutes : Int, _ seconds : Int) -> String {
        var timeString : String = ""
        
        timeString += String(format: "%02d", hours)
        timeString += ":"
        timeString += String(format: "%02d", minutes)
        timeString += ":"
        timeString += String(format: "%02d", seconds)
        
        return timeString
    }
    
    
    //MARK: - play sound method
    
    func playSound(_ soundName: String) {
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "wav") else { return }

        do {
//            .mixOthers in options plays audio without turning other apps down.
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.duckOthers])
            try AVAudioSession.sharedInstance().setActive(true)

            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)

            guard let player = player else { return }

            player.play()

        } catch let error {
            print(error.localizedDescription)
        }
    }
}

//MARK: - table view delegate methods
extension ExerciseTableViewController : UITableViewDelegate, UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, dragSessionWillBegin session: UIDragSession) {

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
            
            let deleteAlert = UIAlertController(title: "Delete Exercise", message: "Are you sure you want to delete this exercise?", preferredStyle: .alert)
            
            let confirmAction = UIAlertAction(title: "Delete", style: .destructive) { action in
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
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .default)
            
            deleteAlert.addAction(cancelAction)
            deleteAlert.addAction(confirmAction)
            self.present(deleteAlert, animated: true)
        }
//        Adds image above text
        deleteAction.image = UIGraphicsImageRenderer(size: CGSize(width: 30, height: 40)).image {
            _ in UIImage(named: "trash_icon_dark")!.draw(in: CGRect(x: 0, y: 0, width: 30, height: 40))
        }
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { editAction, view, handler in
            
            if let exercises = self.exercises {
                self.selectedExercise = exercises[indexPath.row]
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
            cell.setCellUI()
            cell.activityTitle.text = currentExercise.name
            cell.delegate = self
            
            setCellDetails(currentExercise, cell)
            
            if currentExercise.current {
                currentExerciseIndex = indexPath
                currentExc = currentExercise
                currentExerciseCell = cell
                
                if currentExercise.type == ExerciseType.interval.rawValue {
                    currentActiveTime = currentExercise.intervalActiveTime
                    currentRestTime = currentExercise.intervalRestTime
                    currentIntervalToComplete = currentExercise.intervals
                }
                
                else if currentExercise.type == ExerciseType.singleDuration.rawValue {
                    currentActiveTime = currentExercise.duration
                }
            }
        }
        return cell
    }
    
    func setCellDetails(_ currentExercise : Exercise, _ cell : ActivityCell) {
        switch currentExercise.type {
        case ExerciseType.interval.rawValue:
            if currentExercise.completed {
                cell.addIntervalDetails(currentExercise.intervals, currentExercise.intervalActiveTime, currentExercise.intervalRestTime, currentExercise.intervals)
            }
            else {
                cell.addIntervalDetails(currentExercise.intervals, currentExercise.intervalActiveTime, currentExercise.intervalRestTime, completedIntervals)
            }
        case ExerciseType.setsReps.rawValue:
            cell.addSetRepsDetails(currentExercise.sets, currentExercise.reps)
        case ExerciseType.singleDuration.rawValue:
            cell.addSingleDurationDetails(currentExercise.duration)
        default:
            cell.activityDetails.text = ""
        }
    }
    
    func tappedCheckButton(_ cell: ActivityCell, _ exercise: Exercise?) {
        if let exercise = exercise {
            do {
                try realm.write({
                    exercise.completed = !exercise.completed
                    
                    if exercise.current && exercise.completed {
                        exercise.current = false
                        currentExerciseSet = false
                        resetCounterAndVariables()
                        currentExerciseCell = nil
                    }
                })
            } catch {
                print("error setting exercise complete \(error)")
            }
            
            loadExercises()
        }
    }
}

//MARK: - Data Manipulation & Delegate
extension ExerciseTableViewController : AddExercisePopupProtocol, EditExercisePopupProtocol {
    
    func getExercise() -> Exercise? {
        return selectedExercise
    }
    
    func updateExercise(_ selectedExercise : Exercise, _ name : String, _ duration : Int, _ sets : Int, _ reps : Int, _ intervals : Int, _ intervalActiveTime : Int, _ intervalRestTime : Int) {
            do {
                try realm.write {
                    selectedExercise.name = name
                    selectedExercise.duration = duration
                    selectedExercise.sets = sets
                    selectedExercise.reps = reps
                    selectedExercise.intervals = intervals
                    selectedExercise.intervalActiveTime = intervalActiveTime
                    selectedExercise.intervalRestTime = intervalRestTime
                }
            } catch {
                print("error saving updating exercise \(error)")
            }
    }
    
    func loadExercises() {
        if let selectedWorkout = selectedWorkout {
            let exercisesResults = selectedWorkout.workoutExcercises.sorted(byKeyPath: "order", ascending: true)
            
            exercises = exercisesResults.reduce(List<Exercise>()) { (list, element) -> List<Exercise> in
                list.append(element)
                return list
            }
            setCurrentWorkout()
            tableView.reloadData()
//            forces table to update before continuing could also try dispatch async
            tableView.layoutIfNeeded()
            if let currentExerciseIndex = currentExerciseIndex  {
                print("Index from load exercise: \(currentExerciseIndex)")
                tableView.scrollToRow(at: currentExerciseIndex, at: .top, animated: true)
            }
            currentExerciseIndex = nil
        }
    }
    
    func addExercise(_ newExercise: Exercise) {
        do {
            try realm.write({
                selectedWorkout?.workoutExcercises.append(newExercise)
            })
        } catch {
            print("error adding exercise \(error)")
        }
    }
    
    func setCurrentWorkout() {
        if let exercises = exercises {
            for exercise in exercises {
//                if the exercise is already set - this avoids 2 highlighted cell both being current exercise
                if exercise.current {
                    currentExerciseSet = true
                }
//                sets the next incomplete exercise to current exercise and toggle exerciseSet
                else if exercise.completed == false && currentExerciseSet == false {
                    currentExerciseSet = true
                    do {
                        try realm.write({
                            exercise.current = true
                        })
                    } catch {
                        print("error setting current exercise \(error)")
                    }
                    return
                }
            }
//            there is neither a current exercise set or an incomplete exercise to set as current, meaning all exercises are completed
            completedExercise = true
            workoutPlaying = false
            workoutTimer?.invalidate()
            playPauseButton.setBackgroundImage(UIImage(named: "play_icon_dark"), for: .normal)
        }
    }
}
