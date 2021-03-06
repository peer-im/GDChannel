//
//  Generated by the J2ObjC translator.  DO NOT EDIT!
//  source: /Users/retechretech/dev/workspace/realtime/realtime-channel/src/main/java/com/goodow/realtime/channel/impl/SimpleBus.java
//
//  Created by retechretech.
//

#include "IOSClass.h"
#include "com/goodow/realtime/channel/Bus.h"
#include "com/goodow/realtime/channel/BusHook.h"
#include "com/goodow/realtime/channel/Message.h"
#include "com/goodow/realtime/channel/State.h"
#include "com/goodow/realtime/channel/impl/DefaultMessage.h"
#include "com/goodow/realtime/channel/impl/SimpleBus.h"
#include "com/goodow/realtime/channel/util/IdGenerator.h"
#include "com/goodow/realtime/core/Handler.h"
#include "com/goodow/realtime/core/HandlerRegistration.h"
#include "com/goodow/realtime/core/Platform.h"
#include "com/goodow/realtime/core/Scheduler.h"
#include "com/goodow/realtime/json/Json.h"
#include "com/goodow/realtime/json/JsonArray.h"
#include "com/goodow/realtime/json/JsonObject.h"
#include "java/lang/IllegalArgumentException.h"
#include "java/lang/Throwable.h"
#include "java/lang/Void.h"
#include "java/util/logging/Level.h"
#include "java/util/logging/Logger.h"

BOOL GDCSimpleBus_initialized = NO;

@implementation GDCSimpleBus

NSString * GDCSimpleBus_MODE_MIX_ = @"forkLocal";
JavaUtilLoggingLogger * GDCSimpleBus_log_;

+ (void)checkNotNullWithNSString:(NSString *)paramName
                          withId:(id)param {
  if (param == nil) {
    @throw [[JavaLangIllegalArgumentException alloc] initWithNSString:[NSString stringWithFormat:@"Parameter %@ must be specified", paramName]];
  }
}

- (id)init {
  return [self initGDCSimpleBusWithGDJsonObject:nil];
}

- (id)initGDCSimpleBusWithGDJsonObject:(id<GDJsonObject>)options {
  if (self = [super init]) {
    state_ = GDCStateEnum_get_CONNECTING();
    handlerMap_ = [GDJson createObject];
    replyHandlers_ = [GDJson createObject];
    idGenerator_ = [[ComGoodowRealtimeChannelUtilIdGenerator alloc] init];
    state_ = GDCStateEnum_get_OPEN();
    [self setOptionsWithGDJsonObject:options];
  }
  return self;
}

- (id)initWithGDJsonObject:(id<GDJsonObject>)options {
  return [self initGDCSimpleBusWithGDJsonObject:options];
}

- (void)close {
  if (hook_ == nil || [hook_ handlePreClose]) {
    [self doClose];
  }
}

- (id<GDJsonObject>)getOptions {
  return options_ == nil ? nil : [options_ copy__];
}

- (GDCStateEnum *)getReadyState {
  return state_;
}

- (GDCSimpleBus *)publish:(NSString *)address message:(id)msg {
  [self internalHandleSendOrPubWithBoolean:NO withNSString:address withId:msg withComGoodowRealtimeCoreHandler:nil];
  return self;
}

- (id<ComGoodowRealtimeCoreHandlerRegistration>)registerHandler:(NSString *)address handler:(id)handler {
  [self doRegisterHandlerWithNSString:address withComGoodowRealtimeCoreHandler:handler];
  return [[GDCSimpleBus_$1 alloc] initWithGDCSimpleBus:self withNSString:address withComGoodowRealtimeCoreHandler:handler];
}

- (GDCSimpleBus *)send:(NSString *)address message:(id)msg replyHandler:(id)replyHandler {
  [self internalHandleSendOrPubWithBoolean:YES withNSString:address withId:msg withComGoodowRealtimeCoreHandler:replyHandler];
  return self;
}

