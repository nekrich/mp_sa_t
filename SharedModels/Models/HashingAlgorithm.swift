//
//  HashingAlgorithm.swift
//  SharedModels
//
//  Created by Vitalii Budnik on 12/10/19.
//  Copyright © 2019 Vitalii Budnik. All rights reserved.
//

import Foundation

public enum HashingAlgorithm: String, Codable, Equatable, Hashable {
  case sha1 = "SHA1"
  case sha256 = "SHA256"
}
