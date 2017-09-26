//
//  ViewController.m
//  GDDatePicking
//
//  Created by BM-138-Dinesh on 26/09/17.
//  Copyright © 2017 Bimarian. All rights reserved.
//

#import "ViewController.h"
#import "GDDatePickerCell.h"
@interface ViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
{
    NSMutableArray *datesArr;
    NSIndexPath *selectedIndexPath;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    datesArr=[[NSMutableArray alloc] init];
    
    // Here I took dates upto 7 days from Current date.
    datesArr=[self fillDatesFromDate:[NSDate date] numberOfDays:7];
//    if u want to enable the scroll Put Scroll Enabled to YES;
    self.datePickerCollectionView.scrollEnabled=NO;
    
    self.datePickerCollectionView.delegate=self;
    self.datePickerCollectionView.dataSource=self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark getting dates Array Reference from DIDatePicker

// This method provides the date between two dates
- (NSMutableArray*)fillDatesFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate
{
    NSAssert([[NSDate date] compare:toDate] == NSOrderedAscending, @"toDate must be after fromDate");
    
    NSMutableArray *dates = [[NSMutableArray alloc] init];
    NSDateComponents *days = [[NSDateComponents alloc] init];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSInteger dayCount = 0;
    while(YES){
        [days setDay:dayCount++];
        NSDate *date = [calendar dateByAddingComponents:days toDate:[NSDate date] options:0];
        
        if([date compare:toDate] == NSOrderedDescending) break;
        [dates addObject:date];
    }
    return  dates;
}

// This method provides the dates upto N Number of days from provided date

- (NSMutableArray*)fillDatesFromDate:(NSDate *)fromDate numberOfDays:(NSInteger)numberOfDays
{
    NSDateComponents *days = [[NSDateComponents alloc] init];
    [days setDay:numberOfDays];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
  return  [self fillDatesFromDate:fromDate toDate:[calendar dateByAddingComponents:days toDate:fromDate options:0]];
}
#pragma mark -- CollectionView Delegates

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(90,90);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return datesArr.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    GDDatePickerCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"GDDatePickerCell" forIndexPath:indexPath];
    if (indexPath==selectedIndexPath) {
        cell.dateShowLbl.attributedText=[self convertDateForCells:[datesArr objectAtIndex:indexPath.row] isselected:YES];
        cell.dateShowLbl.layer.borderWidth=2.0;
        cell.dateShowLbl.layer.borderColor=[UIColor orangeColor].CGColor;
    }
    else{
        cell.dateShowLbl.attributedText=[self convertDateForCells:[datesArr objectAtIndex:indexPath.row] isselected:NO];
        cell.dateShowLbl.layer.borderWidth=2.0;
        cell.dateShowLbl.layer.borderColor=[UIColor clearColor].CGColor;
    }
    
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    // Unhighlighting the selected cell by removing label layer color
    GDDatePickerCell *selectedCell =(GDDatePickerCell*)[collectionView cellForItemAtIndexPath:selectedIndexPath];
    selectedCell.dateShowLbl.attributedText=[self convertDateForCells:[datesArr objectAtIndex:selectedIndexPath.row] isselected:NO];
    selectedCell.dateShowLbl.layer.borderWidth=2.0;
    selectedCell.dateShowLbl.layer.borderColor=[UIColor clearColor].CGColor;
    
    // Moving cell to center
    [self.datePickerCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    // highlighting the selected cell by adding label layer color

    GDDatePickerCell *cell =(GDDatePickerCell*)[collectionView cellForItemAtIndexPath:indexPath];
    cell.dateShowLbl.attributedText=[self convertDateForCells:[datesArr objectAtIndex:indexPath.row] isselected:YES];
    cell.dateShowLbl.layer.borderWidth=2.0;
    cell.dateShowLbl.layer.borderColor=[UIColor orangeColor].CGColor;
    selectedIndexPath=indexPath;
}
#pragma mark -- Converting date
- (NSAttributedString*)convertDateForCells:(NSDate *)date isselected:(BOOL)cellSelected
{
    NSString *fontName;
    UIColor *fontColor;
    if (cellSelected) {
        fontColor=[UIColor blackColor];
        fontName=@"HelveticaNeue-Bold";
    }
    else{
        fontColor=[UIColor lightGrayColor];
        fontName=@"HelveticaNeue-Medium";
    }
    // if nsdictionary if i get dates from service call
    
  NSDateFormatter*  dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd"];
    NSDate *converteddate=date;        //[parseFormatter dateFromString:ddstr];
    
    NSString *dayFormattedString = [dateFormatter stringFromDate:converteddate];
    
    [dateFormatter setDateFormat:@"EEE"];
    NSString *dayInWeekFormattedString = [dateFormatter stringFromDate:converteddate];
    
    [dateFormatter setDateFormat:@"MMM"];
    NSString *monthFormattedString = [[dateFormatter stringFromDate:converteddate] uppercaseString];
    
    NSMutableAttributedString *dateString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@\n%@",monthFormattedString, dayFormattedString, [dayInWeekFormattedString uppercaseString]]];
    
    [dateString addAttributes:@{
                                NSFontAttributeName: [UIFont fontWithName:fontName size:10],
                                NSForegroundColorAttributeName: fontColor
                                } range:NSMakeRange(0, monthFormattedString.length)];
    
    [dateString addAttributes:@{
                                NSFontAttributeName: [UIFont fontWithName:fontName size:25],
                                NSForegroundColorAttributeName: fontColor
                                } range:NSMakeRange(monthFormattedString.length + 1, dayFormattedString.length)];
    
    [dateString addAttributes:@{
                                NSFontAttributeName: [UIFont fontWithName:fontName size:12],
                                NSForegroundColorAttributeName: fontColor
                                } range:NSMakeRange(dateString.string.length - dayInWeekFormattedString.length, dayInWeekFormattedString.length)];
    
    //    if ([self isHoliday:date]) {
    //        [dateString addAttribute:NSFontAttributeName
    //                           value:[UIFont fontWithName:@"HelveticaNeue-Medium" size:8]
    //                           range:NSMakeRange(dayFormattedString.length + 1, dayInWeekFormattedString.length)];
    //    }
    
     return dateString;
}
@end
