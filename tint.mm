#import <AppKit/AppKit.h>

#include "tint.h"

#define CONTENT_EFFECT_VIEW_TAG 100022
#define INSPECTOR_EFFECT_VIEW_TAG 100023
#define TITLEBAR_BACKGROUND_VIEW_TAG 100024
#define TITLEBAR_EFFECT_VIEW_TAG 100025

@interface DCTaggedVisualEffectView : NSVisualEffectView
@property(readwrite) NSInteger tag;
@end

@implementation DCTaggedVisualEffectView
@synthesize tag = _tag;
@end

@interface DCTaggedView : NSView
@property(readwrite) NSInteger tag;
@end

@implementation DCTaggedView
@synthesize tag = _tag;
@end

napi_value setWindowLayout(napi_env env, napi_callback_info info) {
	napi_status status;

	size_t argc = 4;
	napi_value args[4];
	status = napi_get_cb_info(env, info, &argc, args, 0, 0);
	if (status != napi_ok) {
		napi_throw_error(env, NULL, "setWindowLayout(): failed to get arguments");
		return NULL;
	} else if (argc < 3) {
		napi_throw_error(env, NULL, "setWindowLayout(): wrong number of arguments");
		return NULL;
	}

	void *windowBuffer;
	size_t windowBufferLength;
	status = napi_get_buffer_info(env, args[0], &windowBuffer, &windowBufferLength);
	if (status != napi_ok) {
		napi_throw_error(env, NULL, "setWindowLayout(): cannot read window handle");
		return NULL;
	} else if (windowBufferLength == 0) {
		napi_throw_error(env, NULL, "setWindowLayout(): empty window handle");
		return NULL;
	}

	NSView *mainWindowView = *static_cast<NSView **>(windowBuffer);
	if (![mainWindowView respondsToSelector:@selector(window)] || mainWindowView.window == nil) {
		napi_throw_error(env, NULL, "setWindowLayout(): NSView doesn't contain window");
		return NULL;
	}

	int sidebarWidth;
	status = napi_get_value_int32(env, args[1], &sidebarWidth);
	if (status != napi_ok) {
		napi_throw_error(env, NULL, "setWindowLayout(): cannot read sidebarWidth from args");
		return NULL;
	}

	int titlebarHeight;
	status = napi_get_value_int32(env, args[2], &titlebarHeight);
	if (status != napi_ok) {
		napi_throw_error(env, NULL, "setWindowLayout(): cannot read titlebarHeight from args");
		return NULL;
	}

	int titlebarMarginRight = 0;
	if (argc >= 4) {
		status = napi_get_value_int32(env, args[3], &titlebarMarginRight);
		if (status != napi_ok) {
			napi_throw_error(env, NULL, "setWindowLayout(): cannot read titlebarMarginRight from args");
			return NULL;
		}
	}

	NSWindow *window = mainWindowView.window;
	NSView *view = window.contentView;

	DCTaggedVisualEffectView *contentEffectView =
	    (DCTaggedVisualEffectView *)[view viewWithTag:CONTENT_EFFECT_VIEW_TAG];
	if (contentEffectView) {
		contentEffectView.frame =
		    CGRectMake(sidebarWidth, 0, [view frame].size.width - sidebarWidth - titlebarMarginRight,
			       [view frame].size.height - titlebarHeight);
	} else {
		contentEffectView = [[DCTaggedVisualEffectView alloc]
		    initWithFrame:CGRectMake(sidebarWidth, 0,
					     [view frame].size.width - sidebarWidth - titlebarMarginRight,
					     [view frame].size.height - titlebarHeight)];
		[contentEffectView setBlendingMode:NSVisualEffectBlendingModeBehindWindow];
		[contentEffectView setMaterial:NSVisualEffectMaterialWindowBackground];
		[contentEffectView setTag:CONTENT_EFFECT_VIEW_TAG];
		if ([[view subviews] count] > 0) {
			[view addSubview:contentEffectView
			      positioned:NSWindowAbove
			      relativeTo:[[view subviews] objectAtIndex:0]];
		} else {
			[view addSubview:contentEffectView];
		}
		contentEffectView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
	}

	DCTaggedVisualEffectView *inspectorEffectView =
	    (DCTaggedVisualEffectView *)[view viewWithTag:INSPECTOR_EFFECT_VIEW_TAG];
	if (inspectorEffectView) {
		inspectorEffectView.frame = CGRectMake([view frame].size.width - titlebarMarginRight, 0,
						       titlebarMarginRight, [view frame].size.height);
	} else {
		inspectorEffectView = [[DCTaggedVisualEffectView alloc]
		    initWithFrame:CGRectMake([view frame].size.width - titlebarMarginRight, 0, titlebarMarginRight,
					     [view frame].size.height)];
		[inspectorEffectView setBlendingMode:NSVisualEffectBlendingModeBehindWindow];
		[inspectorEffectView setMaterial:NSVisualEffectMaterialWindowBackground];
		[inspectorEffectView setTag:INSPECTOR_EFFECT_VIEW_TAG];
		[view addSubview:inspectorEffectView positioned:NSWindowAbove relativeTo:contentEffectView];
		inspectorEffectView.autoresizingMask = NSViewHeightSizable | NSViewMinXMargin;
	}

	DCTaggedView *titlebarBackgroundView = (DCTaggedView *)[view viewWithTag:TITLEBAR_BACKGROUND_VIEW_TAG];
	if (titlebarBackgroundView) {
		titlebarBackgroundView.frame =
		    CGRectMake(sidebarWidth, [view frame].size.height - titlebarHeight,
			       [view frame].size.width - sidebarWidth - titlebarMarginRight, titlebarHeight);
	} else {
		titlebarBackgroundView = [[DCTaggedView alloc]
		    initWithFrame:CGRectMake(sidebarWidth, [view frame].size.height - titlebarHeight,
					     [view frame].size.width - sidebarWidth - titlebarMarginRight,
					     titlebarHeight)];
		[titlebarBackgroundView setTag:TITLEBAR_BACKGROUND_VIEW_TAG];
		[view addSubview:titlebarBackgroundView positioned:NSWindowAbove relativeTo:inspectorEffectView];
		titlebarBackgroundView.autoresizingMask = NSViewWidthSizable | NSViewMinYMargin;

		NSBox *box = [[NSBox alloc] initWithFrame:CGRectMake(0, 0, [titlebarBackgroundView frame].size.width,
								     [titlebarBackgroundView frame].size.height)];
		[box setBackgroundColor:[NSColor textBackgroundColor]];
		[box setBoxType:NSBoxCustom];
		[box setBorderType:NSNoBorder];
		[titlebarBackgroundView addSubview:box];
		box.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
	}

	DCTaggedVisualEffectView *titlebarEffectView =
	    (DCTaggedVisualEffectView *)[view viewWithTag:TITLEBAR_EFFECT_VIEW_TAG];
	if (titlebarEffectView) {
		titlebarEffectView.frame =
		    CGRectMake(sidebarWidth, [view frame].size.height - titlebarHeight,
			       [view frame].size.width - sidebarWidth - titlebarMarginRight, titlebarHeight);
	} else {
		titlebarEffectView = [[DCTaggedVisualEffectView alloc]
		    initWithFrame:CGRectMake(sidebarWidth, [view frame].size.height - titlebarHeight,
					     [view frame].size.width - sidebarWidth - titlebarMarginRight,
					     titlebarHeight)];
		[titlebarEffectView setBlendingMode:NSVisualEffectBlendingModeWithinWindow];
		[titlebarEffectView setMaterial:NSVisualEffectMaterialTitlebar];
		[titlebarEffectView setTag:TITLEBAR_EFFECT_VIEW_TAG];
		[view addSubview:titlebarEffectView positioned:NSWindowAbove relativeTo:titlebarBackgroundView];
		titlebarEffectView.autoresizingMask = NSViewWidthSizable | NSViewMinYMargin;
	}

	return NULL;
}

