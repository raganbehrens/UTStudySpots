//
//  RegisterViewController.swift
//  UTStudySpots
//
//  Created by Nalisia Greenleaf on 10/8/16.
//  Copyright © 2016 Nalisia Greenleaf. All rights reserved.
//

import UIKit
import Alamofire

class RegisterViewController: UIViewController {

    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var registerStatus: UILabel!
    @IBOutlet weak var firstNameText: UITextField!
    @IBOutlet weak var lastNameText: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    var loginsuccess = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(self.keyboardWillShow(_:)),
            name: UIKeyboardWillShowNotification,
            object: nil
        )
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(self.keyboardWillHide(_:)),
            name: UIKeyboardWillHideNotification,
            object: nil
        )
        
        // Do any additional setup after loading the view.
    }
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func alreadyRegister(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func registerButtonPressed(sender: AnyObject) {
        
        if emailText.text == "" || passwordText.text == "" || firstNameText.text == "" || lastNameText == "" {
            registerStatus.text! = "All fields are required"
        }
        else if !validEmail(emailText.text!){
            notify("Please enter a valid email", button1: "Ok", button2: "")
            registerStatus.text! = "Please enter a valid email"
        }
        else {
            fetchRegister()
        }
        
    }
    
    func validEmail(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(email)
    }
    
    func notify(message:String, button1: String, button2: String){
        let backgroundQueue = dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)
        
        dispatch_async(backgroundQueue) {
            let controller = UIAlertController(title: "Alert Controller", message: message, preferredStyle: .Alert)
            let secondButton = UIAlertAction(title: button2, style: .Cancel){
                UIAlertAction in
                self.storeLoginInfo(self.firstNameText.text!, lastName: self.lastNameText.text!)
                self.performSegueWithIdentifier("registeredSegue", sender: self)
            }
            if (button2 != ""){
                controller.addAction(secondButton)
            }
            controller.addAction(UIAlertAction(title: button1 ,style: .Default, handler: nil))
            
            dispatch_async(dispatch_get_main_queue()) {
                self.presentViewController(controller, animated: true, completion: nil)
                
            }
        }
        
    }
    
    func storeLoginInfo(firstName:String, lastName:String){
        
        let kUserNameKey = "username"
        let kPassword = "password"
        let kfirstName = "firstname"
        let klastName = "lastname"
        let username = emailText.text!
        let password = passwordText.text!
        
        // Get a reference to the global user defaults object
        let defaults = NSUserDefaults.standardUserDefaults()
        // Store various values
        defaults.setObject(username, forKey: kUserNameKey)
        defaults.setObject(password, forKey: kPassword)
        defaults.setObject(firstName, forKey: kfirstName)
        defaults.setObject(lastName, forKey: klastName)
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Called when the user touches on the main view (outside the UITextField).
    //
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func fetchRegister() {
        Alamofire.request(
            .GET,
            "http://107.170.39.244:3000/register"
            /*"http://5e5f6854.ngrok.io/register"*/,
            parameters: ["include_docs": "true", "email" : emailText.text!, "password" : passwordText.text!, "firstname" : firstNameText.text!, "lastname": lastNameText.text!],
            encoding: .URL)
            .validate()
            .responseJSON { (response) -> Void in
                guard response.result.isSuccess else {
                    print("Error while fetching register: \(response.result.error)")
                    return
                }
                
                guard let value = response.result.value as? [String: AnyObject]
                    else {
                        print("didn't get anything")
                        return
                }
                
                print(value["success"]!)
                self.loginsuccess = value["success"]! as! String == "YES"
                if self.loginsuccess {
                    self.notify("You have been registered! Login now?", button1: "No", button2: "Yes")
                    //self.registerStatus.text! = "Registered!"
                    //self.dismissViewControllerAnimated(true, completion: nil)
                    
                }
                else {
                    self.notify("This email is already registered.", button1: "Ok", button2: "")
                    //self.registerStatus.text! = "Username already registered"
                }
                
                print("email is \(self.emailText.text) password is \(self.passwordText.text)")
        }
    }
    var adjusted = false
    func adjustInsetForKeyboardShow(show: Bool, notification: NSNotification) {
        guard let value = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue else { return }
        let keyboardFrame = value.CGRectValue()
        let adjustmentHeight = (CGRectGetHeight(keyboardFrame) + 20) * (show ? 1 : -1)
        if (lastNameText.isFirstResponder() || (adjusted && !show)){
            
            scrollView.contentInset.bottom += adjustmentHeight
            scrollView.scrollIndicatorInsets.bottom += adjustmentHeight
            if(adjusted) {
                adjusted = false
            } else {
                adjusted = true
            }
            
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        adjustInsetForKeyboardShow(true, notification: notification)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        adjustInsetForKeyboardShow(false, notification: notification)
    }
    @IBAction func hideKeyboard(sender: AnyObject) {
          lastNameText.endEditing(true)
          firstNameText.endEditing(true)
          emailText.endEditing(true)
          passwordText.endEditing(true)
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
