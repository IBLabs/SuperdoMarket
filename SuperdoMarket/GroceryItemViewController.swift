//
//  GroceryItemViewController.swift
//  SuperdoMarket
//
//  Created by Itamar Biton on 20/11/2018.
//  Copyright © 2018 Itamar Biton. All rights reserved.
//

import UIKit

class GroceryItemViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var bagColorView: UIView!
    
    /** The presented grocery item */
    var groceryItem: GroceryItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // configure the view using the grocery item
        if let item = groceryItem {
            configureView(item: item)
        }
    }
    
    // MARK: User Interface Methods
    
    @IBAction func didClickedCloseButton(sender: UIButton) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Utility Methods
    
    /**
     Configures the view using the received grocery item
     
     - Parameter item: A GroceryItem object used to configure the view
     */
    func configureView(item: GroceryItem) {
        nameLabel.text = item.name
        weightLabel.text = item.weight
        bagColorView.backgroundColor = UIColor(hexString: item.bagColor)
    }
}
