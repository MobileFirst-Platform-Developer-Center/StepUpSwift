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
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func getBalance(sender: AnyObject) {
        let request = WLResourceRequest(URL: NSURL(string: "/adapters/ResourceAdapter/balance"), method: WLHttpMethodGet)
        request.sendWithCompletionHandler { (response, error) -> Void in
            if (error != nil){
                NSLog("getBalanceError: " + error.description)
            } else {
                NSLog("getBalance = " + response.responseText)
                self.resultLabel.text = "Balance = " + response.responseText
            }
        }
    }
    
    @IBAction func transferFounds(sender: AnyObject) {
        let alert = UIAlertController(title: "Tranfer founds", message: "Enter amount:", preferredStyle: .Alert)
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
    
    func transfer(amount: String){
        let request = WLResourceRequest(URL: NSURL(string: "/adapters/ResourceAdapter/transfer"), method: WLHttpMethodPost)
        let formParams = ["amount":amount]
        request.sendWithFormParameters(formParams) { (response, error) -> Void in
            if (error != nil){
                NSLog("transferFoundsError: " + error.description)
            } else {
                NSLog("transferFounds = " + String(response.status))
                self.resultLabel.text = "Status = " + String(response.status)
            }
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
