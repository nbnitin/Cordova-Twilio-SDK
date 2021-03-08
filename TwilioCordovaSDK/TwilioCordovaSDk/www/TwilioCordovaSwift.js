var exec = require('cordova/exec');
exports.initiateCall = function(arg0,arg1,arg2,arg3,arg4,arg5, success, error) {
  exec(success, error, 'TwilioCordovaSwift', 'initiateCall', [arg0,arg1,arg2,arg3,arg4,arg5]);
};

exports.connect = function(arg0,arg1,success,error) {
  exec(success,error,'TwilioCordovaSwift', 'connect', [arg0,arg1]);
};

exports.forceEndCall = function(arg0,success,error) {
  exec(success,error,'TwilioCordovaSwift', 'forceEndCall', [arg0]);
};
