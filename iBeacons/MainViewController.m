//
//  MainViewController.m
//  iBeacons
//
//  Created by Apple on 14-3-3.
//  Copyright (c) 2014年 meng.wang. All rights reserved.
//

#import "MainViewController.h"
#pragma mark UIKeyboard handling

#define kMin 150

@interface MainViewController ()

@end

@implementation MainViewController

@synthesize textInputBox;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (IBAction)viewDown:(id)sender {
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    
}

-(IBAction)flootPlanId:(id)sender{
    if ([textInputBox.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Warnning" message:@"Please input your floorplanid!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
    }else{
        [self performSegueWithIdentifier:@"List" sender:self];
    }
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"List"]){
        MenuViewController *nameViewController;
        nameViewController=segue.destinationViewController;
        //ip:68.52.143.43
        //http://1.mccnav.appspot.com/floorplan.editor.html#/floorplan/
        nameViewController.subUrlString=[@"http://1.mccnav.appspot.com/mcc/floorplan/" stringByAppendingString: textInputBox.text];
        nameViewController.floorPlanId=textInputBox.text;
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)sender
{

    //move the main view, so that the keyboard does not hide it.
    if (self.view.frame.origin.y + textInputBox.frame.origin. y >= kMin) {
        [self setViewMovedUp:YES];
    }
}



//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    if (movedUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y = kMin - textInputBox.frame.origin.y ;
    }
    else
    {
        // revert back to the normal state.
        rect.origin.y = 0;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}


- (void)keyboardWillShow:(NSNotification *)notif
{
    //keyboard will be shown now. depending for which textfield is active, move up or move down the view appropriately
    
    if ([textInputBox isFirstResponder] && textInputBox.frame.origin.y + self.view.frame.origin.y >= kMin)
    {
        [self setViewMovedUp:YES];
    }
    else if (![textInputBox isFirstResponder] && textInputBox.frame.origin.y  + self.view.frame.origin.y < kMin)
    {
        [self setViewMovedUp:NO];
    }
}

- (void)keyboardWillHide:(NSNotification *)notif
{
    //keyboard will be shown now. depending for which textfield is active, move up or move down the view appropriately
    if (self.view.frame.origin.y < 0 ) {
        [self setViewMovedUp:NO];
    }
    
}


- (void)viewWillAppear:(BOOL)animated
{
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:self.view.window];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    // all settings are basic, pages with custom packgrounds, title image on each page
    [self showIntroWithCrossDissolve];
}

- (void)showIntroWithCrossDissolve {
    EAIntroPage *page1 = [EAIntroPage page];
    page1.title = @"Hello iBeacons";
    page1.desc = @"Frist you should input the floorplanid.";
    page1.bgImage = [UIImage imageNamed:@"1"];
    page1.titleImage = [UIImage imageNamed:@"original"];
    
    EAIntroPage *page2 = [EAIntroPage page];
    page2.title = @"Second Step";
    page2.desc = @"Choose the room you want to record.";
    page2.bgImage = [UIImage imageNamed:@"2"];
    page2.titleImage = [UIImage imageNamed:@"supportcat"];
    
    EAIntroPage *page3 = [EAIntroPage page];
    page3.title = @"Final Step";
    page3.desc = @"Press the record button and test it. In the multiply record paper, u could shake your phone to remove recorded messages";
    page3.bgImage = [UIImage imageNamed:@"3"];
    page3.titleImage = [UIImage imageNamed:@"femalecodertocat"];
    
    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:self.view.bounds andPages:@[page1,page2,page3]];
    
    [intro setDelegate:self];
    [intro showInView:self.view animateDuration:0.0];
}

- (void)introDidFinish {
//    NSLog(@"Intro callback");
}


@end
