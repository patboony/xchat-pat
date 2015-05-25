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
    
    @IBOutlet weak var tableViewContainer: UIView!
    @IBOutlet weak var tableViewBottomLayoutConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var messageTextFieldTrailingSpace: NSLayoutConstraint!
    @IBOutlet weak var messageTextFieldSpaceToSendButton: NSLayoutConstraint!
    
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var subWelcomeLabel: UILabel!
    
    
    let animationTime: NSTimeInterval = 0.3
    var threadId: String = "AtsDDF0sUK"
    var messages = [PFObject]()
    var originalWidth: CGFloat?
    var originalHeight: CGFloat?
    
    // First login and then fetch messages
    func loginDummyUser() {
        PFUser.logInWithUsernameInBackground("patboony", password: "123456") { (user: PFUser?, error: NSError?) -> Void in
            if error != nil {
                println(error?.description)
            } else {
                // Done
                println(user)
                self.fetchMessages()
            }
        }
    }
    
    @IBAction func onTableViewTap(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBAction func OnTextFieldChanged(sender: UITextField) {
        if sender.text != "" {
            self.messageTextFieldTrailingSpace.constant = 52
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.view.layoutIfNeeded()
                }, completion: { (completed: Bool) -> Void in
                self.sendButton.alpha = 1
            })
            
        } else {
            self.sendButton.alpha = 0
            self.messageTextFieldTrailingSpace.constant = 8

            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.view.layoutIfNeeded()
                }, completion: { (completed: Bool) -> Void in
                    
            })
        }
    }

    // Set various parameters for messageTableView
    func initializeMessageTableView(){
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        messageTableView.rowHeight = UITableViewAutomaticDimension
        messageTableView.estimatedRowHeight = 80
        
        messageTableView.tableFooterView = UIView(frame: CGRectZero)
        
        originalWidth = messageTableView.frame.width
        originalHeight = messageTableView.frame.height
    }
    
    func insertWelcomeHeader(){
        var nib = UINib(nibName: "WelcomeChatView", bundle: nil)
        var objects = nib.instantiateWithOwner(self, options: nil)
        var headerView = objects[0] as! UIView
        
        messageTableView.tableHeaderView = headerView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initializeMessageTableView()
        
        // Login and fetch messages
        loginDummyUser()
        
        messageTextField.resignFirstResponder()
        
        // Hide Keyboard and stuff
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        
        
    }
    
    
    func keyboardWillShow(notification: NSNotification){
        let userInfo = notification.userInfo
        let kbSize = userInfo?[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue()
        let newHeight = tableViewContainer.frame.height - kbSize!.height
        
        self.tableViewBottomLayoutConstraint.constant = kbSize!.height
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            
            self.view.layoutIfNeeded()
            }, completion: { (Bool) -> Void in
                self.scrollToBottom()
        })
        
    }
    
    func keyboardWillHide(notification: NSNotification){
        
        self.tableViewBottomLayoutConstraint.constant = 0
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            
            self.view.layoutIfNeeded()
            }, completion: { (Bool) -> Void in
                self.scrollToBottom()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func sendMessageAction(sender: AnyObject) {
        
        var message = PFObject(className: "message")
        // Dummy authorId and threadId
        message["authorUsername"] = PFUser.currentUser()?.username!
        message["threadId"] = threadId
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
        query.whereKey("threadId", equalTo: threadId)
        query.orderByAscending("updatedAt")
        query.limit = 20
        
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]?, error: NSError?) -> Void in
            if objects != nil {
                
                self.messages = (objects as! [PFObject]?)!
                if self.messages.count != 0 {
                    // get rid of the welcome message
                    self.messageTableView.tableHeaderView = UIView(frame: CGRectZero)
                    self.messageTableView.reloadData()
                    self.scrollToBottom()
                } else {
                    self.insertWelcomeHeader()
                }
                
            } else {
                println("object is nil")
                println(error?.description)
            }
        }
    }
    
    func scrollToBottom(){
        let bottomSection = messageTableView.numberOfSections() - 1
        if bottomSection >= 0 {
            let bottomRow = messageTableView.numberOfRowsInSection(bottomSection) - 1
            if bottomRow >= 0 {
                println(bottomRow)
                println(bottomSection)
                let lastIndexPath = NSIndexPath(forRow: bottomRow, inSection: bottomSection)
                
                messageTableView.layoutIfNeeded()
                messageTableView.scrollToRowAtIndexPath(lastIndexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
                //messageTableView.layoutIfNeeded()
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("MessageTableViewCell", forIndexPath: indexPath) as! MessageTableViewCell
        
        let messageForRow = messages[indexPath.row] as PFObject
        cell.messageLabel.text = messageForRow["content"] as? String
        cell.authorLabel.text = messageForRow["authorUsername"] as? String        
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        cell.timestampLabel.text = dateFormatter.stringFromDate(messageForRow.createdAt!)

        return cell
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
