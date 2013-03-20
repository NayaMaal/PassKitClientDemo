//
//  CAViewController.h
//  PassKitDemo
//
//  Created by Global Logic on 20/03/13.
//  Copyright (c) 2013 Globallogic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PassKit/PassKit.h>

@interface CAViewController : UIViewController <UITableViewDelegate,
                                                UITableViewDataSource,
                                                PKAddPassesViewControllerDelegate,
                                                ASIHTTPRequestDelegate>
@property (strong, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) NSMutableArray *passes;

@end
