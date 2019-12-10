//
//  BaseFileOperation.swift
//  ActionsExecutor
//
//  Created by Vitalii Budnik on 12/15/19.
//  Copyright © 2019 Vitalii Budnik. All rights reserved.
//

import Foundation

class BaseFileOperation: Operation, ProgressReporting {
  let fileURL: URL
  let progress: Progress
  let mainProgress: Progress
  let fileSize: Int64

  var result: Result<String, OperationError>? = .none {
    didSet {
      switch result {
      case let .failure(error):
        progress.setUserInfoObject(error.localizedDescription, forKey: .result)
        progress.completedUnitCount += 1
        if !progress.isCancelled {
          progress.cancel()
        }
      case let .success(value):
        progress.setUserInfoObject(value, forKey: .result)
      case .none:
        break
      }
    }
  }

  init(taskID: String, fileURL: URL, mainProgress: Progress) {
    let fileSize = (try? FileManager.default.attributesOfItem(atPath: fileURL.path))?[.size] as? Int64 ?? 0
    let progress = Progress(totalUnitCount: fileSize + 1)
    progress.fileURL = fileURL
    progress.kind = .file

    self.mainProgress = mainProgress
    self.fileSize = fileSize
    self.fileURL = fileURL
    self.progress = progress

    progress.publish()
  }

  deinit {
    progress.unpublish()
  }

  override func cancel() {
    super.cancel()
    progress.cancel()
    result = .failure(.common(.canceled(fileURL: fileURL)))
  }
}
