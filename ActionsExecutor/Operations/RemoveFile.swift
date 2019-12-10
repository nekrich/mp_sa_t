//
//  RemoveFile.swift
//  ActionsExecutor
//
//  Created by Vitalii Budnik on 12/15/19.
//  Copyright © 2019 Vitalii Budnik. All rights reserved.
//

import Foundation

final class RemoveFile: BaseFileOperation {
  override func main() {
    do {
      // try FileManager.default.removeItem(at: fileURL)
      result = .success("Removed (actually not)")
    } catch {
      result = .failure(.remove(.remove(fileURL: fileURL, error: error)))
    }
    progress.completedUnitCount += fileSize + 1
    mainProgress.completedUnitCount += fileSize
  }
}
