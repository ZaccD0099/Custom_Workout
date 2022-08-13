//
//  WorkoutCollectionViewCell.swift
//  Custom Fitness
//
//  Created by Zach Davis on 7/27/22.
//

protocol WorkoutCollectionViewCellProtocol : AnyObject {
    func pullEditWorkoutScreen()
    func setSelectedWorkout(_ selectedWorkout : Workout)
}

import UIKit

class WorkoutCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var workoutTitleLabel: UILabel!
    @IBOutlet weak var workoutType: UILabel!
    @IBOutlet weak var workoutDuration: UILabel!
    @IBOutlet weak var mainView: UIView!
    
    weak var delegate : WorkoutCollectionViewCellProtocol?
    
    var cellWorkout : Workout?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.mainView.layer.borderColor = UIColor(named: "cutom_dark")?.cgColor
        self.mainView.layer.borderWidth = 1.0
        self.mainView.layer.cornerRadius = 25
        self.mainView.layer.masksToBounds = true
        self.mainView.layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 30.0).cgPath
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(pullEditWorkout))
        longPress.minimumPressDuration = 0.75
        
        self.mainView.addGestureRecognizer(longPress)
        
//        self.viewofCell.layer.shadowColor = UIColor.black.cgColor
//        self.viewofCell.layer.shadowOpacity = 1
//        self.viewofCell.layer.shadowOffset = CGSize(width: 2.0, height: 6.0)
//        self.viewofCell.layer.shadowRadius = 10
//        self.viewofCell.layer.backgroundColor = UIColor(ciColor: .clear).cgColor
    }
    
    @objc func pullEditWorkout(Recognizer: UILongPressGestureRecognizer){
        
        if Recognizer.state == .began {
            if let cellWorkout = cellWorkout {
                delegate?.setSelectedWorkout(cellWorkout)
            }
            delegate?.pullEditWorkoutScreen()
        }
    }
}
