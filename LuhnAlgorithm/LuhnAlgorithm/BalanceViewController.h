//
//  BalanceViewController.h
//  LuhnAlgorithm
//
//  Created by Ticket Services on 14/09/17.
//  Copyright © 2017 UedaSoft IT Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BalanceViewController : UIViewController
@property(nonatomic, strong)  NSString *selectedCardNumber;
@property(nonatomic, weak) IBOutlet UILabel *lblCardNumber;
@property(nonatomic, weak) IBOutlet UILabel *lblProduct;
@property(nonatomic, weak) IBOutlet UILabel *lblBalanceValue;
@property(nonatomic, weak) IBOutlet UILabel *lblDate;


@end
