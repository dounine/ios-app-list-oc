//
//  MyTableViewController.m
//  ios_list_app2
//
//  Created by lake on 2024/7/25.
//

#import <Foundation/Foundation.h>
#import "MyTableViewController.h"
#import <objc/runtime.h>
@implementation MyTableViewController

- (NSString*)version:(NSObject*)app{
    NSString *name = [app performSelector:@selector(shortVersionString)];
    return name;
}
-(NSString*)bundleID:(NSObject*)app{
    NSString *name = [app performSelector:@selector(bundleIdentifier)];
    return name;
}
- (NSString *)displayName:(NSObject*)app {
    NSString *name = [app performSelector:@selector(itemName)];
    NSString *localizedName = name;
    NSURL *bundleURL = [app performSelector:@selector(bundleURL)];
    if (!bundleURL || ![bundleURL checkResourceIsReachableAndReturnError:nil]) {
        localizedName = name;
    } else {
        //        NSString *plistPath = [[bundleURL absoluteString] stringByAppendingString:@"Info.plist"];
        //        NSLog(@"bundleIdentifier -> %@", plistPath);
        //        NSBundle *bundle = [NSBundle bundleWithPath:plistPath];
        if (![localizedName isKindOfClass:[NSString class]]) localizedName = nil;
        if (!localizedName || [localizedName isEqualToString:@""]) {
            localizedName = [app performSelector:@selector(localizedName)];
            if (!localizedName || [localizedName isEqualToString:@""]) {
                NSBundle *bundle = [NSBundle bundleWithURL:bundleURL];
                localizedName = [bundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];
                if (![localizedName isKindOfClass:[NSString class]]) localizedName = nil;
                if (!localizedName || [localizedName isEqualToString:@""]) {
                    localizedName = [bundle objectForInfoDictionaryKey:@"CFBundleName"];
                    if (![localizedName isKindOfClass:[NSString class]]) localizedName = nil;
                    if (!localizedName || [localizedName isEqualToString:@""]) {
                        localizedName = [bundle objectForInfoDictionaryKey:@"CFBundleExecutable"];
                        if (![localizedName isKindOfClass:[NSString class]]) localizedName = nil;
                        if (!localizedName || [localizedName isEqualToString:@""]) {
                            //last possible fallback: use slow IPC call
                            localizedName = name;
                        }
                    }
                }
            }
        }
    }
    return localizedName;
}

-(NSMutableArray*)appList{
    Class lsawsc = objc_getClass("LSApplicationWorkspace");
    NSObject *workspace = [lsawsc performSelector:@selector(defaultWorkspace)];
    NSArray *plugins = [workspace performSelector:@selector(installedPlugins)]; //列出所有plugins
    NSMutableSet *list = [[NSMutableSet alloc] init];
    for (NSObject* plugin in plugins) {
        id bundle = [plugin performSelector:@selector(containingBundle)];
        if (bundle) {
            [list addObject:bundle];
        }
    }
    NSMutableArray *array = [NSMutableArray array];
    for (NSObject* app in list){
        NSString* name = [self displayName:app];
        NSString* version = [self version:app];
        NSString* bundleID = [self bundleID:app];
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:name forKey:@"name"];
        if(version!=nil){
            [dict setObject:version forKey:@"version"];
        }else{
            [dict setObject:@"" forKey:@"version"];
        }
        if(bundleID!=nil){
            [dict setObject:bundleID forKey:@"bundleID"];
            [array addObject:dict];
        }
        NSLog(@"name:%@ version:%@ bundleID:%@",name,version,bundleID);
    }
    return array;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.title = @"应用列表";
    
    UITableView *tableView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
    
    //设置表头视图
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 200)];
    headerView.backgroundColor = [UIColor redColor];
    tableView.tableHeaderView = headerView;
    //设置表尾视图
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 200)];
    footerView.backgroundColor = [UIColor blueColor];
    tableView.tableFooterView = footerView;
    
    //设置tableView的数据源
    tableView.dataSource = self;
    //设置tableView的Delegate
    tableView.delegate = self;
    //    tableView.separatorInset = UIEdgeInsetsMake(10,10,10,10);
    
    self.dataSource = [self appList];
    [self.view addSubview:tableView];
    
}

// 必要的UITableViewDataSource实现
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // 返回行数
    return self.dataSource.count;
}
- (NSUInteger)iconFormat {
    return (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad) ? 8 : 10;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 返回单元格
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@(indexPath.row)];
//    cell.textLabel.text = @"hello";
    NSMutableDictionary *app = self.dataSource[indexPath.row];
    cell.textLabel.text = app[@"name"];
    cell.detailTextLabel.text = [app[@"bundleID"] stringByAppendingString:[@" " stringByAppendingString: app[@"version"]]];
    
    cell.image = [UIImage _applicationIconImageForBundleIdentifier:app[@"bundleID"] format:self.iconFormat scale:[UIScreen mainScreen].scale];
//        if (indexPath.section == 0) {
//            if (indexPath.row == 0) {
//                cell.textLabel.text = @"你好吗??";
//            }else {
//                cell.textLabel.text = @"这是一个单元格";
//            }
//            return cell;
//        }
    // 配置单元格
    return cell;
}

@end