# iOS-plugin-twilio-call-cordova

Note:- Please add ios platform before following these steps


How to Use

1. Add swift support cordova plugin add cordova-plugin-add-swift-support --save  
2. Change Swift version > go to your cordova project open config.xml and add these line in ios platform

<preference name="UseSwiftLanguageVersion" value="5" />
<preference name="deployment-target" value="11.0" />

3. Install twilio-call-plugin>
cordova plugin add <PATH_TO_PLUGIN's package.json>

4. Get list of plugin > cordova plugin list

5. Remove plugin > cordova plugin rm id of plugin something like ~ 'com-twiliocordova-plugins-swift'

4. Cordova build ios

5. Plugin sends back call back now, if call ended normally it will send "" else cancelled or dropped accordingly

