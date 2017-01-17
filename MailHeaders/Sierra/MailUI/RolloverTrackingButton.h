//
//     Generated by class-dump 3.5 (64 bit).
//
//     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2013 by Steve Nygard.
//

#import "ButtonPlus.h"

@class NSTrackingArea;

@interface RolloverTrackingButton : ButtonPlus
{
    BOOL _usesRolloverAppearanceInInactiveWindow;	// 172 = 0xac
    BOOL _usesRolloverAppearanceOnMouseDown;	// 173 = 0xad
    BOOL _redrawOnMouseEnteredAndExited;	// 174 = 0xae
    BOOL _mouseIsOver;	// 175 = 0xaf
    BOOL _trackingMouseDown;	// 176 = 0xb0
    id <RolloverTrackingButtonDelegate> _delegate;	// 184 = 0xb8
    NSTrackingArea *_trackingArea;	// 192 = 0xc0
}

@property(nonatomic) BOOL trackingMouseDown; // @synthesize trackingMouseDown=_trackingMouseDown;
@property(nonatomic) BOOL mouseIsOver; // @synthesize mouseIsOver=_mouseIsOver;
@property(retain, nonatomic) NSTrackingArea *trackingArea; // @synthesize trackingArea=_trackingArea;
@property(nonatomic) BOOL redrawOnMouseEnteredAndExited; // @synthesize redrawOnMouseEnteredAndExited=_redrawOnMouseEnteredAndExited;
@property(nonatomic) BOOL usesRolloverAppearanceOnMouseDown; // @synthesize usesRolloverAppearanceOnMouseDown=_usesRolloverAppearanceOnMouseDown;
@property(nonatomic) BOOL usesRolloverAppearanceInInactiveWindow; // @synthesize usesRolloverAppearanceInInactiveWindow=_usesRolloverAppearanceInInactiveWindow;
@property(nonatomic) __weak id <RolloverTrackingButtonDelegate> delegate; // @synthesize delegate=_delegate;
- (void).cxx_destruct;	// IMP=0x000000010028951a
- (void)rightMouseDown:(id)arg1;	// IMP=0x00000001002893c7
- (void)mouseExited:(id)arg1;	// IMP=0x0000000100289308
- (void)mouseEntered:(id)arg1;	// IMP=0x0000000100289249
- (void)updateMouseIsOver;	// IMP=0x0000000100289235
- (void)updateMouseIsOver:(long long)arg1;	// IMP=0x0000000100288fe8
@property(readonly, nonatomic) BOOL shouldUseRolloverAppearance;
- (void)mouseUp:(id)arg1;	// IMP=0x0000000100288ed4
- (void)mouseDown:(id)arg1;	// IMP=0x0000000100288e00
- (void)mouseEnteredOrExited:(BOOL)arg1;	// IMP=0x0000000100288d8b
- (void)updateTrackingAreas;	// IMP=0x0000000100288c79
- (void)dealloc;	// IMP=0x0000000100288c2f
- (void)_rolloverTrackingButtonCommonInit;	// IMP=0x0000000100288c13
- (id)initWithCoder:(id)arg1;	// IMP=0x0000000100288bce
- (id)initWithFrame:(struct CGRect)arg1;	// IMP=0x0000000100288b66

@end
