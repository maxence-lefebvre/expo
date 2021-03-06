//
//  BranchEvent+RNBranch.h
//  Branch-SDK
//
//  Created by Jimmy Dee on 11/28/17.
//

#import <Branch/Branch.h>

@interface BranchEvent(ABI28_0_0RNBranch)

- (instancetype)initWithName:(NSString *)eventName map:(NSDictionary *)map;

- (void)setRevenueWithString:(NSString *)revenue;
- (void)setShippingWithString:(NSString *)shipping;
- (void)setTaxWithString:(NSString *)tax;

@end
