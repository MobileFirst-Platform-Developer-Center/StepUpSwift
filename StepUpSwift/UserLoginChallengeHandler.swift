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

import Foundation
import IBMMobileFirstPlatformFoundation

class UserLoginChallengeHandler : WLChallengeHandler {
    let challengeHandlerName = "UserLoginChallengeHandler"
    let securityCheckName = "StepUpUserLogin"
    var isChallenged = false
    
    override init() {
        super.init(securityCheck: securityCheckName)
        WLClient.sharedInstance().registerChallengeHandler(self)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "login:", name: ACTION_USERLOGIN_LOGIN_REQUIRED, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "logout:", name: ACTION_USERLOGIN_LOGOUT, object: nil)
    }
    
    override func handleChallenge(challenge: [NSObject : AnyObject]!) {
        print("\(self.challengeHandlerName): handleChallenge - \(challenge)")
        self.isChallenged = true
        var errorMsg: String
        if (challenge["errorMsg"] is NSNull) {
            errorMsg = ""
        } else{
            errorMsg = challenge["errorMsg"] as! String
        }
        NSNotificationCenter.defaultCenter().postNotificationName(ACTION_USERLOGIN_CHALLENGE_RECEIVED , object: self, userInfo: ["errorMsg":errorMsg])
    }
    
    override func handleSuccess(success: [NSObject : AnyObject]!) {
        print("\(self.challengeHandlerName): handleSuccess - \(success)")
        self.isChallenged = false
        NSUserDefaults.standardUserDefaults().setObject(success["user"]!["displayName"]! as! String, forKey: "displayName")
        NSNotificationCenter.defaultCenter().postNotificationName(ACTION_USERLOGIN_CHALLENGE_SUCCESS , object: self)
    }
    
    override func handleFailure(failure: [NSObject : AnyObject]!) {
        print("\(self.challengeHandlerName): \(failure)")
        self.isChallenged = false
//        var errorMsg: String
//        if (failure["failure"] is NSNull) {
//            errorMsg = "Unknown error"
//        } else {
//            errorMsg = failure["failure"] as! String
//        }
//        NSNotificationCenter.defaultCenter().postNotificationName(ACTION_CHALLENGE_FAILURE, object: self, userInfo: ["errorMsg":errorMsg])
    }
    
    func login(notification: NSNotification){
        print("\(self.challengeHandlerName): login")
        let username = notification.userInfo!["username"] as! String
        let password = notification.userInfo!["password"] as! String
        if(!self.isChallenged){
            WLAuthorizationManager.sharedInstance().login(self.securityCheck, withCredentials: ["username": username, "password": password]) { (error) -> Void in
                print("\(self.challengeHandlerName): login")
                if(error != nil){
                    print("\(self.challengeHandlerName): login onFailure - \(error.description)")                }
            }
        } else {
            self.submitChallengeAnswer(["username": username, "password": password])
        }
    }
    
    func logout(notification: NSNotification){
        print("\(self.challengeHandlerName): logout")
        WLAuthorizationManager.sharedInstance().logout(securityCheckName) { (error) -> Void in
            if (error != nil){
                print("\(self.challengeHandlerName): logout onFailure - \(error.description)")
            } else {
                NSNotificationCenter.defaultCenter().postNotificationName(ACTION_PINCODE_LOGOUT , object: self)
                self.isChallenged = false
            }
        }
    }

}
