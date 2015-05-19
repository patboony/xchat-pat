//
//  MessageViewController.swift
//  xchat-pat
//
//  Created by Pat Boonyarittipong on 5/13/15.
//  Copyright (c) 2015 patboony. All rights reserved.
//

import UIKit

class MessageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    
    var threadId: String?
    var messages = [PFObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        messageTableView.rowHeight = UITableViewAutomaticDimension
        messageTableView.estimatedRowHeight = 50
        
        // Check bug if this is ever false
        if threadId != nil {
            fetchMessages()
        } else {
            println("You shouldn't see this")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendMessageAction(sender: AnyObject) {
        
        var message = PFObject(className: "message")
        // Dummy authorId and threadId
        message["authorUsername"] = PFUser.currentUser()?.username!
        message["threadId"] = threadId!
        message["content"] = messageTextField.text
        
        // Clear the text field
        messageTextField.text = ""
        
        message.saveInBackgroundWithBlock { (result: Bool, error: NSError?) -> Void in
            if error != nil {
                // Print some kind of error to clients
                println("unable to send this message")
                println(error?.description)
            } else {
                // Succeed - reload
                self.fetchMessages()
            }
        }

    }
    
    func fetchMessages() {
        var query = PFQuery(className: "message")
        query.whereKey("threadId", equalTo: threadId!)
        query.orderByDescending("updatedAt")
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]?, error: NSError?) -> Void in
            if objects != nil {
                println(objects)
                self.messages = (objects as! [PFObject]?)!
                self.messageTableView.reloadData()
            } else {
                println("object is nil")
                println(error?.description)
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("MessageTableViewCell", forIndexPath: indexPath) as! MessageTableViewCell
        
        let messageForRow = messages[indexPath.row] as PFObject
        cell.messageLabel.text = messageForRow["content"] as? String
        cell.authorLabel.text = messageForRow["authorUsername"] as? String
        
        return cell
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
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
