//
//  BalanceViewController.m
//  LuhnAlgorithm
//
//  Created by Ticket Services on 14/09/17.
//  Copyright © 2017 UedaSoft IT Solutions. All rights reserved.
//

#import "BalanceViewController.h"
#define TCKContentType @"Content-Type"
#define TCKContentTypeAppJson @"application/json"
@interface BalanceViewController ()

@end

@implementation BalanceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(self.selectedCardNumber)
    {
        [self analyseCardStatus:self.selectedCardNumber];
        self.lblCardNumber.text = self.selectedCardNumber;
    }
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) analyseCardStatus: (NSString*) cardNumber
{
    NSURL *url = [NSURL URLWithString:@"https://api.ticket.com.br/usuarios/cartoes/v1/saldo"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod: @"POST"];
    
    
    [request setAllHTTPHeaderFields: @{TCKContentType : TCKContentTypeAppJson,
                                       @"Authorization" : @"Bearer 6bf7528050751bf29e1cd1a5b8b8621"}];
    
    NSString *requestBody = [NSString stringWithFormat: @"{\"cartao\":{\"numero\": \"%@\"}}", cardNumber];
    [request setHTTPBody:[requestBody dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                                     completionHandler:^( NSData *data, NSURLResponse *response, NSError *error)
                                      {
                                          
                                          if (error)
                                          {
                                              NSLog(@"Error: %@", error);
                                          }
                                          else
                                          {
                                              if(response)
                                              {
                                                  
                                                  NSDictionary *dictFromData = [NSJSONSerialization JSONObjectWithData:data
                                                                                                               options:NSJSONReadingAllowFragments
                                                                                                                 error:&error];
                                                  
                                                  if(dictFromData)
                                                  {
                                                      NSLog(@"Card: %@", self.selectedCardNumber);
                                                      NSDictionary *balanceData = [dictFromData objectForKey: @"cartaoSaldo"];
                                                      
                                                      if([balanceData isKindOfClass: [NSDictionary class]])
                                                      {
                                                          NSNumber *balance = [balanceData objectForKey: @"valor" ] ? [balanceData objectForKey: @"valor" ]: @0;
                                                          NSString *date = [balanceData objectForKey: @"data" ] ? [balanceData objectForKey: @"data" ]: @"N/A";
                                                          NSString *product = [balanceData objectForKey: @"produto" ] ? [balanceData objectForKey: @"produto" ]: @"N/A";
                                                          
                                                          
                                                          NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
                                                          
                                                          NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"pt_BR"];
                                                          formatter.locale = locale;
                                                          
                                                          formatter.usesGroupingSeparator = YES;
                                                          formatter.numberStyle = NSNumberFormatterCurrencyStyle;
                                                          formatter.currencySymbol = @"R$";
                                                          formatter.paddingPosition = NSNumberFormatterPadAfterPrefix;
                                                          formatter.paddingCharacter = @" ";
                                                          formatter.formatWidth = 7;
                                                          formatter.groupingSize = 3;
                                                          formatter.groupingSeparator = @".";
                                                          formatter.decimalSeparator = @",";
                                                          formatter.minimumIntegerDigits = 1;
                                                          formatter.maximumFractionDigits = 2;
                                                          formatter.minimumFractionDigits = 2;
                                                          

                                                          
                                                          
                                                          dispatch_async(dispatch_get_main_queue(),^{

                                                              NSString *formattedBalance = [formatter stringFromNumber:balance ?: @0];
                                                              
                                                              [self setLabelsWithBalance:formattedBalance withProduct:product withDate:date];
                                                          });
                                                          
                                                          
                                                          
                                                      }
                                                  }
                                              }
                                              
                                          }
                                      }];
    
    [dataTask resume];
    
    
}

-(void) setLabelsWithBalance: (NSString *) balance withProduct: (NSString*) product withDate: (NSString*) date
{
    [self.lblDate setText: date];
    [self.lblProduct setText: product];
    [self.lblBalanceValue setText: balance];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
