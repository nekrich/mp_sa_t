//
//  ActionTests.swift
//  SharedModelsTests
//
//  Created by Vitalii Budnik on 12/10/19.
//  Copyright © 2019 Vitalii Budnik. All rights reserved.
//

import Foundation
import XCTest
@testable import SharedModels

class ActionTests: XCTestCase {

  func testActionDecoding() {
    func stringToAction(_ jsonString: String, file: StaticString = #file, line: UInt = #line) -> Action? {
      do {
        return try JSONDecoder().decode(Action.self, from: Data(jsonString.utf8))
      } catch {
        XCTFail("Failed to decode action from \(jsonString): \(error)", file: file, line: line)
        return .none
      }
    }

    XCTAssertEqual(
      stringToAction(#"{"action":"remove"}"#),
      .remove
    )
    XCTAssertEqual(
      stringToAction(#"{"action":"calculateHash","parameters":"SHA256"}"#),
      .calculateHash(algorithm: .sha256)
    )
    XCTAssertEqual(
      stringToAction(#"{"action":"calculateHash","parameters":"SHA1"}"#),
      .calculateHash(algorithm: .sha1)
    )
  }

  func testActionEncoding() {
    func actionToString(_ action: Action, file: StaticString = #file, line: UInt = #line) -> String? {
      do {
        return try String(decoding: JSONEncoder().encode(action), as: UTF8.self)
      } catch {
        XCTFail("Failed to encode action \(action) to string: \(error)", file: file, line: line)
        return .none
      }
    }

    XCTAssertEqual(
      actionToString(.remove),
      #"{"action":"remove"}"#
    )
    XCTAssertEqual(
      actionToString(.calculateHash(algorithm: .sha256)),
      #"{"action":"calculateHash","parameters":"SHA256"}"#
    )
    XCTAssertEqual(
      actionToString(.calculateHash(algorithm: .sha1)),
      #"{"action":"calculateHash","parameters":"SHA1"}"#
    )
  }
}
