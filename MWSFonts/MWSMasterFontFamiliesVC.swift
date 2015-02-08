//
//  MWSMasterFontFamiliesVC.swift
//  MWSFonts
//
//  Created by Eric Turner on 2/5/15.
//  Copyright (c) 2015 MagicWave Software. All rights reserved.
//

import Foundation
import UIKit

struct MWSFontFamily {
    let familyName: String
    let fontNames:  [String]
}


class MWSMasterFontFamiliesVC: UITableViewController, UISplitViewControllerDelegate {

    private let cellId = "FontFamilyCell_ID"
    private var shouldCollapseDetailVC = true
    private var fontFamilyNames = [MWSFontFamily]()

    override func viewDidLoad() {
        super.viewDidLoad()
    
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }

        // load font data
        var familyNames = UIFont.familyNames() as [String]
        familyNames.sort(<)
        for famName in familyNames {
            var data = MWSFontFamily(familyName: famName, fontNames: UIFont.fontNamesForFamilyName(famName) as [String])
            fontFamilyNames.append(data)
        }
        println("fontFamilyNames.count:\(fontFamilyNames.count)")
        
        navigationItem.backBarButtonItem = nil
        navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", 
            style: UIBarButtonItemStyle.Plain, 
            target: nil, 
            action: nil)

        self.title = "Font Families (\(fontFamilyNames.count))"
        splitViewController?.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        if let ip = tableView.indexPathForSelectedRow()? {
            tableView.deselectRowAtIndexPath(ip, animated: true)
        }
    }
  
//    override func viewWillDisappear(animated: Bool) {
//        if let ip = tableView.indexPathForSelectedRow()? {
//            tableView.deselectRowAtIndexPath(ip, animated: true)
//        }
//    }
    
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let detailNavCon = segue.destinationViewController as? UINavigationController {
            if let familyDetailVC = detailNavCon.topViewController as? MWSFontDetailVC {
                if let selectedRowIndexPath = tableView.indexPathForSelectedRow() {
                    let fontFamilyData = fontFamilyNames[selectedRowIndexPath.row] as MWSFontFamily
                    familyDetailVC.fontFamily = fontFamilyData
                }                
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fontFamilyNames.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath) as UITableViewCell

        let data = fontFamilyNames[indexPath.row]
        let fName = data.familyName
        cell.textLabel!.text = fName
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }


    // MARK: Table View Delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        shouldCollapseDetailVC = false
    }

    
    // MARK: - UISplitViewControllerDelegate
    
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController!, ontoPrimaryViewController primaryViewController: UIViewController!) -> Bool {
        return shouldCollapseDetailVC
    }

    
    //MARK: UIViewController Boilerplate
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

