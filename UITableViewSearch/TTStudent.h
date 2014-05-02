//
//  TTStudent.h
//  UITableViewSearch
//
//  Created by Sergey Reshetnyak on 4/29/14.
//  Copyright (c) 2014 sergey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TTStudent : NSObject

@property (strong,nonatomic) NSString *firstName;
@property (strong,nonatomic) NSString *lastName;
@property (strong,nonatomic) NSDate *bornDate;

+ (TTStudent *)getRandomStudent;

@end
