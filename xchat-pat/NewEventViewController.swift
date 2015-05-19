//
//  NewEventViewController.swift
//  xchat-pat
//
//  Created by Pat Boonyarittipong on 5/18/15.
//  Copyright (c) 2015 patboony. All rights reserved.
//

import UIKit

class NewEventViewController: UIViewController {

    @IBOutlet weak var eventNameTextField: UITextField!
    
    @IBOutlet weak var eventLocationTextField: UITextField!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addButtonAction(sender: AnyObject) {
        
        var newEvent = PFObject(className: "event")
        
        // Dummy gropuId
        newEvent["groupId"] = 1
        newEvent["authorUsername"] = PFUser.currentUser()?.username!
        newEvent["eventName"] = eventNameTextField.text
        newEvent["eventLocation"] = eventLocationTextField.text
        newEvent["start"] = startDatePicker.date
        newEvent["end"] = endDatePicker.date
        newEvent.saveInBackgroundWithBlock { (result: Bool, error: NSError?) -> Void in
            if error != nil {
                println(error?.description)
            } else {
                println(result)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        
        
    }
        
    @IBAction func cancelButtonAction(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
