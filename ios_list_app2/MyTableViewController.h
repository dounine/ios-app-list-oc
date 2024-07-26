//
//  MyTableViewController.h
//  ios_list_app2
//
//  Created by lake on 2024/7/25.
//

#import <UIKit/UIKit.h>

@interface UIImage (Private)
+ (UIImage *)_applicationIconImageForBundleIdentifier:(NSString *)bundleIdentifier format:(NSUInteger)format scale:(CGFloat)scale;
@end

@interface MyTableViewController : UITableViewController
@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic,strong) NSObject* workspace;
@end
