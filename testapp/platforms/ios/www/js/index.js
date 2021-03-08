/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
var app = {
    // Application Constructor
    initialize: function() {
        document.addEventListener('deviceready', this.onDeviceReady.bind(this), false);
    },

    // deviceready Event Handler
    //
    // Bind any cordova events here. Common events are:
    // 'pause', 'resume', etc.
   onDeviceReady: function() {
       app.receivedEvent('deviceready');
      
           twilioCordovaSwift.initiateCall('parti','room',
               'userName','IMG','Audio',false,
    function(msg) { 
      document
        .getElementById('deviceready')
        .querySelector('.received')
        .innerHTML = msg + "pass";   
    },
    function(err) {
      document
        .getElementById('deviceready')
        .innerHTML = '<p class="event received">' + err + '</p>'; 
    });
twilioCordovaSwift.connect("eyJjdHkiOiJ0d2lsaW8tZnBhO3Y9MSIsInR5cCI6IkpXVCIsImFsZyI6IkhTMjU2In0.eyJpc3MiOiJTS2UzOWQyNTA3MTA5YzgyMzdkMGU0YWU0YWVjMjczMTFiIiwiZXhwIjoxNTk1NDI2NjQ0LCJncmFudHMiOnsiaWRlbnRpdHkiOiJJcGFkX0JpZ0dlZV84ZGNiYzFkMi0yZTgwLTRjZGEtODQyZC0yNDM5MzE3YjEzNDQiLCJ2aWRlbyI6eyJyb29tIjoiNjNiZGU2ODctMmMxMC00NzYyLTlhOWUtOGJiNDIwNjYxYWZhIn19LCJqdGkiOiJTS2UzOWQyNTA3MTA5YzgyMzdkMGU0YWU0YWVjMjczMTFiLTE1OTU0MjMxMDQiLCJzdWIiOiJBQzYzYmI1YjU5YWJmMGFkYjhjOTBmODNkYmIzZDFkZGYyIn0.SuqtEFSWcvdcSKcFWe5IwEretjGQZi7fy3o8jPpSnu0", "63bde687-2c10-4762-9a9e-8bb420661afa");
twilioCordovaSwift.forceEndCall("by bye");
  modusechoswift.echojs(
    'Hello Plugin',
    function(msg) {
      document.getElementsByTagName('h1')[0].innerHTML = msg;
    },
    function(err) {
      document.getElementsByTagName('h1')[0].innerHTML = err;
    }
  );
},

    // Update DOM on a Received Event
    receivedEvent: function(id) {
        var parentElement = document.getElementById(id);
        var listeningElement = parentElement.querySelector('.listening');
        var receivedElement = parentElement.querySelector('.received');

        listeningElement.setAttribute('style', 'display:none;');
        receivedElement.setAttribute('style', 'display:block;');

        console.log('Received Event: ' + id);
    }
};

app.initialize();