
#ifndef SYNTHESIZE_SINGLETON_FOR_CLASS

//
//  SynthesizeSingleton.h
//  CocoaWithLove
//
//  Created by Matt Gallagher on 20/10/08.
//  Copyright 2009 Matt Gallagher. All rights reserved.
//
//  Permission is given to use this source code file without charge in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//
//  Modified and optimized by Andreas Hanft (talantium.net) on
//  19.12.11 (dispatch_once), 12.02.13. (ARC).
//

/**
 *	#########		Usage:		##########
 *
 *	1) #import this header at the top of a class implementation
 *
 *	2) Add 
 
            SYNTHESIZE_SINGLETON_FOR_CLASS(MyClassName, accessor)
 
       inside the @implementation, as accessor use something like 'sharedManager'.
 *
 *	3)	Add + (MyClassName*) accessor; to the @interface
 *
 */


#if  __has_feature(objc_arc)

#define SYNTHESIZE_SINGLETON_FOR_CLASS(classname, accessor) \
\
static classname* shared##classname = nil; \
\
+ (classname*) accessor \
{ \
    static dispatch_once_t pred; \
    dispatch_once(&pred, \
    ^{ \
        shared##classname = [[self alloc] init]; \
    }); \
    \
    return shared##classname; \
} \
\
\
+ (id) allocWithZone:(NSZone *)zone \
{ \
    @synchronized(self) \
    { \
        if (shared##classname == nil) \
        { \
            shared##classname = [super allocWithZone:zone]; \
            \
            return shared##classname; \
        } \
    } \
    \
    return nil; \
} \
\
- (id) copyWithZone:(NSZone *)zone \
{ \
    return self; \
} \

#else

#define SYNTHESIZE_SINGLETON_FOR_CLASS(classname, accessor) \
 \
static classname* shared##classname = nil; \
 \
+ (classname*) accessor \
{ \
    static dispatch_once_t pred; \
    dispatch_once(&pred, \
    ^{ \
        shared##classname = [[self alloc] init]; \
    }); \
     \
    return shared##classname; \
} \
 \
 \
+ (id) allocWithZone:(NSZone *)zone \
{ \
	@synchronized(self) \
	{ \
		if (shared##classname == nil) \
		{ \
			shared##classname = [super allocWithZone:zone]; \
             \
			return shared##classname; \
		} \
	} \
	 \
	return nil; \
} \
 \
- (id) copyWithZone:(NSZone *)zone \
{ \
	return self; \
} \
 \
- (id) retain \
{ \
	return self; \
} \
 \
- (NSUInteger) retainCount \
{ \
	return NSUIntegerMax; \
} \
 \
- (oneway void) release \
{ \
} \
 \
- (id) autorelease \
{ \
	return self; \
}

#endif

#endif /* SYNTHESIZE_SINGLETON_FOR_CLASS */
