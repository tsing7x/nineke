//
//  ImagePicker.h
//  NineKe
//
//  Created by 李强 on 14-9-9.
//
//

#import <Foundation/Foundation.h>

@interface ImagePicker : NSObject <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverControllerDelegate>

@property (nonatomic, retain) UIImagePickerController *imagePicker;
@property (nonatomic, retain) UIPopoverController *popover;
@property BOOL canEdit;

- (void) showImagePicker;

@end
