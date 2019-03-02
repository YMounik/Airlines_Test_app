//
//  ATFlightDetailsCell.swift
//  AlaskaTest
//
//  Created by Kiran on 10/01/19.
//  Copyright © 2019 Kiran. All rights reserved.
//

import UIKit

class ATFlightDetailsCell: UITableViewCell {

    @IBOutlet weak var lblFlightId: UILabel!
    @IBOutlet weak var lblOrigin: UILabel!
    @IBOutlet weak var lblCurrentTime: UILabel!
    @IBOutlet weak var lblArrivalTIme: UILabel!
    @IBOutlet weak var lblEstimatedArrival: UILabel!
    @IBOutlet weak var lblairport: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
