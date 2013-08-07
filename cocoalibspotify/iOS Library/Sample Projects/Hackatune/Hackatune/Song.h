//
//  Song.h
//  Hackatune
//
//  Created by Daniel Larsson on 2013-08-06.
//  Copyright (c) 2013 Spotify. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Song : NSManagedObject

@property (nonatomic, retain) NSString * songID;

@end
