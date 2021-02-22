//
//  ECGHistoryVC.swift
//  ClubAfib
//
//  Created by Rener on 7/22/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit

class ECGHistoryVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ECGViewCell", for: indexPath) as! ECGViewCell
        
        return cell
    }
    

}
