//
//  ViewController.h
//  CalBurner
//
//  Created by Diana Zmuda on 8/16/12.
//  Copyright (c) 2012 Diana Zmuda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *bodyWeightField;

- (IBAction)startButton;

- (IBAction)endButton;

@property (weak, nonatomic) IBOutlet UILabel *calSecLabel;

@property (weak, nonatomic) IBOutlet UILabel *totalCalLabel;

@end
