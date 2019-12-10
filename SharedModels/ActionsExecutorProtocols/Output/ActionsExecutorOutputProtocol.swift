//
//  ActionsExecutorOutputProtocol.swift
//  SharedModels
//
//  Created by Vitalii Budnik on 12/10/19.
//  Copyright © 2019 Vitalii Budnik. All rights reserved.
//

import Foundation

@objc public protocol ActionsExecutorOutputProtocol {
  func actionProgressDidFinish(taskID: String, action: Data)
  func actionProgressDidChange(taskID: String, action: Data, progress: Double)
}
