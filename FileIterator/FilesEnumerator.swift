//
//  FilesEnumerator.swift
//  FileIterator
//
//  Created by Vitalii Budnik on 12/10/19.
//  Copyright © 2019 Vitalii Budnik. All rights reserved.
//

import Foundation
import Cocoa

protocol FilesEnumeratorProtocol {
  func getFiles(at urls: [URL], includeHiddenFiles: Bool) -> [URL]
}

final class FilesEnumerator: FilesEnumeratorProtocol {

  func getFiles(at urls: [URL], includeHiddenFiles: Bool) -> [URL] {
    guard !urls.isEmpty else {
      return []
    }

    let openedURLs = urls.reduce(into: [URL]()) { (accum, url) in
      let values = try? url.resourceValues(forKeys: [.isDirectoryKey])
      if values?.isDirectory == true {
        accum.append(contentsOf: directoryContents(at: url, includeHiddenFiles: includeHiddenFiles))
      } else {
        accum.append(url)
      }
    }

    return openedURLs
  }

  private func directoryContents(at url: URL, includeHiddenFiles: Bool) -> [URL] {
    let propertiesToFetch: Set<URLResourceKey> = [.isDirectoryKey, .nameKey]
    let enumartionOptionsMask: FileManager.DirectoryEnumerationOptions = includeHiddenFiles ? [] : .skipsHiddenFiles

    let directoryEnumerator = FileManager.default.enumerator(
      at: url,
      includingPropertiesForKeys: propertiesToFetch.map { $0 },
      options: enumartionOptionsMask) { (url, error) -> Bool in
        print("An error ocurred while enumerating file at", url, ":", error)
        return true
    }

    let files = directoryEnumerator?.reduce(into: [URL]()) { (accum, url) in
      guard let url = url as? URL,
        let resourceValues = try? url.resourceValues(forKeys: propertiesToFetch),
        let isDirectory = resourceValues.isDirectory,
        let name = resourceValues.name else {
          return
      }
      if isDirectory {
        if name == "_extras" {
          directoryEnumerator?.skipDescendants()
        }
      } else {
        accum.append(url)
      }
    }

    return files ?? []
  }
  
}
