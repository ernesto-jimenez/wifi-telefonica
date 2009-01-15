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


#import "Settings.h"
#import "Constants.h"
#import "Helpers.h"
#import "big5ViewController.h"

@implementation big5ViewController

@synthesize gWebView;
@synthesize gImageView;
@synthesize gLastLocation;
@synthesize gNotFoundState;
@synthesize gSupportAutoRotation;

- (id)init {
	self = [super init];
	/* if (self)
	{
		// this title will appear in the navigation bar
		self.title = NSLocalizedString(@"WebTitle", @"");
	} */
    gNotFoundState = false;
    gSupportAutoRotation = false;
	return self;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}

- (void)dealloc {
    [gWebView release];
	// [urlField release];	
	[super dealloc];
}

// *****************************************************************************
// VIEW
// *****************************************************************************

- (void)loadView {
    NSLog(@"view: load");
    
    /* if(gWebView!=nil) {
    
         [self.view bringSubviewToFront:gWebView];
        
    } else {
    */ 
	// the base view for this view controller
	UIView *contentView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	// contentView.backgroundColor = [[UIColor alloc] initWithRed:235 green:225 blue:200 alpha:1];
    	
	// important for view orientation rotation
	contentView.autoresizesSubviews = YES;
	contentView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);	
	
	self.view = contentView;
	
	[contentView release];

    /*
    if(BOOL_PREF(@"setting_acceleration")) {
        [[UIAccelerometer sharedAccelerometer] setUpdateInterval:1.0/40.0];
        [[UIAccelerometer sharedAccelerometer] setDelegate:self];
	}
    */

    // Init web view
    // -------------------------------------------------

	CGRect webFrame = [[UIScreen mainScreen] applicationFrame];

	// webFrame.origin.y -= kTopMargin; // + 5.0;	// leave from the URL input field and its label
	// webFrame.size.height -= 40.0;
	gWebView = [[UIWebView alloc] initWithFrame:webFrame];
	// gWebView.backgroundColor = [[UIColor alloc] initWithRed:235 green:225 blue:200 alpha:1];
	gWebView.scalesPageToFit = NO;
	gWebView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	gWebView.delegate = self;
    gWebView.hidden = YES;
	[self.view addSubview:gWebView];
	
    /* if(0) {
        CGRect textFieldFrame = CGRectMake(kLeftMargin, kTweenMargin, self.view.bounds.size.width - (kLeftMargin * 2.0), kTextFieldHeight);
        urlField = [[UITextField alloc] initWithFrame:textFieldFrame];
        urlField.borderStyle = UITextBorderStyleBezel;
        urlField.textColor = [UIColor blackColor];
        urlField.delegate = self;
        urlField.placeholder = @"<enter a URL>";
        urlField.text = @"http://www.apple.com";
        urlField.backgroundColor = [UIColor whiteColor];
        urlField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        urlField.returnKeyType = UIReturnKeyGo;
        urlField.keyboardType = UIKeyboardTypeURL;	// this makes the keyboard more friendly for typing URLs
        urlField.autocorrectionType = UITextAutocorrectionTypeNo;	// we don't like autocompletion while typing
        urlField.clearButtonMode = UITextFieldViewModeAlways;
        [self.view addSubview:urlField];
    } */

    // Show Image while loading
    // -------------------------------------------------
    
    gImageView = [[UIImageView alloc] initWithImage:[[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Default" ofType:@"png"]]];
	[self.view addSubview:gImageView];    
    
    // Init location manager
    // -------------------------------------------------

    if(BOOL_PREF(@"setting_location")) {
        gLocationManager = [[CLLocationManager alloc] init];
        gLocationManager.delegate = self;
	}
    // }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// we do not support rotation in this view controller
	return gSupportAutoRotation;
}

/*
 Implement viewDidLoad if you need to do additional setup after loading the view.
- (void)viewDidLoad {
	[super viewDidLoad];
}
 */
 
/* // this helps dismiss the keyboard when the "Done" button is clicked
 - (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	[myWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[textField text]]]];	
	return YES;
} */

// *****************************************************************************
// WEBVIEW
// *****************************************************************************

// #pragma mark UIWebView delegate methods

- (void)setDeviceDefaults {
    callJavascript(gWebView, @"window.bigfive = {version: '1.0.1', \
       device_model: '%s', \
       device_version: '%s', \
       device_name: '%s', \
       device_id: '%s'}",
       [[[UIDevice currentDevice] model] UTF8String], 
       [[[UIDevice currentDevice] systemVersion] UTF8String],
       [[[UIDevice currentDevice] systemName] UTF8String],
       [[[UIDevice currentDevice] uniqueIdentifier] UTF8String]);
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	// starting the load, show the activity indicator in the status bar
    NSLog(@"web: start load %@", [webView.request description]);  

#ifndef APP_OFFLINE
	[UIApplication sharedApplication].isNetworkActivityIndicatorVisible = YES;
#endif

    // [self setDeviceDefaults];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	// finished loading, hide the activity indicator in the status bar
    NSLog(@"web: finished loading, request %@", [webView.request description]);

#ifndef APP_OFFLINE
	[UIApplication sharedApplication].isNetworkActivityIndicatorVisible = NO;
#endif

    gWebView.hidden = NO;
    [self.view bringSubviewToFront:gWebView];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	// load error, hide the activity indicator in the status bar
    NSLog(@"web: loading failed");

#ifndef APP_OFFLINE    
	[UIApplication sharedApplication].isNetworkActivityIndicatorVisible = NO;
#endif
    
    gWebView.hidden = NO;
    [self.view bringSubviewToFront:gWebView];

    if(!gNotFoundState) {
        gNotFoundState = true;

        // report the error inside the webview
        
        NSString* errorString = [NSString stringWithFormat:
             @"<html><body style='background: #ebe1c8; font-size: 125%%; margin: 1em;' align='center'>An error occurred:<br><strong>%@</strong><br><br>\
             Please check if you provided a correct URL in the settings of Big&nbsp;Five. For more informations visit the projects web site \
             <a href='safari:http://www.big5apps.com/'>http://www.big5apps.com</a> <br> or go to the default start page <br> \
             <a href='http://iphone.big5apps.com/home'>http://iphone.big5apps.com/home</a>. \
             </html>",
             error.localizedDescription
             ];
                                 
        NSLog(@"web: error in ", [gWebView.request description]);                                 
        [gWebView loadHTMLString:errorString baseURL:nil];
    }
}

- (BOOL)webView:(UIWebView *)webViewLocal shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	NSString *myURL = [[request URL] absoluteString];

	NSLog(@"big5: handle url %@ %d", myURL, navigationType);
	// NSLog([self.lastKnownLocation description]);
	    
    // XXX deprecated!
    if([myURL hasPrefix:@"safari:"]) {
        // ([parts count]>1) && [(NSString *)[parts objectAtIndex:0] isEqualToString:@"safari"]) {
        // SWITCH TO SAFARI
        NSLog(@"safari: called");
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:(NSString *)[myURL substringFromIndex:7]]];
        return NO;            
    }
    
    // XXX gap: deprecated
    if([myURL hasPrefix:@"gap:"] || [myURL hasPrefix:@"device:"]) {
       		
        // Prepare parameters
        NSString *command = @"";
		NSString *param =  @"";
        NSArray *parts = [myURL componentsSeparatedByString:@":"];
                
        if([parts count] > 1) {
            command = (NSString *)[parts objectAtIndex:1];
        }
        
        if([parts count] > 2) {
            NSRange range; 
            range.location = 2;
            range.length = [parts count] - 2;
            param = [[NSString alloc] initWithString:[[parts subarrayWithRange:range] componentsJoinedByString:@":"]];    
        }
                
        NSLog(@"big5: command '%@', param '%@'", command, param);
        
        // INIT
        if([command isEqualToString:@"init"]) {
            NSLog(@"big5: init");
            [self setDeviceDefaults]; 
            callJavascript(gWebView, @"__device_init()");
        }

        // SETTER
        else if([command isEqualToString:@"set"] && ([parts count]==4)){
            NSString *name = (NSString *)[parts objectAtIndex:2];
            NSString *value = (NSString *)[parts objectAtIndex:3];
            NSLog(@"setter: %@ %@", name, value);
            
            // SET AUTO ROTATION
            if([name isEqualToString:@"rotation"]) {
                gSupportAutoRotation = ([value isEqualToString:@"true"] || [value isEqualToString:@"1"]);
            }

            // SET SCALE PAGE TO FIT
            if([name isEqualToString:@"scale"]) {
                gWebView.scalesPageToFit = ([value isEqualToString:@"true"] || [value isEqualToString:@"1"]);
            }
            
        }
        
        // LOCATION
        else if(BOOL_PREF(@"setting_location") && [command isEqualToString:@"location"]){
            NSLog(@"loc: request!");
            [gLocationManager startUpdatingLocation];
        }
        
        // VIBRATION
        else if(BOOL_PREF(@"setting_vibration") && [command isEqualToString:@"vibrate"]){
            NSLog(@"vibration: request!");
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        }

        // BROWSER
        else if([command isEqualToString:@"safari"]) {
            NSLog(@"big5: jumpt to safari with url %@", param);
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:param]];
        }

        // LOGGING
        else if([command isEqualToString:@"log"]) {
            NSLog(@"LOG: %@", param);
        }

        // ALERT
        else if([command isEqualToString:@"alert"]) {
            NSLog(@"ALERT: %@", param);
            alert(param);
        }        
        
        // PHOTO-PICKER
        else if(BOOL_PREF(@"setting_photo")) {
        
            // NSLog(@"photo: allowed");
        
            // PHOTOLIB
            if ([command isEqualToString:@"photo_from_library"] || [command isEqualToString:@"photo_from_album"]) {
            
                gPhotoUploadDestination = param;
                NSLog(@"photo: request library! callback %@", gPhotoUploadDestination);
                UIImagePickerController* picker = [[UIImagePickerController alloc] init];
                picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                picker.delegate = self;
                // picker.allowsImageEditing = YES;
                [self presentModalViewController:picker animated:YES];
                NSLog(@"photo: lib dialog open now!");                                
            
            }
            
            // CAMERA
            else if ([command isEqualToString:@"photo_from_camera"]) {                

                gPhotoUploadDestination = param;                
                NSLog(@"photo: request camera! callback %@", gPhotoUploadDestination);
                                    
                if ( (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) ) {
                
                    alert(@"Camera not available!");
                    NSLog(@"photo: camera not available!");
    
                    callJavascript(gWebView, @"__device_did_fail_image_upload('Camera not available');");
                
                } else {
                
                    UIImagePickerController* picker = [[UIImagePickerController alloc] init];
                    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                    picker.delegate = self;
                    // picker.allowsImageEditing = YES;
                    [self presentModalViewController:picker animated:YES];
                    NSLog(@"photo: camera dialog open now!");
                
                }
            }                                                          			            
        }
    
        // XXX CONNECTION        
        // XXX SOUND RECORDING  
        // XXX READ APP PREFS

		return NO;
	}
    
    NSLog(@"Timeout %f and cache policy %d",
        request.timeoutInterval,
        request.cachePolicy
        );
    
    // [gWebView cu  
    
    // [gWebView ]
    
    // [request cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
	return YES;
}