- (GDCSimpleBus *)setHookWithGDCBusHook:(id<GDCBusHook>)hook {
  self->hook_ = hook;
  return self;
}

- (void)setOptionsWithGDJsonObject:(id<GDJsonObject>)options {
  self->options_ = options;
  forkLocal_ = options == nil || ![options has:GDCSimpleBus_MODE_MIX_] ? NO : [options getBoolean:GDCSimpleBus_MODE_MIX_];
}

- (void)clearHandlers {
  (void) [((id<GDJsonObject>) nil_chk(replyHandlers_)) clear];
  (void) [((id<GDJsonObject>) nil_chk(handlerMap_)) clear];
}

- (void)doClose {
  state_ = GDCStateEnum_get_CLOSING();
  [self doReceiveMessageWithGDCMessage:[[GDCDefaultMessage alloc] initWithBoolean:NO withGDCBus:nil withNSString:GDCBus_get_LOCAL_ON_CLOSE_() withNSString:nil withId:nil]];
  state_ = GDCStateEnum_get_CLOSED();
  [self clearHandlers];
  if (hook_ != nil) {
    [hook_ handlePostClose];
  }
}

- (void)doReceiveMessageWithGDCMessage:(id<GDCMessage>)message {
  NSString *address = [((id<GDCMessage>) nil_chk(message)) address];
  id<GDJsonArray> handlers = [((id<GDJsonObject>) nil_chk(handlerMap_)) getArray:address];
  if (handlers != nil) {
    [handlers forEach:[[GDCSimpleBus_$2 alloc] initWithGDCSimpleBus:self withNSString:address withGDCMessage:message]];
  }
  else {
    id handler = [((id<GDJsonObject>) nil_chk(replyHandlers_)) getWithNSString:address];
    if (handler != nil) {
      (void) [replyHandlers_ removeWithNSString:address];
      [self scheduleHandleWithNSString:address withId:handler withId:message];
    }
  }
}

- (BOOL)doRegisterHandlerWithNSString:(NSString *)address
     withComGoodowRealtimeCoreHandler:(id<ComGoodowRealtimeCoreHandler>)handler {
  [GDCSimpleBus checkNotNullWithNSString:@"address" withId:address];
  [GDCSimpleBus checkNotNullWithNSString:@"handler" withId:handler];
  id<GDJsonArray> handlers = [((id<GDJsonObject>) nil_chk(handlerMap_)) getArray:address];
  if (handlers == nil) {
    (void) [handlerMap_ set:address value:[((id<GDJsonArray>) nil_chk([GDJson createArray])) push:handler]];
    return YES;
  }
  else if ([handlers indexOf:handler] == -1) {
    (void) [handlers push:handler];
  }
  return NO;
}

- (void)doSendOrPubWithBoolean:(BOOL)send
                  withNSString:(NSString *)address
                        withId:(id)msg
withComGoodowRealtimeCoreHandler:(id<ComGoodowRealtimeCoreHandler>)replyHandler {
  [GDCSimpleBus checkNotNullWithNSString:@"address" withId:address];
  NSString *replyAddress = nil;
  if (replyHandler != nil) {
    replyAddress = [self makeUUID];
  }
  BOOL isLocal = [self isLocalForkWithNSString:address];
  GDCDefaultMessage *message = [[GDCDefaultMessage alloc] initWithBoolean:send withGDCBus:self withNSString:isLocal ? [((NSString *) nil_chk(address)) substring:((int) [((NSString *) nil_chk(GDCBus_get_LOCAL_())) length])] : address withNSString:isLocal && replyHandler != nil ? ([NSString stringWithFormat:@"%@%@", GDCBus_get_LOCAL_(), replyAddress]) : replyAddress withId:msg];
  if ([self internalHandleReceiveMessageWithGDCMessage:message] && replyHandler != nil) {
    (void) [((id<GDJsonObject>) nil_chk(replyHandlers_)) set:replyAddress value:replyHandler];
  }
}

