/*
 *     Generated by class-dump 3.4 (64 bit).
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2012 by Steve Nygard.
 */

#import "NSObject.h"

#import "MFMessageConsumer.h"

@class MCInvocationQueue, MFLibraryStore;

@interface MFLibraryStoreMessageConsumer : NSObject <MFMessageConsumer>
{
    MFLibraryStore *_libraryStore;
    MCInvocationQueue *_callbackQueue;
    BOOL _shouldCancel;
    long long _collectorID;
}

@property BOOL shouldCancel; // @synthesize shouldCancel=_shouldCancel;
@property long long collectorID; // @synthesize collectorID=_collectorID;
- (void)finishedSendingMessages;
- (void)searchPhaseComplete;
- (id)libraryNotificationMessages;
- (id)libraryNotificationObject;
- (void)newMessagesAvailable:(id)arg1 conversationsMembersByConversationID:(id)arg2 options:(id)arg3;
- (void)dealloc;
- (void)clearLibraryStoreWeakReference;
- (id)initWithLibraryStore:(id)arg1 useCallbackQueue:(BOOL)arg2;

@end