// *****************************************************************************
// LOCATION
// *****************************************************************************

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    /*
	[lastKnownLocation release];
	lastKnownLocation = newLocation;
	[lastKnownLocation retain];    
    double lat = lastKnownLocation.coordinate.latitude;
    double lon = lastKnownLocation.coordinate.longitude;            
    */
    
    callJavascript(gWebView, @"__device_did_update_location('%f', '%f', '%f', '%f');", 
                   newLocation.coordinate.latitude,
                   newLocation.coordinate.longitude,
                   oldLocation.coordinate.latitude,
                   oldLocation.coordinate.longitude);      
    
    NSLog(@"loc: updating location to %@", [newLocation description]);
}

// *****************************************************************************
// ACCELEROMETER
// *****************************************************************************

- (void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {    
    callJavascript(gWebView, @"__device_did_accelerate('%f','%f','%f');", acceleration.x, acceleration.y, acceleration.z);
}

// *****************************************************************************
// IMAGE PICKER
// *****************************************************************************
 
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    NSLog(@"photo: picked image");
    
    // Remove the picker interface and release the picker object.   
    [[picker parentViewController] dismissModalViewControllerAnimated:YES];
    [picker release];
    	
    NSData *imageData = UIImageJPEGRepresentation(image, 0.65);	
	//NSData * imageData = UIImagePNGRepresentation(image);	
    
    NSLog(@"photo: upload to %@", [gPhotoUploadDestination description]);
	// NSString *urlString = [@"http://macbook01.local:8080/upload?" stringByAppendingString:@"uid="];
	// urlString = [urlString stringByAppendingString:uniqueId];
	
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	[request setURL:[NSURL URLWithString:gPhotoUploadDestination]];
	[request setHTTPMethod:@"POST"];

    //Add the header info
	NSString *stringBoundary = [NSString stringWithString:@"0xKhTmLbOuNdArY"];
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",stringBoundary];
	[request addValue:contentType forHTTPHeaderField: @"Content-Type"];
	
	//create the body
	NSMutableData *postBody = [NSMutableData data];
	[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
    /* //add key values from the NSDictionary object
	NSEnumerator *keys = [postKeys keyEnumerator];
	int i;
	for (i = 0; i < [postKeys count]; i++) {
		NSString *tempKey = [keys nextObject];
		[postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",tempKey] dataUsingEncoding:NSUTF8StringEncoding]];
		[postBody appendData:[[NSString stringWithFormat:@"%@",[postKeys objectForKey:tempKey]] dataUsingEncoding:NSUTF8StringEncoding]];
		[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	} */
	
	//add data field and file data
	[postBody appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"data\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithString:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[NSData dataWithData:imageData]];
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	[request setHTTPBody:postBody];
	
	NSURLConnection *conn=[[NSURLConnection alloc] initWithRequest:request delegate:self];
	if(conn) {
		NSLog(@"photo: connection sucess");	
		//receivedData = [[NSMutableData data] retain];
	} else {
        NSLog(@"photo: upload failed!");
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    NSLog(@"photo: cancel dialog");
    callJavascript(gWebView, @"__device_photo_dialog_cancel();");
    [[picker parentViewController] dismissModalViewControllerAnimated:YES];
    [picker release];
}

// *****************************************************************************
// UPLOAD DATA
// *****************************************************************************

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"photo: upload finished!");

    // Callback
    callJavascript(gWebView, @"__device_did_finish_image_upload();");

    /* #if TARGET_IPHONE_SIMULATOR
    alert(@"Did finish loading image!");
    #endif */
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // append the new data to the receivedData
    // receivedData is declared as a method instance elsewhere
    // [receivedData appendData:data];
    NSLog(@"photo: progress");
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog([@"photo: upload failed! " stringByAppendingString:[error description]]);

    callJavascript(gWebView, @"__device_did_fail_image_upload('%s');", [[error description] UTF8String]);

    /* #if TARGET_IPHONE_SIMULATOR
    alert(@"Error while uploading image!");
    #endif */
}

@end

