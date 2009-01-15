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

// Coordinates for Web and Text fields

#define kLeftMargin				0.0
#define kTopMargin				0.0
#define kRightMargin			0.0
#define kBottomMargin			0.0
#define kTweenMargin			10.0
#define kTextFieldHeight		30.0

// Settings

#define kURL                    @"setting_url"
#define kLocation               @"setting_location"
#define kPhoto                  @"setting_photo"
#define kVibration              @"setting_vibration"

// Shortcuts

#define STR_PREF(name)          [[NSUserDefaults standardUserDefaults] stringForKey:name]
#ifdef APP_OFFLINE
    #define BOOL_PREF(name)         1
#else
    #define BOOL_PREF(name)         ([[[NSUserDefaults standardUserDefaults] stringForKey:name] isEqualToString:@"YES"])
#endif