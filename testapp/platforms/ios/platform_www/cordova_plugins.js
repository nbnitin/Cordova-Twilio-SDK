cordova.define('cordova/plugin_list', function(require, exports, module) {
  module.exports = [
    {
      "id": "com-twiliocordova-plugins-swift.TwilioCordovaSwift",
      "file": "plugins/com-twiliocordova-plugins-swift/www/TwilioCordovaSwift.js",
      "pluginId": "com-twiliocordova-plugins-swift",
      "clobbers": [
        "twilioCordovaSwift"
      ]
    }
  ];
  module.exports.metadata = {
    "cordova-plugin-whitelist": "1.3.4",
    "cordova-plugin-add-swift-support": "2.0.2",
    "com-twiliocordova-plugins-swift": "0.0.1"
  };
});