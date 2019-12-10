//
//  ActionsExecutorInputProtocol.swift
//  SharedModels
//
//  Created by Vitalii Budnik on 12/10/19.
//  Copyright © 2019 Vitalii Budnik. All rights reserved.
//

import Foundation

@objc public protocol ActionsExecutorInputProtocol {
  func perform(action actionData: Data, taskID: String, on files: [String])
}