- (BOOL)doUnregisterHandlerWithNSString:(NSString *)address
       withComGoodowRealtimeCoreHandler:(id<ComGoodowRealtimeCoreHandler>)handler {
  NSAssert(address != nil, @"address shouldn't be null");
  NSAssert(handler != nil, @"handler shouldn't be null");
  id<GDJsonArray> handlers = [((id<GDJsonObject>) nil_chk(handlerMap_)) getArray:address];
  if (handlers != nil) {
    int idx = [handlers indexOf:handler];
    if (idx != -1) {
      (void) [handlers removeWithInt:idx];
    }
    if ([handlers count] == 0) {
      (void) [handlerMap_ removeWithNSString:address];
      return YES;
    }
  }
  return NO;
}

- (BOOL)internalHandleReceiveMessageWithGDCMessage:(id<GDCMessage>)message {
  if (hook_ == nil || [hook_ handleReceiveMessageWithGDCMessage:message]) {
    [self doReceiveMessageWithGDCMessage:message];
    return YES;
  }
  return NO;
}

- (BOOL)isLocalForkWithNSString:(NSString *)address {
  NSAssert(address != nil, @"address shouldn't be null");
  return forkLocal_ && [((NSString *) nil_chk(address)) hasPrefix:GDCBus_get_LOCAL_()];
}

- (NSString *)makeUUID {
  return [((ComGoodowRealtimeChannelUtilIdGenerator *) nil_chk(idGenerator_)) nextWithInt:36];
}

- (void)scheduleHandleWithNSString:(NSString *)address
                            withId:(id)handler
                            withId:(id)event {
  [((id<ComGoodowRealtimeCoreScheduler>) nil_chk([ComGoodowRealtimeCorePlatform scheduler])) scheduleDeferredWithComGoodowRealtimeCoreHandler:[[GDCSimpleBus_$3 alloc] initWithGDCSimpleBus:self withId:handler withId:event withNSString:address]];
}

- (void)internalHandleSendOrPubWithBoolean:(BOOL)send
                              withNSString:(NSString *)address
                                    withId:(id)msg
          withComGoodowRealtimeCoreHandler:(id<ComGoodowRealtimeCoreHandler>)replyHandler {
  if (hook_ == nil || [hook_ handleSendOrPubWithBoolean:send withNSString:address withId:msg withComGoodowRealtimeCoreHandler:replyHandler]) {
    [self doSendOrPubWithBoolean:send withNSString:address withId:msg withComGoodowRealtimeCoreHandler:replyHandler];
  }
}

+ (void)initialize {
  if (self == [GDCSimpleBus class]) {
    GDCSimpleBus_log_ = [JavaUtilLoggingLogger getLoggerWithNSString:[[IOSClass classWithClass:[GDCSimpleBus class]] getName]];
    GDCSimpleBus_initialized = YES;
  }
}

- (void)copyAllFieldsTo:(GDCSimpleBus *)other {
  [super copyAllFieldsTo:other];
  other->forkLocal_ = forkLocal_;
  other->handlerMap_ = handlerMap_;
  other->hook_ = hook_;
  other->idGenerator_ = idGenerator_;
  other->options_ = options_;
  other->replyHandlers_ = replyHandlers_;
  other->state_ = state_;
}

