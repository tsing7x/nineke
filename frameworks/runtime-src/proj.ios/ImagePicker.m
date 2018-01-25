//
//  ImagePicker.m
//  NineKe
//
//  Created by 李强 on 14-9-9.
//
//

#import "ImagePicker.h"
#import "RootViewController.h"
#import "LuaOCBridge.h"

@implementation ImagePicker

@synthesize popover = _popover;
@synthesize canEdit = _canEdit;

- (void) showImagePicker
{
    self.imagePicker = [[[UIImagePickerController alloc] init] autorelease];
    self.imagePicker.delegate = self;
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    self.imagePicker.allowsEditing = self.canEdit;
    
    RootViewController* rootVC = nil;
    if ([[UIDevice currentDevice].systemVersion floatValue] < 6.0)
    {
        // warning: addSubView doesn't work on iOS6
        NSArray* array = [[UIApplication sharedApplication]windows];
        UIWindow* win = [array objectAtIndex:0];
        
        UIView* ui = [[win subviews] objectAtIndex:0];
        rootVC = (RootViewController*)[ui nextResponder];
    }
    else
    {
        // use this method on ios6
        rootVC = (RootViewController*)[UIApplication sharedApplication].keyWindow.rootViewController;
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [rootVC presentModalViewController:self.imagePicker animated:YES];
    }
    else
    {
        self.popover = [[[UIPopoverController alloc] initWithContentViewController:self.imagePicker] autorelease];
        self.popover.delegate = self;
        [self.popover presentPopoverFromRect:CGRectMake(rootVC.view.bounds.size.width - 100, 0, 100, 1) inView:rootVC.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if (self.popover)
    {
        [self.popover dismissPopoverAnimated:YES];
        self.popover = nil;
    }
    else
    {
        [self.imagePicker dismissModalViewControllerAnimated:YES];
        self.imagePicker = nil;
    }
    
    UIImage* editedImg = [info objectForKey:UIImagePickerControllerEditedImage];
	CGSize newSize;
	if([self canEdit]) {
		newSize = CGSizeMake(100, 100);
		// Create a graphics image context
		UIGraphicsBeginImageContext(newSize);
		// Tell the old image to draw in this new context, with the desired new size
		[editedImg drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
		// Get the new image from the context
		UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
		// End the context
		UIGraphicsEndImageContext();
    
		// Save to document
		NSData* imageData = UIImageJPEGRepresentation(newImage, 1.0);
		// Now we get the full path to the file
		NSString* fullPathToFile = [[NSHomeDirectory()stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"upload_avatar.jpg"];
		// and then we write it out
		[imageData writeToFile:fullPathToFile atomically:NO];

		[LuaOCBridge pickedImageCallback:fullPathToFile];
	} else {
		UIImage* newImage = [info objectForKey:UIImagePickerControllerOriginalImage];
		int w = (int)CGImageGetWidth(newImage.CGImage);
		int h = (int)CGImageGetHeight(newImage.CGImage);
		if(w > 1024 || h > 1024) {
			if(w > h) {
				newSize = CGSizeMake(1024, 1024 * h / w);
				NSLog(@"new size %d * %d", 1024, 1024 * h / w);
			} else {
				newSize = CGSizeMake(1024 * w / h, 1024);
				NSLog(@"new size %d * %d", 1024 * w / h, 1024);
			}
			
			// Create a graphics image context
			UIGraphicsBeginImageContext(newSize);
			// Tell the old image to draw in this new context, with the desired new size
			[newImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
			// Get the new image from the context
			newImage = UIGraphicsGetImageFromCurrentImageContext();
			// End the context
			UIGraphicsEndImageContext();
		}

		// Save to document
		NSData* imageData = UIImageJPEGRepresentation(newImage, 0.5);
		// Now we get the full path to the file
		NSString* fullPathToFile = [[NSHomeDirectory()stringByAppendingPathComponent:@"Documents"]stringByAppendingPathComponent:@"upload_pic.jpg"];
		// and then we write it out
		[imageData writeToFile:fullPathToFile atomically:YES];
		[LuaOCBridge pickupPicCallback:fullPathToFile];
	}
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if (self.popover)
    {
        [self.popover dismissPopoverAnimated:YES];
        self.popover = nil;
    }
    else
    {
        [self.imagePicker dismissModalViewControllerAnimated:YES];
        self.imagePicker = nil;
    }
	NSLog(@"imagePickerControllerDidCancel");
	if(self.canEdit) {
		[LuaOCBridge pickedImageCallback:nil];
	} else{
		[LuaOCBridge pickupPicCallback:nil];
	}
}

- (void) popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    if (self.popover)
    {
        [self.popover dismissPopoverAnimated:YES];
        self.popover = nil;
    }
    else
    {
        [self.imagePicker dismissModalViewControllerAnimated:YES];
        self.imagePicker = nil;
    }
    NSLog(@"popoverControllerDidDismissPopover");
	if(self.canEdit) {
		[LuaOCBridge pickedImageCallback:nil];
	} else{
		[LuaOCBridge pickupPicCallback:nil];
	}
}

- (void) navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

@end
