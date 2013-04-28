//
//  BrowsedRaceViewController.m
//  JustRace
//
//  Created by Laborator iOS on 4/8/13.
//  Copyright (c) 2013 Andra Mititelu. All rights reserved.
//

#import "BrowsedRaceViewController.h"
#import "MapViewController.h"
#import <Parse/Parse.h>

@interface BrowsedRaceViewController ()

@end

@implementation BrowsedRaceViewController

@synthesize race;

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
    
    self.nameLabel.text = [race objectForKey:@"raceName"];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd MM yyyy"];
    self.dateLabel.text = [formatter stringFromDate:[race objectForKey:@"raceDate"]];
    
    [formatter setDateFormat:@"hh:mm"];
    self.timeLabel.text = [formatter stringFromDate:[race objectForKey:@"raceTime"]];
    
    //NSLog(@"%@",[race objectForKey:@"username"]);
     PFQuery *query = [PFUser query];
     [query whereKey:@"username" equalTo:[race objectForKey:@"username"]];
     
     [query findObjectsInBackgroundWithBlock:^(NSArray *data, NSError *error){
     if (!error){
    // NSLog(@"%@",data);
     self.organizerLabel.text = [[data objectAtIndex:0] objectForKey:@"name"];
     } else{
     NSLog(@"eroare = %@",error);
     }
     }];
     
    
    if([(NSDate *)[race objectForKey:@"raceDate"] earlierDate:[NSDate date]])
    {
        [self.buttonC setTitle:@"Participants" forState:UIControlStateNormal];
        
        //posibilitate de a participa daca nu ai ales deja sa participi
        PFQuery *query = [PFQuery queryWithClassName:@"Participation"];
        [query whereKey:@"username" equalTo:[[PFUser currentUser] username]];
        [query whereKey:@"raceName" equalTo:[race objectForKey:@"raceName"]];
        [query findObjectsInBackgroundWithBlock:^(NSArray *data, NSError *error){
            if (!error){
                if([data count] > 0)
                {
                    UILabel *part= [[UILabel alloc] initWithFrame:CGRectMake(20, 330, self.view.frame.size.width - 40, 45)];
                    [part setFont:[UIFont boldSystemFontOfSize:17.0]];
                    part.text = @"You already joined this race!";
                    part.textAlignment = UITextAlignmentCenter;
                    [self.view addSubview:part];
                }
                else
                {
                    UIButton *partBut = [[UIButton alloc] initWithFrame:CGRectMake(25, 330,self.view.frame.size.width - 50, 45)];
                    [partBut setTitle:@"Join race!" forState:UIControlStateNormal];
                    [partBut setTitleShadowColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
                    [partBut setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
                    [partBut setBackgroundImage:[UIImage imageNamed:@"silver-button-normal.png"] forState:UIControlStateNormal];
                    [partBut addTarget:self action:@selector(joinRace:) forControlEvents:UIControlEventTouchDown];
                    [self.view addSubview:partBut];
                }
            } else{
                NSLog(@"eroare = %@",error);
            }
        }];
    }
    else
    {
        [self.buttonC setTitle:@"Results" forState:UIControlStateNormal];
    }
}

-(IBAction)joinRace:(id)sender
{
    PFObject *pt = [PFObject objectWithClassName:@"Participation"];
    [pt setObject:[race objectForKey:@"raceName"] forKey:@"raceName"];
    [pt setObject:[[PFUser currentUser] username] forKey:@"username"];
    [pt saveInBackground];
    
    UILabel *part= [[UILabel alloc] initWithFrame:CGRectMake(20, 330, self.view.frame.size.width - 40, 45)];
    part.text = @"You joined this race! Good luck!";
    [part setFont:[UIFont boldSystemFontOfSize:17.0]];
    part.textAlignment = UITextAlignmentCenter;
    [self.view addSubview:part];
    [(UIButton*)sender setHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)browsedRaceOpenMap:(id)sender {
    MapViewController *map = [[MapViewController alloc] initWithReturnController:self racePath:[race objectForKey:@"racePath"] editable:NO];
    [self.navigationController pushViewController:map animated:YES];
}

@end
