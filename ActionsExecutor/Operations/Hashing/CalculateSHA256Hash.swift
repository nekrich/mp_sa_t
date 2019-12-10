//
//  CalculateSHA256Hash.swift
//  ActionsExecutor
//
//  Created by Vitalii Budnik on 12/15/19.
//  Copyright © 2019 Vitalii Budnik. All rights reserved.
//

import Foundation
import CommonCrypto

final class CalculateSHA256Hash: BaseFileOperation {
  override init(
    taskID: String,
    fileURL: URL,
    mainProgress: Progress
  )
  {
    super.init(taskID: taskID, fileURL: fileURL, mainProgress: mainProgress)
    progress.fileOperationKind = .init("Calculating SHA256 hash")
  }

  override func main() {

    let fileHandle: FileHandle
    do {
      fileHandle = try FileHandle(forReadingFrom: fileURL)
    } catch {
      result = .failure(.hash(.cantOpenFileHandle(fileURL: fileURL, error: error)))
      return
    }

    defer { fileHandle.closeFile() }

    let bufferSize: Int = 1024 * 1024

    var context = CC_SHA256_CTX()
    CC_SHA256_Init(&context)

    while autoreleasepool(invoking: { () -> Bool in
      let data = fileHandle.readData(ofLength: bufferSize)
      guard !data.isEmpty else { // !EOF
        return false
      }

      data.withUnsafeBytes { (bytes) in
        _ = CC_SHA256_Update(&context, bytes.baseAddress, numericCast(bytes.count))
      }

      let completedUnitCount = Int64(data.count)

      progress.completedUnitCount += completedUnitCount
      mainProgress.completedUnitCount += completedUnitCount

      return !isCancelled
    }) {}

    guard !isCancelled else {
      result = .failure(.common(.canceled(fileURL: fileURL)))
      return
    }

    var bytes: [UInt8] = Array(repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
    _ = CC_SHA256_Final(&bytes, &context)

    let hashString = bytes.reduce(into: "") { (accum, byte) in
      var byteHexString = String(byte, radix: 16)
      if byte < 16 {
        byteHexString = "0" + byteHexString
      }
      accum += byteHexString
    }

    result = .success("SHA256: " + hashString)

    progress.completedUnitCount += 1
  }
}
