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

#import <AudioToolbox/AudioServices.h>
#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIDevice.h>

@interface big5ViewController : UIViewController <
    UITextFieldDelegate, 
    UIWebViewDelegate, 
    CLLocationManagerDelegate, 
    UIAccelerometerDelegate,
    UIPickerViewDelegate,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate
    >
{
	UIWebView           *gWebView;
    UIImageView         *gImageView;
	// UITextField         *urlField;
    BOOL                gNotFoundState;
    BOOL                gSupportAutoRotation;
    
    // Location
	CLLocationManager   *gLocationManager;  
	CLLocation          *gLastLocation;
    
    // Photo
    NSString            *gPhotoUploadDestination;    
}

@property (nonatomic, retain) UIWebView	*gWebView;
@property (nonatomic, retain) UIImageView *gImageView;
@property (nonatomic, retain) CLLocation *gLastLocation;
@property BOOL gNotFoundState;
@property BOOL gSupportAutoRotation;

@end
