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
    
    var completedIntervals = 0
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

    
    func addCellDetails(_ durationInt: Int, _ setsInt: Int, _ repsInt : Int, _ intervalsInt : Int, _ activityTimeFloat: Float, _ restTimeFloat: Float, _ completedIntervalsInt : Int) {
        
        //        setting strings for the functions optional inputs to return correct string in cell
        var duration : String?
        var sets : String?
        var reps : String?
        var intervals : String?
        var activityTime : String?
        var restTime : String?
        let completedIntervals : String = String(completedIntervalsInt)
        
        if durationInt != 0 { duration = String(durationInt) }
        if setsInt != 0 { sets = String(setsInt) }
        if repsInt != 0 { reps = String(repsInt) }
        if intervalsInt != 0 { intervals = String(intervalsInt) }
        if activityTimeFloat != 0.0 { activityTime = String(activityTimeFloat) }
        if restTimeFloat != 0 { restTime = String(restTimeFloat) }

        
        
        //        logic to determine contents and format of the cells details
        var activityDetailsString : String = ""
        
        
        //         setting proper string for sets and reps
        if let sets = sets,
           let reps = reps{
            activityDetailsString = "Sets: \(sets) x Reps: \(reps)"
        }
        else if let reps = reps {
            activityDetailsString = "Reps: \(reps)"
        }
        
        //        setting the final string depending on existance of duration and set reps
        if let duration = duration {
            activityDetailsString = "Time: \(duration)"
        }
        
//        setting proper ui for interval options
        
        if let intervals = intervals,
            let activityTime = activityTime,
            let restTime = restTime {
            
            activityDetailsString = "\(completedIntervals) / \(intervals) Completed \n \(activityTime) On - \(restTime) Off"
        }
        
        
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
}


