//
//  main.swift
//  ActionsExecutor
//
//  Created by Vitalii Budnik on 12/10/19.
//  Copyright © 2019 Vitalii Budnik. All rights reserved.
//

import Foundation

import Foundation

let delegate = ActionsExecutorDelegate()
let listener = NSXPCListener.service()
listener.delegate = delegate
listener.resume()
