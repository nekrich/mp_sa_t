//
//  ActionsExecutorService.swift
//  ActionsExecutor
//
//  Created by Vitalii Budnik on 12/10/19.
//  Copyright © 2019 Vitalii Budnik. All rights reserved.
//

import Foundation
import SharedModels

final class ActionsExecutorService: NSObject, ActionsExecutorInputProtocol {

  var output: ActionsExecutorOutputProtocol?

  func perform(
    action actionData: Data,
    taskID: String,
    on files: [String]
  )
  {
    let files = files.map(URL.init(fileURLWithPath:))
    let action: Action
    do {
      action = try JSONDecoder().decode(Action.self, from: actionData)
    } catch {
      print(error)
      return
    }

    let q: OperationQueue = OperationQueue()
    q.qualityOfService = .utility

    let fileToOperation: (URL) -> Operation

    switch action {
    case .remove:
      q.progress.fileOperationKind = .init("Removing")
      fileToOperation = { RemoveFile(taskID: taskID, fileURL: $0, mainProgress: q.progress) }
    case let .calculateHash(algorithm: algorithm):
      q.progress.fileOperationKind = .init("Hashing")
      switch algorithm {
      case .sha1:
        fileToOperation = { CalculateSHA1Hash(taskID: taskID, fileURL: $0, mainProgress: q.progress) }
      case .sha256:
        fileToOperation = { CalculateSHA256Hash(taskID: taskID, fileURL: $0, mainProgress: q.progress) }
      }
    }

    let filesSize: Int64 = files.reduce(into: 0) {
      $0 += (try? FileManager.default.attributesOfItem(atPath: $1.path))?[.size] as? Int64 ?? 0
    }

    q.progress.totalUnitCount = filesSize
    q.progress.setUserInfoObject(taskID, forKey: .taskID)
    q.progress.setUserInfoObject(actionData, forKey: .action)
    q.progress.addObserver(self, forKeyPath: "fractionCompleted", options: .new, context: .none)

    let operations = files.map(fileToOperation)

    let lastOperation = BlockOperation { [weak self, weak output] in
      if let self = self {
        q.progress.removeObserver(self, forKeyPath: "fractionCompleted")
      }
      output?.actionProgressDidFinish(taskID: taskID, action: actionData)
    }
    operations.forEach {
      lastOperation.addDependency($0)
      q.addOperation($0)
    }
    q.addOperation(lastOperation)
  }

  override func observeValue(
    forKeyPath keyPath: String?,
    of object: Any?,
    change: [NSKeyValueChangeKey : Any]?,
    context: UnsafeMutableRawPointer?
  )
  {
    guard let progress = object as? Progress,
      let taskID = progress.userInfo[.taskID] as? String,
      let actionData = progress.userInfo[.action] as? Data else {
        return
    }
    output?.actionProgressDidChange(
      taskID: taskID,
      action: actionData,
      progress: progress.fractionCompleted
    )
  }
}
