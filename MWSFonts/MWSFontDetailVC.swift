//
//  MWSFontDetailVC.swift
//  MWSFonts
//
//  Created by Eric Turner on 2/5/15.
//  Copyright (c) 2015 MagicWave Software. All rights reserved.
//

import UIKit

class MWSFontDetailVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    @IBOutlet var lblPointSize: UILabel!
    @IBOutlet var slider:       UISlider!
    @IBOutlet var tableView:    UITableView!
    @IBOutlet var textfield:    UITextField!
    
    var fontFamily: MWSFontFamily?
    private var fonts:[String]! = [String]()
    
    private let cellId = "FontCell_ID"
    private let kTextLoremIpsum = "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor " + 
    "incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco " +
    "laboris nisi ut aliquip ex ea commodo consequat."
   
    
    //MARK: Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
        navigationItem.leftItemsSupplementBackButton = true
        
        tableView.estimatedRowHeight = 200.0 //44.0
        tableView.rowHeight = UITableViewAutomaticDimension

        updatePlaceholderText()
        textfield.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        
        if let fontFam = fontFamily {
            fonts = fontFamily!.fontNames
            self.title = "\(fontFam.familyName) (\(fonts.count))"
            updateFontSizeLabel()
        } else {
            // On iPad, part of the detailVC view is displayed before
            // a font family is selected from the masterVC
            self.title = "Font Family Not Selected"
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // On iPhone, when a font family is selected from the masterVC,
        // the tableView automatic row heights are set so that the cell
        // labels are squashed a bit, i.e., there isn't a nice separation
        // between the text at the bottom of the cell label and the 
        // section title of the cell below.
        //
        // A call to update the cells, which also reloads the table, with
        // a very short delay, lays out the cells properly.
        //
        // This issue does not occur on the iPad. Moreover, on the iPad,
        // because the detailVC loads immediately before the fontFamily
        // datasource var is set, without the check for fonts.isEmpty, the 
        // app will crash in the configureCellAtIndexPath() method.
        let delay = Int64(0.05 * Double(NSEC_PER_SEC))
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay), dispatch_get_main_queue()) { 
            if (!self.fonts.isEmpty) {
                self.updateVisibleCells()
                self.updatePlaceholderText()
            }
        }
    }
    
    
    //MARK: Textfield Methods
    
    // Listen for a "clear button", i.e. empty text change to update cells.
    // Otherwise, we only update in shouldReturn - not for every char entered.
    func textFieldDidChange(textfield: UITextField) {
        println("textfield.text changed to \(textfield.text)")
        if textfield.text == nil || textfield.text.isEmpty {
            updateVisibleCells()
        }
    }
    
    // Keyboard Done key handler
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textfield.resignFirstResponder()
        updateVisibleCells()
        return true
    }
    
    // Note that textfield.text is present until this method returns true
//    func textFieldShouldClear(textField: UITextField) -> Bool {
////        println("should clear current text: \(textfield.text)")
//        return true
//    }
    
    func updatePlaceholderText() {
        if !fonts.isEmpty {
            let fWord = (fonts.count > 1) ? "fonts" : "font"
            // Reduce length of text for iPhone
            if (traitCollection.horizontalSizeClass == UIUserInterfaceSizeClass.Compact) {
                textfield.placeholder = "Enter text, then update with Done key."
            } else {
                textfield.placeholder = "Enter text for display in \(fWord). Update with Done key."
            }
        } else {
            textfield.placeholder = "No font family selected."
        }
        
    }
    
    
    //MARK: Font Size Slider Methods
    
    @IBAction func handleSliderValueChanged() {
        if fonts.isEmpty {
            return
        }
        updateVisibleCells()
        updateFontSizeLabel()
    }
    
    func updateFontSizeLabel() {
        if !fonts.isEmpty {
//            println(NSString(format: "%.01f", slider.value))
            lblPointSize.text = NSString(format: "%.01f", slider.value)
        }
    }
    
    
    //MARK: Cell Utilites
    
    func configureCellAtIndexPath(cell: UITableViewCell, ip: NSIndexPath) -> UITableViewCell {
        cell.textLabel!.text = cellTextForIndexPath(ip)
        cell.textLabel!.numberOfLines = 0
        cell.textLabel!.font = UIFont(name: fonts[ip.section], size: CGFloat(slider.value))
        return cell
    }
    
    func updateVisibleCells() {
        let visibleCells = tableView.visibleCells()
        for idx in 0..<visibleCells.count {
            var cell = visibleCells[idx] as UITableViewCell
            if let ip = tableView.indexPathForCell(cell) {
                configureCellAtIndexPath(cell, ip: ip)
            }
        }
        tableView.reloadData()
    }

    func cellTextForIndexPath(indexPath: NSIndexPath) -> String {
        if (countElements(textfield.text) > 0) { //textfield.text != nil && !textfield.text.isEmpty {
            return textfield.text
        }
        return kTextLoremIpsum
    }

    func cellForEmptyTable() -> UITableViewCell {
        let aCell = tableView.dequeueReusableCellWithIdentifier(cellId) as UITableViewCell
        aCell.textLabel?.text = "No font selection..."
        aCell.textLabel?.textColor = UIColor.lightGrayColor()
        return aCell
    }
    
    
    // MARK: - Table View
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        let count = fonts.count
        return (count > 0) ? count : 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return (fonts.isEmpty) ? nil : fonts[section]
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if fonts.isEmpty {
            return cellForEmptyTable()
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as UITableViewCell
        return configureCellAtIndexPath(cell, ip: indexPath)
    }

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    
    //MARK: UIViewController
    
    override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        updatePlaceholderText()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

