//
//  HTPermanentStorageDM.h
//  HubbleTaxi
//
//  Created by Aamir Javed on 06/02/2014.
//  Copyright (c) 2014 Apponative. All rights reserved.
//

#import "HTDataModel.h"

@interface HTPermanentStorageDM : HTDataModel

+ (void)storeObject:(id)object forApplicationLevelUniqueKey:(NSString<NSCopying>*)key;
+ (id)getObjectForApplicationLevelUniqueKey:(NSString<NSCopying> *)key;
+ (void)removeObjectForApplicationLevelUniqueKey:(NSString<NSCopying> *)key;


@end
