//
//  ActionsExecutor.h
//  ActionsExecutor
//
//  Created by Vitalii Budnik on 12/10/19.
//  Copyright © 2019 Vitalii Budnik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ActionsExecutorProtocol.h"

// This object implements the protocol which we have defined. It provides the actual behavior for the service. It is 'exported' by the service to make it available to the process hosting the service over an NSXPCConnection.
@interface ActionsExecutor : NSObject <ActionsExecutorProtocol>
@end
