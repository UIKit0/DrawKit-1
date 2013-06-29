//
//  DKRuntimeHelper.m
///  DrawKit ©2005-2008 Apptree.net
//
//  Created by graham on 27/03/2008.
///
///	 This software is released subject to licensing conditions as detailed in DRAWKIT-LICENSING.TXT, which must accompany this source file.
//

#import "DKRuntimeHelper.h"

#import "LogEvent.h"

#import <objc/objc-runtime.h>


@implementation DKRuntimeHelper


+ (NSArray*)	allClasses
{
	return [self allClassesOfKind:[NSObject class]];
}


+ (NSArray*)	allClassesOfKind:(Class) aClass
{
	// returns a list of all Class objects that are of kind <aClass> or a subclass of it currently registered in the runtime. This caches the
	// result so that the relatively expensive run-through is only performed the first time
	
	static NSMutableDictionary* cache = nil;
	
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [[NSMutableDictionary alloc] init];
    });
    
    @synchronized (cache) {
        if (![[cache allKeys] containsObject:NSStringFromClass(aClass)]) {
            NSMutableArray*	list = [NSMutableArray array];
            
            int numClasses = objc_getClassList(NULL, 0);
            Class *classes = NULL;
            
            classes = malloc(sizeof(Class) * numClasses);
            numClasses = objc_getClassList(classes, numClasses);
            
            for (int i = 0; i < numClasses; i++) {
                Class superClass = classes[i];
                do {
                    superClass = class_getSuperclass(superClass);
                } while(superClass && superClass != aClass);
                
                if (superClass == nil) {
                    continue;
                }
                
                [list addObject:classes[i]];
            }
            
            free(classes);
            
            [cache setObject:list forKey:NSStringFromClass( aClass )];
        }
    }
	
	return [cache objectForKey:NSStringFromClass( aClass )];
}


+ (NSArray*)	allImmediateSubclassesOf:(Class) aClass
{
	static NSMutableDictionary* cache = nil;
	
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [[NSMutableDictionary alloc] init];
    });
    
    @synchronized (cache) {
        if (![[cache allKeys] containsObject:NSStringFromClass(aClass)]) {
            NSArray *allSubclasses = [self allClassesOfKind:aClass];
            NSMutableArray *list = [[allSubclasses mutableCopy] autorelease];
            for (Class subclass in allSubclasses) {
                if (![[subclass superclass] isEqualTo:aClass]) {
                    [list removeObject:subclass];
                }
            }
            
            [cache setObject:list forKey:NSStringFromClass( aClass )];
        }
    }
    
	return [cache objectForKey:NSStringFromClass(aClass)];
}



@end
