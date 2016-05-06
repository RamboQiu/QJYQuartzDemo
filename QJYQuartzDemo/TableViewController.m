//
//  TableViewController.m
//  QJYQuartzDemo
//
//  Created by QiuJunyun on 16/5/6.
//  Copyright © 2016年 QiuJunyun. All rights reserved.
//

#import "TableViewController.h"
#import "ViewController.h"

@implementation TableViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ViewController *vc = segue.destinationViewController;
    vc.loadViewClass = [NSString stringWithFormat:@"MyView%@", segue.identifier];
}
@end