+ (J2ObjcClassInfo *)__metadata {
  static J2ObjcMethodInfo methods[] = {
    { "checkNotNullWithNSString:withId:", "checkNotNull", "V", 0xc, NULL },
    { "init", "SimpleBus", NULL, 0x1, NULL },
    { "initWithGDJsonObject:", "SimpleBus", NULL, 0x1, NULL },
    { "close", NULL, "V", 0x1, NULL },
    { "getOptions", NULL, "Lcom.goodow.realtime.json.JsonObject;", 0x1, NULL },
    { "getReadyState", NULL, "Lcom.goodow.realtime.channel.State;", 0x1, NULL },
    { "publish:message:", "publish", "Lcom.goodow.realtime.channel.impl.SimpleBus;", 0x1, NULL },
    { "registerHandler:handler:", "registerHandler", "Lcom.goodow.realtime.core.HandlerRegistration;", 0x1, NULL },
    { "send:message:replyHandler:", "send", "Lcom.goodow.realtime.channel.impl.SimpleBus;", 0x1, NULL },
    { "setHookWithGDCBusHook:", "setHook", "Lcom.goodow.realtime.channel.impl.SimpleBus;", 0x1, NULL },
    { "setOptionsWithGDJsonObject:", "setOptions", "V", 0x1, NULL },
    { "clearHandlers", NULL, "V", 0x4, NULL },
    { "doClose", NULL, "V", 0x4, NULL },
    { "doReceiveMessageWithGDCMessage:", "doReceiveMessage", "V", 0x4, NULL },
    { "doRegisterHandlerWithNSString:withComGoodowRealtimeCoreHandler:", "doRegisterHandler", "Z", 0x4, NULL },
    { "doSendOrPubWithBoolean:withNSString:withId:withComGoodowRealtimeCoreHandler:", "doSendOrPub", "V", 0x4, NULL },
    { "doUnregisterHandlerWithNSString:withComGoodowRealtimeCoreHandler:", "doUnregisterHandler", "Z", 0x4, NULL },
    { "internalHandleReceiveMessageWithGDCMessage:", "internalHandleReceiveMessage", "Z", 0x4, NULL },
    { "isLocalForkWithNSString:", "isLocalFork", "Z", 0x4, NULL },
    { "makeUUID", NULL, "Ljava.lang.String;", 0x4, NULL },
    { "scheduleHandleWithNSString:withId:withId:", "scheduleHandle", "V", 0x4, NULL },
    { "internalHandleSendOrPubWithBoolean:withNSString:withId:withComGoodowRealtimeCoreHandler:", "internalHandleSendOrPub", "V", 0x2, NULL },
  };
  static J2ObjcFieldInfo fields[] = {
    { "MODE_MIX_", NULL, 0x19, "Ljava.lang.String;", &GDCSimpleBus_MODE_MIX_,  },
    { "log_", NULL, 0x1a, "Ljava.util.logging.Logger;", &GDCSimpleBus_log_,  },
    { "handlerMap_", NULL, 0x14, "Lcom.goodow.realtime.json.JsonObject;", NULL,  },
    { "replyHandlers_", NULL, 0x14, "Lcom.goodow.realtime.json.JsonObject;", NULL,  },
    { "idGenerator_", NULL, 0x12, "Lcom.goodow.realtime.channel.util.IdGenerator;", NULL,  },
    { "options_", NULL, 0x2, "Lcom.goodow.realtime.json.JsonObject;", NULL,  },
    { "forkLocal_", NULL, 0x2, "Z", NULL,  },
    { "state_", NULL, 0x4, "Lcom.goodow.realtime.channel.State;", NULL,  },
    { "hook_", NULL, 0x4, "Lcom.goodow.realtime.channel.BusHook;", NULL,  },
  };
  static J2ObjcClassInfo _GDCSimpleBus = { "SimpleBus", "com.goodow.realtime.channel.impl", NULL, 0x1, 22, methods, 9, fields, 0, NULL};
  return &_GDCSimpleBus;
}

@end

@implementation GDCSimpleBus_BusProxy

- (id)initWithGDCSimpleBus:(GDCSimpleBus *)delegate {
  if (self = [super init]) {
    self->delegate_ = delegate;
  }
  return self;
}

- (void)close {
  [((GDCSimpleBus *) nil_chk(delegate_)) close];
}

- (GDCStateEnum *)getReadyState {
  return [((GDCSimpleBus *) nil_chk(delegate_)) getReadyState];
}

- (GDCSimpleBus *)publish:(NSString *)address message:(id)msg {
  return [((GDCSimpleBus *) nil_chk(delegate_)) publish:address message:msg];
}

