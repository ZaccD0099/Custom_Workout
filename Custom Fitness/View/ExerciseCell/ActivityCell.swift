//
//  ActivityCell.swift
//  Custom Fitness
//
//  Created by Zach Davis on 7/27/22.
//

import UIKit
import RealmSwift


protocol ActivityCellDelegate : AnyObject {
    func tappedCheckButton(_ cell: ActivityCell, _ exercise : Exercise?)
}

class ActivityCell: UITableViewCell {
    
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var activityTitle: UILabel!
    @IBOutlet weak var activityDetails: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var checkboxImage: UIImageView!
    
    var realm = try! Realm()
    var cellExercise : Exercise?
    weak var delegate : ActivityCellDelegate?
    

    //    checkbox logic
    let checkedImage = UIImage(named: "checked_box_icon")! as UIImage
    let uncheckedImage = UIImage(named: "unchecked_box_icon")! as UIImage
    

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setCellUI() {
        if let exercise = cellExercise {
            if exercise.current {
                cellView.layer.backgroundColor = UIColor(named: "custom_green")?.cgColor
                cellView.layer.borderWidth = 1.5
            }
            else if exercise.completed {
                cellView.layer.backgroundColor = UIColor(named: "background")?.cgColor
                cellView.layer.borderWidth = 0.5
            }
            else {
                cellView.layer.backgroundColor = UIColor(.white).cgColor
                cellView.layer.borderWidth = 1.0
            }
        }
        cellView.layer.cornerRadius = 20
        cellView.layer.borderColor = UIColor(named: "custom_dark")?.cgColor


        // Configure the view for the selected state
    }
    
    func addSingleDurationDetails(_ duration: Int) {
        let timeString = secondsToTimeString(duration)
        
        let activityDetailsString = "Time: \(timeString)"
        
        activityDetails.text = activityDetailsString
    }
    
    func addIntervalDetails(_ intervals: Int, _ activityTime: Int, _ restTime: Int, _ completedIntervals : Int) {
        
        let activeTimeString = secondsToTimeString(activityTime)
        let restTimeString = secondsToTimeString(restTime)
        
        let activityDetailsString = "\(completedIntervals) / \(intervals) Completed \n\(activeTimeString) On - \(restTimeString) Off"
        
        
        activityDetails.text = activityDetailsString
    }
    
    func addSetRepsDetails(_ sets: Int, _ reps : Int) {
        let activityDetailsString = "Sets: \(sets) x Reps: \(reps)"
        
        activityDetails.text = activityDetailsString
    }

    @IBAction func checkButtonPressed(_ sender: Any) {
        
        delegate?.tappedCheckButton(self, cellExercise)
    }
    
    func setCheckButton(_ isComplete : Bool) {
        
        if isComplete {
            checkboxImage.image = UIImage(named: "checked_box_icon")
        }
        else {
            checkboxImage.image = UIImage(named: "unchecked_box_icon")
        }
    }
    
    func secondsToTimeString(_ seconds: Int) -> String {
        let minutesString = String(format: "%02d", seconds / 60)
        let secondsString = String(format: "%02d", seconds % 60)
        let timeString = "\(minutesString):\(secondsString)"
        return timeString
    }
    
    
    
 
}


