//
//  CAViewController.m
//  PassKitDemo
//
//  Created by Global Logic on 20/03/13.
//  Copyright (c) 2013 Globallogic. All rights reserved.
//

#import "CAViewController.h"

@interface CAViewController ()
-(void)openPassWithName:(NSString*)name;
- (void)reloadData;
- (NSString *) applicationDocumentsDirectory;
@end

@implementation CAViewController
@synthesize passes = _passes;
@synthesize inData;
@synthesize library = _library;
- (NSString *) applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}


- (IBAction)refreshData:(id)sender {
    self.inData = nil;
    NSURL *url = [[NSURL alloc] initWithString:@"http://172.17.10.62:12345/coupen.pkpass"];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
    [request setDelegate:self];
    self.inData = [NSMutableData dataWithCapacity:0];
    [request startAsynchronous];
}
- (void)reloadData {
    [self.passes removeAllObjects];
    /*NSString* resourcePath = [[NSBundle mainBundle] resourcePath];
    
    NSArray* passFiles = [[NSFileManager defaultManager]
                          contentsOfDirectoryAtPath:resourcePath
                          error:nil];

    for (NSString* passFile in passFiles) {
        if ( [passFile hasSuffix:@".pkpass"] ) {
            [self.passes addObject: passFile];
        }
    }*/
    
    
    NSArray* passFilesForDocument = [[NSFileManager defaultManager]
                          contentsOfDirectoryAtPath:[self applicationDocumentsDirectory]
                          error:nil];

    for (NSString* passFile in passFilesForDocument) {
        if ( [passFile hasSuffix:@".pkpass"] ) {
            [self.passes addObject: passFile];
        }
    }
}
+ (NSString *) applicationDocumentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    if (![PKPassLibrary isPassLibraryAvailable]) {
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:@"PassKit not available"
                                   delegate:nil
                          cancelButtonTitle:@"Pitty"
                          otherButtonTitles: nil] show];
        return;
    }
    _library = [[PKPassLibrary alloc] init];
    //1 initialize objects
    _passes = [[NSMutableArray alloc] init];

    //2 load the passes from the resource folder
   
    [self reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark- TableviewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *selectedPass = [self.passes objectAtIndex:indexPath.row];
    
    [self openPassWithName:selectedPass];
}

#pragma mark - TableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.passes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifire = @"PassesRows";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifire];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifire];
    }
    NSString *object = _passes[indexPath.row];
    cell.textLabel.text = object;
    return cell;
}
#pragma mark - PKAddPassesDelegate
-(void)addPassesViewControllerDidFinish:(PKAddPassesViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark PassLoadLogic
-(void)openPassWithName:(NSString*)name
{
    NSString* passFile = [[self applicationDocumentsDirectory] stringByAppendingPathComponent: name];
    //NSString* passFile = [[[NSBundle mainBundle] resourcePath]                          stringByAppendingPathComponent: name];
    
    NSLog(@"path %@",passFile);
    NSData *passData = [NSData dataWithContentsOfFile:passFile];
    
    NSError* error = nil;
    PKPass *newPass = [[PKPass alloc] initWithData:passData
                                             error:&error];
    if (error!=nil) {
        [[[UIAlertView alloc] initWithTitle:@"Error!"
                                    message:[error
                                             localizedDescription]
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles: nil] show];
        return;
    }
    
    PKAddPassesViewController *addController =
    [[PKAddPassesViewController alloc] initWithPass:newPass];
    
    addController.delegate = self;
    [self presentViewController:addController
                       animated:YES
                     completion:nil];
}

#pragma mark - ASIHTTP Request Delegate
- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders {
    
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSString *path = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"CustomPass.pkpass"];
    [self.inData writeToFile:path atomically:YES];
    [self reloadData];
    [self.myTableView reloadData];
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    
}

- (void)request:(ASIHTTPRequest *)request didReceiveData:(NSData *)data {
    [self.inData appendData:data];
}

@end
