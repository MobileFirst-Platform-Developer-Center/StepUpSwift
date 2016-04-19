/**
 * Copyright 2016 IBM Corp.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import UIKit
import IBMMobileFirstPlatformFoundation

class SecuredViewController: UIViewController {
    
    @IBOutlet weak var helloUserLabel: UILabel!
    @IBOutlet weak var resultLabel: UILabel!
    //var isChallenged = false
    //var showPinCodePopupNotification: NSNotification

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "StepUp"
        self.navigationItem.setHidesBackButton(true, animated:true);
        
        let logoutBtn = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(logout))
        self.navigationItem.rightBarButtonItem = logoutBtn
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        if let userName = NSUserDefaults.standardUserDefaults().stringForKey("displayName"){
            self.helloUserLabel.text = "Hello, " + userName
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(showPinCodePopup(_:)), name: ACTION_PINCODE_CHALLENGE_RECEIVED, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(showErrorPopup(_:)), name: ACTION_PINCODE_CHALLENGE_FAILURE, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(showLoginPage(_:)), name: ACTION_USERLOGIN_CHALLENGE_RECEIVED, object: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    @IBAction func getBalance(sender: AnyObject) {
        let request = WLResourceRequest(URL: NSURL(string: "/adapters/ResourceAdapter/balance"), method: WLHttpMethodGet)
        request.sendWithCompletionHandler { (response, error) -> Void in
            if (error != nil){
                NSLog("getBalanceError: " + error.description)
                self.resultLabel.text = "Failed to get balance"
            } else {
                NSLog("getBalance = " + response.responseText)
                self.resultLabel.text = "Balance = " + response.responseText
            }
        }
    }
    
    @IBAction func transferFunds(sender: AnyObject) {
        self.resultLabel.text = ""
        
        WLAuthorizationManager.sharedInstance().obtainAccessTokenForScope("StepUpUserLogin") { (token, error) -> Void in
            if (error != nil){
                print("obtainAccessToken failure")
            } else {
                print("obtainAccessToken success")
                let alert = UIAlertController(title: "Tranfer funds", message: "Enter amount:", preferredStyle: .Alert)
                alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
                    textField.placeholder = "Amount"
                    textField.keyboardType = .NumberPad
                }
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
                    let pinTextField = alert.textFields![0] as UITextField
                    self.transfer(pinTextField.text!)
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) -> Void in
                    //
                }))
                self.presentViewController(alert,
                                           animated: true,
                                           completion: nil)
            }
        }
    }
    
    func logout(){
        self.resultLabel.text = ""
        self.performSegueWithIdentifier("showLoginPage", sender: self)
        NSNotificationCenter.defaultCenter().postNotificationName(ACTION_LOGOUT , object: self)
    }
    
    func transfer(amount: String){
        let request = WLResourceRequest(URL: NSURL(string: "/adapters/ResourceAdapter/transfer"), method: WLHttpMethodPost)
        let formParams = ["amount":amount]
        request.sendWithFormParameters(formParams) { (response, error) -> Void in
            if (error != nil){
                print("transferFounds Error: \(error.description)")
                dispatch_async(dispatch_get_main_queue()) {
                    self.resultLabel.text = "Faild to transfer funds"
                }
            } else {
                print("transferFounds Success with status: \(String(response.status))")
                dispatch_async(dispatch_get_main_queue()) {
                    self.resultLabel.text = "Transfer funds successfully."
                }
            }
        }
    }
    
    func showPinCodePopup(notification: NSNotification){
        let alert = UIAlertController(title: "Pin Code",
            message: notification.userInfo!["errorMsg"] as? String,
            preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "PIN CODE"
            textField.keyboardType = .NumberPad
        }
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            let pinTextField = alert.textFields![0] as UITextField
            NSNotificationCenter.defaultCenter().postNotificationName(ACTION_PINCODE_CHALLENGE_SUBMIT_ANSWER , object: self, userInfo: ["pinCode":pinTextField.text!])
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName(ACTION_PINCODE_CHALLENGE_CANCEL , object: self)
        }))
        
        self.presentViewController(alert,
            animated: true,
            completion: nil)
    }
    
    func showErrorPopup(notification: NSNotification){
        let alert = UIAlertController(title: "Error",
            message: notification.userInfo!["errorMsg"] as? String,
            preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        
        self.presentViewController(alert,
            animated: true,
            completion: nil)
    }
    
    func showLoginPage(notification: NSNotification){
        self.performSegueWithIdentifier("showLoginPage", sender: self)
    }

}
