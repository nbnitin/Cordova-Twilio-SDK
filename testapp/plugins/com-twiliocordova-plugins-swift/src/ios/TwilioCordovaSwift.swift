
@objc(TwilioCordovaSwift) class TwilioCordovaSwift : CDVPlugin {
    
    var vc : ViewController!
    
    
    @objc(initiateCall:)
    
    func initiateCall(command: CDVInvokedUrlCommand) {
        
        DispatchQueue.main.async {
            var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
                      
            let participantToken = command.arguments[0] as? String ?? ""
            let roomId = command.arguments[1] as? String ?? ""
            let userName = command.arguments[2] as? String ?? ""
            let imgUrl = command.arguments[3] as? String ?? ""
            let callType = command.arguments[4] as? String ?? ""
            let isOutGoingCall = command.arguments[5] as? Bool ?? false
            let sb = UIStoryboard(name: "Sample", bundle: nil)
            self.vc = sb.instantiateInitialViewController() as! ViewController
            self.vc.userName = userName
            self.vc.imgUrl = imgUrl
            self.vc.callType = callType
            self.vc.isCallOutgoing = isOutGoingCall
            self.vc.participantToken = participantToken
            self.vc.roomId = roomId
            self.vc.modalPresentationStyle = .fullScreen
            self.vc.callBackId = command.callbackId
            self.vc.commandDelegate = self.commandDelegate
            self.viewController.view.addSubview(self.vc.view)
            self.vc.didMove(toParent: self.viewController)
        }
    }
    @objc(connect:)
    func connect(command: CDVInvokedUrlCommand){
        let participantID = command.arguments[0] as? String ?? ""
        let roomId = command.arguments[1] as? String ?? ""
        vc.connect(participantToken:participantID,roomId:roomId)
    }
    
     @objc(forceEndCall:)
       func forceEndCall(command: CDVInvokedUrlCommand){
           vc.forceEndCall(messageToShow: command.arguments[0] as? String ?? "")
       }
    
}
