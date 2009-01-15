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

#import "big5AppDelegate.h"
#import "big5ViewController.h"

@implementation big5AppDelegate

@synthesize window;
@synthesize viewController;
@synthesize gAlertView;
@synthesize gURL;

// APPLICATION

- (void)applicationDidFinishLaunching:(UIApplication *)application {	

    NSLog(@"app: finished loading");
    
    // LOAD SETTINGS AND SET DEFAULTS
    // -------------------------------------------------
    
    #ifndef APP_OFFLINE
    NSString *testValue = [[NSUserDefaults standardUserDefaults] stringForKey:kURL];
	if (testValue == nil)
	{
        NSLog(@"app: initalize prefernces");
        
		// no default values have been set, create them here based on what's in our Settings bundle info
		NSString *pathStr = [[NSBundle mainBundle] bundlePath];
		NSString *settingsBundlePath = [pathStr stringByAppendingPathComponent:@"Settings.bundle"];
		NSString *finalPath = [settingsBundlePath stringByAppendingPathComponent:@"Root.plist"];

		NSDictionary *settingsDict = [NSDictionary dictionaryWithContentsOfFile:finalPath];
		NSArray *prefSpecifierArray = [settingsDict objectForKey:@"PreferenceSpecifiers"];

		NSString *urlDefault;
		NSString *locationDefault;
		NSNumber *photoDefault;
		NSNumber *vibrationDefault;
		
		NSDictionary *prefItem;
		for (prefItem in prefSpecifierArray)
		{
			NSString *keyValueStr = [prefItem objectForKey:@"Key"];
			id defaultValue = [prefItem objectForKey:@"DefaultValue"];			
			if ([keyValueStr isEqualToString:kURL])
				urlDefault = defaultValue;
			else if ([keyValueStr isEqualToString:kLocation])
				locationDefault = defaultValue;
			else if ([keyValueStr isEqualToString:kPhoto])
				photoDefault = defaultValue;
			else if ([keyValueStr isEqualToString:kVibration])
				vibrationDefault = defaultValue;
		}

		// since no default values have been set (i.e. no preferences file created), create it here
		NSDictionary *appDefaults =  [NSDictionary dictionaryWithObjectsAndKeys:
            urlDefault, kURL, 
            locationDefault, kLocation,
            photoDefault, kPhoto,
            vibrationDefault, kVibration,
            /*, kFirstNameKey,
            lastNameDefault, kLastNameKey,
            [NSNumber numberWithInt:1], kNameColorKey,
            [NSNumber numberWithInt:1], kBackgroundColorKey, */
            nil];
		
		[[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
    #endif
    	       
	// Override point for customization after app launch	
    // -------------------------------------------------

    [window addSubview:viewController.view];
	[window makeKeyAndVisible];    

    // Let handleOpenURL the time to look if it needs to intervene
    #ifdef APP_URL
    self.gURL = APP_URL;
    #else
    self.gURL = STR_PREF(kURL);
    #endif
    
    [self performSelector:@selector(myLoadURL) withObject:nil afterDelay:0.0];

    // Load default page
    // -------------------------------------------------    
    // NSLog(@"app: loading url %@", STR_PREF(kURL));  
    // [WEB loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:STR_PREF(kURL)]]];

}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {   
    NSLog(@"app: handle special url");
    
    // You should be extremely careful when handling URL requests.
    // You must take steps to validate the URL before handling it.    
    if (!url) {
        // The URL is nil. There's nothing more to do.
        return NO;
    }
    
    NSString *URLString = [[url absoluteString] substringFromIndex:5];
    NSLog(@"app: srtarting with url %@", [URLString description]);
    
    if (!URLString) {
        // The URL's absoluteString is nil. There's nothing more to do.
        return NO;
    }
    
    // Your application is defining the new URL type, so you should know the maximum character
    // count of the URL. Anything longer than what you expect is likely to be dangerous.
    NSInteger maximumExpectedLength = 255;
    
    if ([URLString length] > maximumExpectedLength) {
        // The URL is longer than we expect. Stop servicing it.
        return NO;
    }
    
    NSLog(@"app: loading individual url %@", URLString);
    
    self.gURL = [[NSString alloc] initWithString:URLString];
    
    // NSURL * anURL = [NSURL URLWithString:URLString];
    // NSURLRequest * aRequest = [NSURLRequest requestWithURL:anURL];
    // [WEB loadRequest:aRequest];
    
    // [WEB loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:URLString]]];
	
    return YES;
}

// ALERT

- (void)myLoadURL {
    NSLog(@"my app: loading url %@", gURL);  

    #if TARGET_IPHONE_SIMULATOR
    /* NSString *message = [NSString stringWithFormat:@"Loading URL: %@", myURL];
    self.alertView = [[UIAlertView alloc] initWithTitle:@"Big Five" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [self.alertView show]; */
    #endif
        
    // This is for offline projects
    #ifdef APP_OFFLINE
    NSString *urlPathString;
    NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
    if (urlPathString = [thisBundle pathForResource:@"index" ofType:@"html" inDirectory:APP_FOLDER]){
        NSLog(@"my app: loading local url %@", urlPathString);
        [viewController.gWebView loadRequest:[NSURLRequest 
                                              requestWithURL:[NSURL fileURLWithPath:urlPathString]
                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                              timeoutInterval:20.0
                                              ]];
    } else {
        NSLog(@"app: Folder %@ not found", APP_FOLDER);
    }
    #else
    // and this is the fallback to internet based apps
    [viewController.gWebView loadRequest:[NSURLRequest 
                                          requestWithURL:[NSURL URLWithString:gURL]
                                          cachePolicy:NSURLRequestUseProtocolCachePolicy
                                          timeoutInterval:20.0
                                          ]];
    #endif
}

- (void)dismissUsageAlert {
    [self.gAlertView dismissWithClickedButtonIndex:-1 animated:YES];
}

- (void)modalViewCancel:(UIAlertView *)alertView {
    [self.gAlertView release];
}

// CLEANUP

- (void)dealloc {
    [viewController release];
	[window release];
	[super dealloc];
}

@end