napi_value setWindowAnimationBehavior(napi_env env, napi_callback_info info) {
	napi_status status;

	size_t argc = 2;
	napi_value args[2];
	status = napi_get_cb_info(env, info, &argc, args, 0, 0);
	if (status != napi_ok) {
		napi_throw_error(env, NULL, "setWindowAnimationBehavior(): failed to get arguments");
		return NULL;
	} else if (argc < 2) {
		napi_throw_error(env, NULL, "setWindowAnimationBehavior(): wrong number of arguments");
		return NULL;
	}

	void *windowBuffer;
	size_t windowBufferLength;
	status = napi_get_buffer_info(env, args[0], &windowBuffer, &windowBufferLength);
	if (status != napi_ok) {
		napi_throw_error(env, NULL, "setWindowAnimationBehavior(): cannot read window handle");
		return NULL;
	} else if (windowBufferLength == 0) {
		napi_throw_error(env, NULL, "setWindowAnimationBehavior(): empty window handle");
		return NULL;
	}

	bool isDocument;
	status = napi_get_value_bool(env, args[1], &isDocument);
	if (status != napi_ok) {
		napi_throw_error(env, NULL, "setWindowAnimationBehavior(): cannot read sidebarWidth from args");
		return NULL;
	}

	NSView *mainWindowView = *static_cast<NSView **>(windowBuffer);
	if (![mainWindowView respondsToSelector:@selector(window)] || mainWindowView.window == nil) {
		napi_throw_error(env, NULL, "setWindowAnimationBehavior(): NSView doesn't contain window");
		return NULL;
	}

	NSWindow *window = mainWindowView.window;
	if (window) {
		window.animationBehavior =
		    isDocument ? NSWindowAnimationBehaviorDocumentWindow : NSWindowAnimationBehaviorDefault;
	}

	return NULL;
}
