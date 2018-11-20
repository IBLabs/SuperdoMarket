//
//  ViewController.swift
//  SuperdoMarket
//
//  Created by Itamar Biton on 20/11/2018.
//  Copyright © 2018 Itamar Biton. All rights reserved.
//

import UIKit

import Starscream       // used to connect to the socket

class MainViewController: UIViewController,
    WebSocketDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout {
    
    /** The screen's header */
    @IBOutlet weak var headerView: UIView!
    
    /** The collection view that contains the grocery items */
    @IBOutlet weak var groceryListCollectionView: UICollectionView!
    
    /** The button that toggles the screen's header visibility */
    @IBOutlet weak var toggleHeaderVisibilityBarButtonItem: UIBarButtonItem!
    
    /** The top constraint of the segmented control, used to show/hide the screen's header */
    @IBOutlet weak var segmentedControlTopConstraint: NSLayoutConstraint!
    
    /** The segmented control's top constraint initial value, used for re-showing the screen's header */
    var segmentedControlTopConstraintInitialValue: CGFloat?
    
    /** use to keep track of the header view's visibilty */
    var isHeaderViewVisible = true
    
    /** the socket which we are connecting to */
    let mySocket = WebSocket(url: URL(string: "ws://superdo-groceries.herokuapp.com/receive")!)
    
    /** the array that holds the received grocery items */
    var groceryItems: [GroceryItem] = []
    
    /** the current width of the collection view items */
    var groceryListCollectionViewItemWidth: CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // connect to the socket
        mySocket.delegate = self
        mySocket.connect()
    }

    // MARK: WebSocketDelegate Methods
    
    func websocketDidConnect(socket: WebSocketClient) { }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) { }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        do {
            // try and convert the received text to a grocery item object and add it to the array
            let item = try GroceryItem(jsonString: text)
            groceryItems.insert(item, at: 0)
            
            // reload the collection view
            groceryListCollectionView.reloadData()
        } catch {
            print("failed parsing received grocery item!")
        }
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) { }
    
    // MARK: User Interface Methods
    
    @IBAction func didClickedHideInfoButton(sender: UIBarButtonItem) {
        // toggle the header's visibility
        toggleHeaderVisibility()
    }
    
    @IBAction func didChangedColumnAmount(sender: UISegmentedControl) {
        // get the selected segment (increment by 1 so we can divide by it)
        let selectedSegment = CGFloat(sender.selectedSegmentIndex + 1)
        
        // re-calculate the width of the cells in the collection view
        let newWidth: CGFloat = groceryListCollectionView.frame.size.width / selectedSegment
        groceryListCollectionViewItemWidth = newWidth
        
        // re-layout the collection view
        UIView.animate(withDuration: 0.4) {
            self.groceryListCollectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    // MARK: Utility Functions
    
    /**
     Toggle the sceen's information header visibiltiy
    */
    func toggleHeaderVisibility() {
        if (isHeaderViewVisible) {
            // change the button's title
            toggleHeaderVisibilityBarButtonItem.title = "Show Info"
            
            // keep the initial header height
            if (segmentedControlTopConstraintInitialValue == nil) {
                segmentedControlTopConstraintInitialValue = segmentedControlTopConstraint.constant
            }
            
            // update the constraint's constant
            segmentedControlTopConstraint.constant = 16
            
            // update the layout
            self.view.setNeedsLayout()
            
            // hide the header view
            UIView.animate(withDuration: 0.4) {
                self.headerView.alpha = 0.0
                self.view.layoutIfNeeded()
            }
        } else {
            // change the button's title
            toggleHeaderVisibilityBarButtonItem.title = "Hide Info"
            
            // update the constraint's constant
            segmentedControlTopConstraint.constant = segmentedControlTopConstraintInitialValue!
            
            // update the layout
            self.view.setNeedsLayout()
            
            // show the header view
            UIView.animate(withDuration: 0.4) {
                self.headerView.alpha = 1.0
                self.view.layoutIfNeeded()
            }
        }
        
        // flip the visibility switch
        isHeaderViewVisible = !isHeaderViewVisible
    }
    
    
    // MARK: UICollectionViewDataSource Methods
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groceryItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // get a cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.GROCERY_ITEM_CELL_IDENTIFIER, for: indexPath)
        
        if let groceryItemCell = cell as? GroceryItemCollectionViewCell {
            // get the matching item
            let item = groceryItems[indexPath.item]
            
            // configure the cell
            groceryItemCell.nameLabel.text = item.name
            groceryItemCell.weightLabel.text = item.weight
            groceryItemCell.bagColorView.backgroundColor = UIColor(hexString: item.bagColor)
        }
        
        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout Methods
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // if there's a width set, use it, else use the width of the collection view itself
        let width: CGFloat = groceryListCollectionViewItemWidth ?? groceryListCollectionView.bounds.width
        return CGSize(width: width, height: Constants.GROCERY_ITEM_CELL_HEIGHT)
    }
    
    // MARK: UICollectionViewDelegate Methods
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // get the selected item
        let item = groceryItems[indexPath.item]
        
        // create a grocery item view controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: Constants.GROCERY_ITEM_VIEW_CONTROLLER_IDENTIFIER) as! GroceryItemViewController
        viewController.groceryItem = item
        
        // present the view controller
        present(viewController, animated: true, completion: nil)
    }
}

// MARK: Utility Classes

class GroceryItemTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var bagColorView: UIView!
}

class GroceryItemCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var bagColorView: UIView!
}

class Constants {
    static let GROCERY_ITEM_CELL_IDENTIFIER = "GroceryItemCellIdentifier"
    static let GROCERY_ITEM_CELL_HEIGHT: CGFloat = 88.0
    static let GROCERY_ITEM_VIEW_CONTROLLER_IDENTIFIER = "GroceryItemViewControllerIdentifier"
}
