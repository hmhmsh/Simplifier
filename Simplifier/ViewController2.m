//
//  ViewController2.m
//  Simplifier
//
//  Created by 長谷川瞬哉 on 2015/07/09.
//  Copyright (c) 2015年 長谷川瞬哉. All rights reserved.
//

#import "ViewController2.h"

@interface ViewController2 ()
{
  UIView* cellView;
  UILabel* label;
}
@end

@implementation ViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
  
  self.view.backgroundColor = [UIColor whiteColor];
  
  _tableView.delegate = self;
  _tableView.dataSource = self;
  _tableView.hidden = NO;
  

  
  _tableView.backgroundColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSString *cellIdentifier = @"Cell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  
  // セルが作成されていないか?
  if (!cell) { // yes
    // セルを作成
    cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
  }
  
  UIView* baseView = [[UIView alloc]init];
  baseView.frame = CGRectMake(0, 0, cell.frame.size.width, 200);
  baseView.layer.masksToBounds = YES;
  baseView.layer.borderColor = [UIColor blackColor].CGColor;
  baseView.layer.borderWidth = 1.0;
  baseView.backgroundColor = [UIColor redColor];
  [cell addSubview:baseView];
  
  cellView = [[UIView alloc]init];
  cellView.frame = CGRectMake(10, 10, 50, 50);
  cellView.backgroundColor = [UIColor whiteColor];
  cellView.layer.masksToBounds = YES;
  cellView.layer.borderColor = [UIColor blackColor].CGColor;
  cellView.layer.borderWidth = 2.0;
  cellView.contentMode = UIViewContentModeScaleAspectFit;
  [baseView addSubview:cellView];
  
  UIImage* image = [UIImage imageNamed:@"100837s.jpg"];
  CALayer* imageLayer = [[CALayer alloc]init];
  imageLayer.frame = CGRectMake(0, 0, image.size.width, image.size.height);
  NSLog(@"imageLayer size :%@", NSStringFromCGRect(imageLayer.frame));
  
  imageLayer.contents = (id)image.CGImage;
  [cellView.layer addSublayer:imageLayer];
  
  CGRect rect = cellView.frame;
  rect.size.width = imageLayer.frame.size.width;
  rect.size.height = imageLayer.frame.size.height;
  cellView.frame = rect;
  
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return 200;
}

/**
 * セルが選択されたとき
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//  UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)dealloc {
    [_tableView release];
    [super dealloc];
}
@end
