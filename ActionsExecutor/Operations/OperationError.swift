//
//  OperationError.swift
//  ActionsExecutor
//
//  Created by Vitalii Budnik on 12/15/19.
//  Copyright © 2019 Vitalii Budnik. All rights reserved.
//

import Foundation

enum OperationError: Error, LocalizedError {
  enum Common: Error, CustomNSError {
    case canceled(fileURL: URL)
    case fileDoesntExist(fileURL: URL)

    var fileURL: URL {
      switch self {
      case let .canceled(fileURL: fileURL),
           let .fileDoesntExist(fileURL: fileURL):
        return fileURL
      }
    }
  }

  enum Hash: Error, CustomNSError {
    case cantOpenFileHandle(fileURL: URL, error: Error)
    case getFileAttributes(fileURL: URL, error: Error)
    case unknownFileSize(fileURL: URL)

    var fileURL: URL {
      switch self {
      case let .cantOpenFileHandle(fileURL: fileURL, error: _),
           let .getFileAttributes(fileURL: fileURL, error: _),
           let .unknownFileSize(fileURL: fileURL):
        return fileURL
      }
    }

    var underlyingError: Error? {
      switch self {
      case let .cantOpenFileHandle(fileURL: _, error: error),
           let .getFileAttributes(fileURL: _, error: error):
        return error
      case .unknownFileSize:
        return .none
      }
    }
  }

  enum Remove: Error, CustomNSError {
    case remove(fileURL: URL, error: Error)

    var fileURL: URL {
      switch self {
      case let .remove(fileURL: fileURL, error: _):
        return fileURL
      }
    }

    var underlyingError: Error {
      switch self {
      case let .remove(fileURL: _, error: error):
        return error
      }
    }
  }

  case common(Common)
  case hash(Hash)
  case remove(Remove)

  var fileURL: URL {
    switch self {
    case let .common(common):
      return common.fileURL
    case let .hash(hash):
      return hash.fileURL
    case let .remove(remove):
      return remove.fileURL
    }
  }

  var underlyingError: Error? {
    switch self {
    case .common:
      return .none
    case let .hash(hash):
      return hash.underlyingError
    case let .remove(remove):
      return remove.underlyingError
    }
  }

  var errorDescription: String? {
    return underlyingError?.localizedDescription ?? "\(self)"
  }
}
