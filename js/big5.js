/*******************************************************************************
 
 Copyright (C) 2008 Dirk Holtwick. All rights reserved.
 
 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License version 2 as 
 published by the Free Software Foundation.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License version 2 for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA
 
 See also http://www.fsf.org/licensing/licenses/info/GPLv2.html
 
*******************************************************************************/

// Utils

try {
    $ // Test if it is alread used
} catch(e) {
    $ = function(id){
        return document.getElementById(id)
    };
}

// Acceleration Handling

var accelX = 0;
var accelY = 0;
var accelZ = 0;

function gotAcceleration(x,y,z){
	x = eval(x);
	y = eval(y);
	z = eval(z);
	if ((!isNaN(x)) && (!isNaN(y)) && (!isNaN(z))) {
		accelX = x;
		accelY = y;
		accelZ = z;
	}
	return x + " " + y + " " + z;
}

var Device = {

/*  API for Big Five device extension.
    More informations on http://www.big5apps.com
*/

    available: false,
    model: "",
    version: "",
    gapVersion: "",
    bigFiveVersion: "",
    id: "",
    name: "",
    isIPhone: null,
    isIPod: null,
    callback: null,
    
    init: function() {
        try {
            Device.model = window.bigfive.device_model;
            Device.version = window.bigfive.device_version;
            Device.name = window.bigfive.device_name;
            Device.id = window.bigfive.device_id;            
            Device.gapVersion = window.bigfive.version;
            Device.bigFiveVersion = window.bigfive.version;
            Device.available = true;
        } catch(e) {
            alert("Big Five is not supported!")
        } 
        // Device.alert("Started!")
    },    

    start: function(callback) {
        Device.callback = callback
        window.setTimeout('document.location = "device:init:"', 0.0)   
    },

    exec: function(command, value) {
    /*  Executes device commands without stopping the current thread. If the 
        command has been sent it returns true, otherwise false.
    */
        if(Device.available) {
            // no escape! asynchronous!
            window.setTimeout('document.location = "device:' + command + ':' + (value || '') + '"', 0.0)
            return true
        }
        return false
    },
    
    set: function(name, value) {
        if(Device.available) {
            window.setTimeout('document.location = "device:set:' + name + ':' + value ?  "true" : "false", 0.0)
            return true
        }
        return false        
    },
    
    alert: function(message) {
    /*  Opens a non modal (!) alert. Alerts are not supported by WebKit by default
    */
        Device.exec("alert", message)
    },
    
    safari: function(url) {
    /*  Calls an URL in Safari. That means also that Big5 will be stopped.
    */
        Device.exec("safari", url)
    },

    Location: {
    /*  Tools to get the location of the device
    */    
	
		position: {
			lat: 0.0,
			lon: 0.0,
			oldLat: 0.0,
			oldLon: 0.0
		},
	
        /* lat: 0.0,
        lon: 0.0,
        oldLat: 0.0,
        oldLon: 0.0, */
        callback: null,
        
        init: function() {
            Device.exec("location");
        },
        
        _set: function(lat, lon, oldLat, oldLon) {        
            Device.Location.position.lat = lat
            Device.Location.position.lon = lon
            Device.Location.position.oldLat = oldLat
            Device.Location.position.oldLon = oldLon
            if(Device.Location.callback != null) {
                Device.Location.callback(Device.Location.position)
                Device.Location.callback = null;
            }
        },

        last: function(func) {
        /*  Get the last saved location or if not available request the current 
            location and give the resulting latitude and longitude to the callback function.
        */
            if((Device.Location.lat!=0.0) && (Device.Location.lon!=0.0))
                func(Device.Location.lat, Device.Location.lon)
            else
                Device.Location.wait(func)
        }, 

        wait: function(func) {
        /*  Request the current location and give the resulting latitude and
            longitude to the callback function.
        */
            Device.Location.callback = func
            Device.exec("location");
        }
        
    },

    Image: {

        // available: true,
        callback: null,
        onerror: null,
        destination: null,
        counter: 1,        
        process: {},

        _exec: function(command, destination, callback, onerror) {
            Device.Image.callback = callback || Device.Image.callback 
            Device.Image.onerror = onerror || Device.Image.onerror 
            Device.Image.destination = destination || Device.Image.destination 
            // throw "Destination needed"
            return Device.exec(command, destination)
        },

        getFromPhotoLibrary: function(destination, callback, onerror) {
            return Device.Image._exec("photo_from_library", destination, callback, onerror);
        },
        
        getFromCamera: function(destination, callback, onerror) {
            return Device.Image._exec("photo_from_camera", destination, callback, onerror);
        },
        
        getFromSavedPhotosAlbum: function(destination, callback, onerror) {
            return Device.Image._exec("photo_from_album", destination, callback, onerror);
        }

    },

    Console: {

        log: function(value) {
            Device.exec("log", value)
        },
        
        error: function(value) {
            Device.exec("log", "ERROR! " + value)        
        }
    },

    vibrate: function() {
        return Device.exec("vibrate")
    },

    setRotation: function(value) {
        return Device.set("rotation", value)
    },

    setScale: function(value) {
        return Device.set("scale", value)
    }
        
}

function __device_init(info) {
    Device.init()
    if(Device.callback)
        Device.callback()
}

function __device_did_accelerate(x, y, z) {
    // return Device.Location.set(newLat, newLon, oldLat, oldLon)
    ;
}

function __device_did_update_location(newLat, newLon, oldLat, oldLon) {
    return Device.Location._set(newLat, newLon, oldLat, oldLon)
}

function __device_did_finish_image_upload(destination) {
    return Device.Image.callback()
}

function __device_photo_dialog_cancel() {
    /* if(Device.Image.onerror)
        return Device.Image.onerror(error) */
}

function __device_did_fail_image_upload(error) {
    if(Device.Image.onerror)
        return Device.Image.onerror(error)
}

// A little more abstract

if (!window.console) {
    window.console = Device.console
}
