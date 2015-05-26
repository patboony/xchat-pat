//
//  EventViewController.swift
//  xchat-pat
//
//  Created by Pat Boonyarittipong on 5/18/15.
//  Copyright (c) 2015 patboony. All rights reserved.
//

import UIKit

class EventViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var events: [PFObject] = [PFObject]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        fetchEvents()
    }
    
    override func viewWillAppear(animated: Bool) {
        fetchEvents()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("EventViewCell", forIndexPath: indexPath) as! EventViewCell
        
        let eventForRow = events[indexPath.row] as PFObject
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        
        cell.startTimeLabel.text = dateFormatter.stringFromDate(eventForRow["start"] as! NSDate)
        cell.endTimeLabel.text = dateFormatter.stringFromDate(eventForRow["end"] as! NSDate)
        cell.eventNameLabel.text = eventForRow["eventName"] as? String
        cell.eventLocationLabel.text = eventForRow["eventLocation"] as? String
        
        return cell
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    @IBAction func backButtonAction(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func fetchEvents() {
        var query = PFQuery(className: "event")

        var todayMidnight = NSDate(timeInterval: 0, sinceDate: NSDate())
        var tomorrowMidnight = NSDate(timeInterval: 86400, sinceDate: NSDate())
                
        println(todayMidnight)
        println(tomorrowMidnight)
        
        query.whereKey("start", greaterThanOrEqualTo: todayMidnight)
        query.whereKey("start", lessThanOrEqualTo: tomorrowMidnight)

        query.orderByAscending("start")
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]?, error: NSError?) -> Void in
            if objects != nil {
                println(objects)
                self.events = (objects as! [PFObject]?)!
                self.tableView.reloadData()
            } else {
                println("object is nil")
                println(error?.description)
            }
        }
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
