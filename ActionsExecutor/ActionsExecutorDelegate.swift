//
//  ActionsExecutorDelegate.swift
//  ActionsExecutor
//
//  Created by Vitalii Budnik on 12/10/19.
//  Copyright © 2019 Vitalii Budnik. All rights reserved.
//

import Foundation
import SharedModels

class ActionsExecutorDelegate: NSObject, NSXPCListenerDelegate {
  func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
    let exportedObject = ActionsExecutorService()
    newConnection.exportedInterface = NSXPCInterface(with: ActionsExecutorInputProtocol.self)
    newConnection.remoteObjectInterface = NSXPCInterface(with: ActionsExecutorOutputProtocol.self)
    newConnection.exportedObject = exportedObject
    newConnection.resume()

    let output = newConnection.remoteObjectProxyWithErrorHandler { (error) in
      print("Received error:", error)
    }
    exportedObject.output = output as? ActionsExecutorOutputProtocol

    return true
  }
}