- (id<ComGoodowRealtimeCoreHandlerRegistration>)registerHandler:(NSString *)address handler:(id)handler {
  return [((GDCSimpleBus *) nil_chk(delegate_)) registerHandler:address handler:handler];
}

- (GDCSimpleBus *)send:(NSString *)address message:(id)msg replyHandler:(id)replyHandler {
  return [((GDCSimpleBus *) nil_chk(delegate_)) send:address message:msg replyHandler:replyHandler];
}

- (id<GDCBus>)setHookWithGDCBusHook:(id<GDCBusHook>)hook {
  self->hook_ = hook;
  return self;
}

- (void)copyAllFieldsTo:(GDCSimpleBus_BusProxy *)other {
  [super copyAllFieldsTo:other];
  other->delegate_ = delegate_;
  other->hook_ = hook_;
}

+ (J2ObjcClassInfo *)__metadata {
  static J2ObjcMethodInfo methods[] = {
    { "initWithGDCSimpleBus:", "BusProxy", NULL, 0x1, NULL },
    { "close", NULL, "V", 0x1, NULL },
    { "getReadyState", NULL, "Lcom.goodow.realtime.channel.State;", 0x1, NULL },
    { "publish:message:", "publish", "Lcom.goodow.realtime.channel.impl.SimpleBus;", 0x1, NULL },
    { "registerHandler:handler:", "registerHandler", "Lcom.goodow.realtime.core.HandlerRegistration;", 0x1, NULL },
    { "send:message:replyHandler:", "send", "Lcom.goodow.realtime.channel.impl.SimpleBus;", 0x1, NULL },
    { "setHookWithGDCBusHook:", "setHook", "Lcom.goodow.realtime.channel.Bus;", 0x1, NULL },
  };
  static J2ObjcFieldInfo fields[] = {
    { "delegate_", NULL, 0x14, "Lcom.goodow.realtime.channel.impl.SimpleBus;", NULL,  },
    { "hook_", NULL, 0x4, "Lcom.goodow.realtime.channel.BusHook;", NULL,  },
  };
  static J2ObjcClassInfo _GDCSimpleBus_BusProxy = { "BusProxy", "com.goodow.realtime.channel.impl", "SimpleBus", 0x409, 7, methods, 2, fields, 0, NULL};
  return &_GDCSimpleBus_BusProxy;
}

@end

@implementation GDCSimpleBus_$1

- (void)unregisterHandler {
  [this$0_ doUnregisterHandlerWithNSString:val$address_ withComGoodowRealtimeCoreHandler:val$handler_];
}

- (id)initWithGDCSimpleBus:(GDCSimpleBus *)outer$
              withNSString:(NSString *)capture$0
withComGoodowRealtimeCoreHandler:(id<ComGoodowRealtimeCoreHandler>)capture$1 {
  this$0_ = outer$;
  val$address_ = capture$0;
  val$handler_ = capture$1;
  return [super init];
}

+ (J2ObjcClassInfo *)__metadata {
  static J2ObjcMethodInfo methods[] = {
    { "unregisterHandler", NULL, "V", 0x1, NULL },
    { "initWithGDCSimpleBus:withNSString:withComGoodowRealtimeCoreHandler:", "init", NULL, 0x0, NULL },
  };
  static J2ObjcFieldInfo fields[] = {
    { "this$0_", NULL, 0x1012, "Lcom.goodow.realtime.channel.impl.SimpleBus;", NULL,  },
    { "val$address_", NULL, 0x1012, "Ljava.lang.String;", NULL,  },
    { "val$handler_", NULL, 0x1012, "Lcom.goodow.realtime.core.Handler;", NULL,  },
  };
  static J2ObjcClassInfo _GDCSimpleBus_$1 = { "$1", "com.goodow.realtime.channel.impl", "SimpleBus", 0x8000, 2, methods, 3, fields, 0, NULL};
  return &_GDCSimpleBus_$1;
}

@end

@implementation GDCSimpleBus_$2

- (void)callWithInt:(int)index
             withId:(id)value {
  [this$0_ scheduleHandleWithNSString:val$address_ withId:value withId:val$message_];
}

