//
//  DatabaseHelper.h
//  Hackatune
//
//  Created by Daniel Larsson on 2013-08-06.
//  Copyright (c) 2013 Spotify. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DatabaseHelper : NSObject

+ (DatabaseHelper *) sharedDatabaseHelper;

- (void)insertSongWithID:(NSString *)ID;
- (bool)selectSongWithID:(NSString *)ID;
- (void)clearSongs;

@end
