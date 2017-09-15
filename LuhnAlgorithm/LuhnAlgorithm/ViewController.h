//
//  ViewController.h
//  LuhnAlgorithm
//
//  Created by Ticket Services on 12/09/17.
//  Copyright © 2017 UedaSoft IT Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Luhn.h"
@interface ViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>


@property(nonatomic, weak)IBOutlet UITextField *txtCardNumber;
@property(nonatomic, weak)IBOutlet UITableView *tblPossibilities;
@property(nonatomic, weak)IBOutlet UIButton *btnValidate;
@property(nonatomic, strong) UIActivityIndicatorView *activityIndicator;


-(IBAction) verify: (id) sender;

@end

