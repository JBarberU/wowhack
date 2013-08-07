//
//  DatabaseHelper.m
//  Hackatune
//
//  Created by Daniel Larsson on 2013-08-06.
//  Copyright (c) 2013 Spotify. All rights reserved.
//

#import "DatabaseHelper.h"
#import "HackatuneAppDelegate.h"
#import "Song.h"

@implementation DatabaseHelper

+ (id)sharedDatabaseHelper
{
    static DatabaseHelper *sharedInstance = nil;
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        sharedInstance = [DatabaseHelper alloc];
        sharedInstance = [sharedInstance init];
    });
    
    return sharedInstance;
}

- (void)insertSongWithID:(NSString *)ID
{
    HackatuneAppDelegate *appDelegate = (HackatuneAppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSManagedObject *song = [NSEntityDescription insertNewObjectForEntityForName:@"Song" inManagedObjectContext:context];
    [song setValue:(ID) forKey:@"songID"];
    NSLog(@"Inserted song: %@", ID);
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
}

- (bool)selectSongWithID:(NSString *)ID
{
    HackatuneAppDelegate *appDelegate = (HackatuneAppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Song" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    for (Song *song in fetchedObjects) {
        NSString *songID = song.songID;
        if ([songID isEqualToString:ID]){
            NSLog(@"Song already played!");
            return YES;
        }
    } return NO;
}

- (void)clearSongs
{
    HackatuneAppDelegate *appDelegate = (HackatuneAppDelegate *)[[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Song" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    for (Song *song in fetchedObjects) {
        [context deleteObject:song];
    } 
}

@end
