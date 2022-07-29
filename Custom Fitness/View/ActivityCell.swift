//
//  ActivityCell.swift
//  Custom Fitness
//
//  Created by Zach Davis on 7/27/22.
//

import UIKit

class ActivityCell: UITableViewCell {

    @IBOutlet weak var cellView: UIView!
    
    @IBOutlet weak var activityTitle: UILabel!
    
    @IBOutlet weak var activityDetails: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        cellView.layer.cornerRadius = 20
        cellView.layer.borderWidth = 1.0
        cellView.layer.borderColor = UIColor(named: "custom_dark")?.cgColor

        // Configure the view for the selected state
    }
    
    
    func addTwoLines(_ duration: String, _ setReps: String) {
        
        let activityDetailsString = "\(duration) \n\(setReps)"
        
        cellView.heightAnchor.constraint(equalToConstant: 120.0)
        
        activityDetails.text = activityDetailsString
    }
    
    
}