- (id)initWithGDCSimpleBus:(GDCSimpleBus *)outer$
              withNSString:(NSString *)capture$0
            withGDCMessage:(id<GDCMessage>)capture$1 {
  this$0_ = outer$;
  val$address_ = capture$0;
  val$message_ = capture$1;
  return [super init];
}

+ (J2ObjcClassInfo *)__metadata {
  static J2ObjcMethodInfo methods[] = {
    { "callWithInt:withId:", "call", "V", 0x1, NULL },
    { "initWithGDCSimpleBus:withNSString:withGDCMessage:", "init", NULL, 0x0, NULL },
  };
  static J2ObjcFieldInfo fields[] = {
    { "this$0_", NULL, 0x1012, "Lcom.goodow.realtime.channel.impl.SimpleBus;", NULL,  },
    { "val$address_", NULL, 0x1012, "Ljava.lang.String;", NULL,  },
    { "val$message_", NULL, 0x1012, "Lcom.goodow.realtime.channel.Message;", NULL,  },
  };
  static J2ObjcClassInfo _GDCSimpleBus_$2 = { "$2", "com.goodow.realtime.channel.impl", "SimpleBus", 0x8000, 2, methods, 3, fields, 0, NULL};
  return &_GDCSimpleBus_$2;
}

@end

@implementation GDCSimpleBus_$3

- (void)handleWithId:(id)ignore {
  @try {
    [((id<ComGoodowRealtimeCoreScheduler>) nil_chk([ComGoodowRealtimeCorePlatform scheduler])) handleWithId:val$handler_ withId:val$event_];
  }
  @catch (JavaLangThrowable *e) {
    [((JavaUtilLoggingLogger *) nil_chk(GDCSimpleBus_get_log_())) logWithJavaUtilLoggingLevel:JavaUtilLoggingLevel_get_WARNING_() withNSString:[NSString stringWithFormat:@"Failed to handle on address: %@", val$address_] withJavaLangThrowable:e];
    [this$0_ doReceiveMessageWithGDCMessage:[[GDCDefaultMessage alloc] initWithBoolean:NO withGDCBus:nil withNSString:GDCBus_get_LOCAL_ON_ERROR_() withNSString:nil withId:[((id<GDJsonObject>) nil_chk([((id<GDJsonObject>) nil_chk([((id<GDJsonObject>) nil_chk([GDJson createObject])) set:@"address" value:val$address_])) set:@"event" value:val$event_])) set:@"cause" value:e]]];
  }
}

- (id)initWithGDCSimpleBus:(GDCSimpleBus *)outer$
                    withId:(id)capture$0
                    withId:(id)capture$1
              withNSString:(NSString *)capture$2 {
  this$0_ = outer$;
  val$handler_ = capture$0;
  val$event_ = capture$1;
  val$address_ = capture$2;
  return [super init];
}

+ (J2ObjcClassInfo *)__metadata {
  static J2ObjcMethodInfo methods[] = {
    { "handleWithJavaLangVoid:", "handle", "V", 0x1, NULL },
    { "initWithGDCSimpleBus:withId:withId:withNSString:", "init", NULL, 0x0, NULL },
  };
  static J2ObjcFieldInfo fields[] = {
    { "this$0_", NULL, 0x1012, "Lcom.goodow.realtime.channel.impl.SimpleBus;", NULL,  },
    { "val$handler_", NULL, 0x1012, "Ljava.lang.Object;", NULL,  },
    { "val$event_", NULL, 0x1012, "Ljava.lang.Object;", NULL,  },
    { "val$address_", NULL, 0x1012, "Ljava.lang.String;", NULL,  },
  };
  static J2ObjcClassInfo _GDCSimpleBus_$3 = { "$3", "com.goodow.realtime.channel.impl", "SimpleBus", 0x8000, 2, methods, 4, fields, 0, NULL};
  return &_GDCSimpleBus_$3;
}

@end
