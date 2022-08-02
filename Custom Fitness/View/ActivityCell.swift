//
//  ActivityCell.swift
//  Custom Fitness
//
//  Created by Zach Davis on 7/27/22.
//

import UIKit
import RealmSwift


class ActivityCell: UITableViewCell {
    
    @IBOutlet weak var cellView: UIView!
    
    @IBOutlet weak var activityTitle: UILabel!
    
    @IBOutlet weak var activityDetails: UILabel!
    
    @IBOutlet weak var checkButton: UIButton!
    
    @IBOutlet weak var checkboxImage: UIImageView!
    
    var realm = try! Realm()
    
    var cellExercise : Exercise?
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        cellView.layer.cornerRadius = 20
        cellView.layer.borderWidth = 1.0
        cellView.layer.borderColor = UIColor(named: "custom_dark")?.cgColor

        // Configure the view for the selected state
    }
    
    
    func addCellDetails(_ durationInt: Int, _ setsInt: Int, _ repsInt : Int) {
        
//        setting strings for the functions optional inputs to return correct string in cell
        var duration : String?
        var sets : String?
        var reps : String?
        
        if durationInt != 0 {
            duration = String(durationInt)
        }
        
        if setsInt != 0 {
            sets = String(setsInt)
        }
        
        if repsInt != 0 {
            reps = String(repsInt)
        }
        
        
//        logic to determine contents and format of the cells details
        var setReps : String?
        
        var activityDetailsString : String = ""
        
        
//         setting proper string for sets and reps
        if sets != nil && reps != nil {
            setReps = "Sets: \(sets!) x Reps: \(reps!)"
        }
        else if reps != nil {
            setReps = "Reps: \(reps!)"
        }
        
//        setting the final string depending on existance of duration and set reps
        if let duration = duration {
            if let setReps = setReps {
                let durationString = "Time: \(duration)"
                activityDetailsString = "\(durationString) \n\(setReps)"
            }
            else {
                activityDetailsString = "\(duration)"
            }
        }
        else {
            if let setReps = setReps {
                activityDetailsString = "\(setReps)"
            }
        }
        
        activityDetails.text = activityDetailsString
    }
    
    
//    checkbox logic
    let checkedImage = UIImage(named: "checked_box_icon")! as UIImage
    let uncheckedImage = UIImage(named: "unchecked_box_icon")! as UIImage
    
    

    @IBAction func checkButtonPressed(_ sender: Any) {
        print("check button pressed")
        
        var exerciseCompleted : Bool?
        
        if let completed = cellExercise?.completed {
            if completed {
                exerciseCompleted = false
                checkboxImage.image = UIImage(named: "unchecked_box_icon")
            } else {
                exerciseCompleted = true
                checkboxImage.image = UIImage(named: "checked_box_icon")
            }
            
            do {
                try realm.write({
                    cellExercise?.completed = exerciseCompleted!
                })
            }
            catch {
                print("error setting exercise complete \(error)")
            }
        }
        else {
            print("not passing cellExercise")
        }

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
