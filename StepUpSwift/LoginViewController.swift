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

class LoginViewController: UIViewController {

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var errorMsgLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "StepUp"
        self.navigationItem.setHidesBackButton(true, animated:true);
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(showError(_:)), name: ACTION_USERLOGIN_CHALLENGE_RECEIVED, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(showSecuredPage), name: ACTION_USERLOGIN_CHALLENGE_SUCCESS, object: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    @IBAction func login(sender: AnyObject) {
        if(self.username.text != "" && self.password.text != ""){
            NSNotificationCenter.defaultCenter().postNotificationName(ACTION_USERLOGIN_LOGIN_REQUIRED, object: self, userInfo: ["username": username.text!, "password": password.text!])
        } else {
            errorMsgLabel.text = "Username and password are required"
        }
    }

    func showError(notification: NSNotification){
        errorMsgLabel.text = notification.userInfo!["errorMsg"] as? String
    }
    
    func showSecuredPage(){
        if (self.navigationController?.viewControllers.first == self){
            self.performSegueWithIdentifier("showSecuredPage", sender: self)
        } else {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    

}
