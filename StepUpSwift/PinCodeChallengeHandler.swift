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

class PinCodeChallengeHandler : WLChallengeHandler {
    
    let challengeHandlerName = "PinCodeChallengeHandler"
    
    override init() {
        super.init(securityCheck: "PinCodeAttempts")
        WLClient.sharedInstance().registerChallengeHandler(self)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "challengeSubmitAnswer", name: ACTION_CHALLENGE_SUBMIT_ANSWER, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "challengeCanceled", name: ACTION_CHALLENGE_CANCEL, object: nil)
        
    }
    
    override func handleChallenge(challenge: [NSObject : AnyObject]!) {
        print("\(self.challengeHandlerName): \(challenge)")
        var errorMsg: String
        if (challenge["errorMsg"] is NSNull) {
            errorMsg = "Enter PIN code:"
        } else{
            errorMsg = challenge["errorMsg"] as! String
        }
        NSNotificationCenter.defaultCenter().postNotificationName(ACTION_CHALLENGE_RECEIVED , object: self, userInfo: ["errorMsg":errorMsg])
    }
    
    override func handleFailure(failure: [NSObject : AnyObject]!) {
        print("\(self.challengeHandlerName): \(failure)")
        var errorMsg: String
        if (failure["failure"] is NSNull) {
            errorMsg = "Unknown error"
        } else {
            errorMsg = failure["failure"] as! String
        }
        NSNotificationCenter.defaultCenter().postNotificationName(ACTION_CHALLENGE_FAILURE, object: self, userInfo: ["errorMsg":errorMsg])
    }
    
    func challengeSubmitAnswer(notification: NSNotification){
        self.submitChallengeAnswer(["pin": (notification.userInfo!["pinCode"] as? String)!])
    }
    
    func challengeCanceled(){
        self.submitFailure(nil)
    }
    
}