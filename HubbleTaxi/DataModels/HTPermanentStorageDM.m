//
//  HTPermanentStorageDM.m
//  HubbleTaxi
//
//  Created by Aamir Javed on 06/02/2014.
//  Copyright (c) 2014 Apponative. All rights reserved.
//

#import "HTPermanentStorageDM.h"

@implementation HTPermanentStorageDM


+ (void)storeObject:(id)object forApplicationLevelUniqueKey:(NSString<NSCopying> *)key
{
    if (object && key) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:object forKey:key];
        [userDefaults synchronize];
    }else
    {
        //Nothing to save, will get back nothing on retreive
    }
}

+ (id)getObjectForApplicationLevelUniqueKey:(NSString<NSCopying> *)key
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:key];
}

+ (void)removeObjectForApplicationLevelUniqueKey:(NSString<NSCopying> *)key
{
    if (key) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults removeObjectForKey:key];
        [userDefaults synchronize];
    }else
    {
        //Nothing to remove
    }
}
@end
