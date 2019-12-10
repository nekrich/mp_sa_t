//
//  Action.swift
//  SharedModels
//
//  Created by Vitalii Budnik on 12/10/19.
//  Copyright © 2019 Vitalii Budnik. All rights reserved.
//

import Foundation

public enum Action: Codable, Equatable, Hashable {
  case remove
  case calculateHash(algorithm: HashingAlgorithm)

  private enum CodingKey: String, Swift.CodingKey {
    case action
    case parameters
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKey.self)
    let actionString = try container.decode(String.self, forKey: .action)
    switch actionString {
    case "remove":
      self = .remove
    case "calculateHash":
      let algorithm = try container.decode(HashingAlgorithm.self, forKey: .parameters)
      self = .calculateHash(algorithm: algorithm)
    default:
      throw DecodingError.dataCorruptedError(
        forKey: .action,
        in: container,
        debugDescription: "Unsupported action \(actionString)"
      )
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKey.self)
    switch self {
    case .remove:
      try container.encode("remove", forKey: .action)
    case let .calculateHash(algorithm: algorithm):
      try container.encode("calculateHash", forKey: .action)
      try container.encode(algorithm, forKey: .parameters)
    }
  }
}
