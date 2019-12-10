//
//  FileObject.swift
//  FileIterator
//
//  Created by Vitalii Budnik on 12/15/19.
//  Copyright © 2019 Vitalii Budnik. All rights reserved.
//

import Foundation

final class FileObject: NSObject {
  let url: URL

  private(set) var lastKnownResult: String = ""
  private(set) var lastKnownProgress: Double = 0.0
  private(set) var subscriber: Any? = .none {
    willSet {
      subscriber.map(Progress.removeSubscriber(_:))
    }
  }

  init(url: URL) {
    self.url = url
    super.init()

    subscriber = Progress.addSubscriber(forFileURL: url) { [weak self] (progress) -> Progress.UnpublishingHandler? in
      guard let self = self else {
        return .none
      }
      progress.addObserver(self, forKeyPath: "fractionCompleted", options: .new, context: .none)
      return { [weak self, weak progress] in
        guard let self = self else {
          return
        }
        progress?.removeObserver(self, forKeyPath: "fractionCompleted")
      }
    }
  }

  deinit {
    subscriber = .none
  }

  override func observeValue(
    forKeyPath keyPath: String?,
    of object: Any?,
    change: [NSKeyValueChangeKey : Any]?,
    context: UnsafeMutableRawPointer?
  )
  {
    guard let object = object as? Progress,
      keyPath == "fractionCompleted"
      else {
        return
    }
    lastKnownResult = object.userInfo[.result] as? String ?? lastKnownResult
    lastKnownProgress = object.fractionCompleted
  }
}
