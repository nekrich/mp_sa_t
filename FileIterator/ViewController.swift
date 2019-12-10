//
//  ViewController.swift
//  FileIterator
//
//  Created by Vitalii Budnik on 12/10/19.
//  Copyright © 2019 Vitalii Budnik. All rights reserved.
//

import Cocoa
import SharedModels

class ViewController: NSViewController {
  @IBOutlet private weak var tableView: NSTableView!
  @IBOutlet private weak var hashSHA1Progress: NSProgressIndicator!
  @IBOutlet private weak var hashSHA256Progress: NSProgressIndicator!
  @IBOutlet private weak var removalProgress: NSProgressIndicator!

  private lazy var connection: NSXPCConnection = {
    let connection = NSXPCConnection(serviceName: Bundle.main.bundleIdentifier!.appending(".ActionsExecutor"))
    connection.remoteObjectInterface = NSXPCInterface(with: ActionsExecutorInputProtocol.self)
    connection.exportedInterface = NSXPCInterface(with: ActionsExecutorOutputProtocol.self)
    connection.exportedObject = self
    connection.resume()
    return connection
  }()

  private lazy var xpcService: ActionsExecutorInputProtocol? = {
    return connection.remoteObjectProxyWithErrorHandler { error in
      print("Received error:", error)
      } as? ActionsExecutorInputProtocol
  }()

  private var files: [FileObject] = [] {
    didSet {
      tableView.reloadData()
    }
  }
}

// MARK: - Action

extension ViewController {

  @IBAction private func didPressSHA1HashButton(_ button: NSButton) {
    perform(action: .calculateHash(algorithm: .sha1))
  }

  @IBAction private func didPressSHA256HashButton(_ button: NSButton) {
    perform(action: .calculateHash(algorithm: .sha256))
  }

  @IBAction private func didPressRemoveFileButton(_ button: NSButton) {
    perform(action: .remove)
  }

  @discardableResult
  private func perform(action: Action) -> UUID {
    let actionID = UUID()

    do {
      xpcService?.perform(
        action: try JSONEncoder().encode(action),
        taskID: actionID.uuidString,
        on: tableView.selectedRowIndexes.map { files[$0].url.path }
      )
    } catch {
      assertionFailure("\(error)")
    }

    setProgress(progress: 0, for: action, taskID: actionID.uuidString)

    return actionID
  }
}

// MARK: - Documents open

extension ViewController {

  @IBAction func openDocument(_ sender: Any?) {
    guard let window = view.window else {
      assertionFailure("View is not assigned to any window")
      return
    }

    let panel = NSOpenPanel()
    panel.canChooseFiles = true
    panel.canChooseDirectories = true
    panel.allowsMultipleSelection = true

    panel.beginSheetModal(for: window) { [weak self, unowned panel](result) in
      guard result == NSApplication.ModalResponse.OK else {
        print("No files was selected")
        return
      }

      self?.didSelect(urls: panel.urls, includeHiddenFiles: panel.showsHiddenFiles)
    }
  }

  private func didSelect(urls: [URL], includeHiddenFiles: Bool) {
    files = FilesEnumerator()
      .getFiles(at: urls, includeHiddenFiles: includeHiddenFiles)
      .map(FileObject.init)
  }
}

extension ViewController: ActionsExecutorOutputProtocol {
  func actionProgressDidFinish(taskID: String, action: Data) {
    guard let action = try? JSONDecoder().decode(Action.self, from: action) else {
      return
    }
    setProgress(progress: 1.0, for: action, taskID: taskID)
  }

  private func setProgress(progress: Double, for action: Action, taskID: String) {
    let progressIndicator: NSProgressIndicator
    switch action {
    case .remove:
      progressIndicator = removalProgress
    case let .calculateHash(algorithm: algorithm):
      switch algorithm {
      case .sha1:
        progressIndicator = hashSHA1Progress
      case .sha256:
        progressIndicator = hashSHA256Progress
      }
    }

    DispatchQueue.main.async { [progressIndicator] in
      progressIndicator.doubleValue = progress
    }
  }

  func actionProgressDidChange(taskID: String, action: Data, progress: Double) {
    guard let action = try? JSONDecoder().decode(Action.self, from: action) else {
      return
    }

    setProgress(progress: progress, for: action, taskID: taskID)
  }
}

extension ViewController: NSTableViewDataSource {
  func numberOfRows(in tableView: NSTableView) -> Int {
    return files.count
  }

  func tableView(
    _ tableView: NSTableView,
    objectValueFor tableColumn: NSTableColumn?,
    row: Int
  )
    -> Any?
  {
    return files[row]
  }
}

extension ViewController: NSTableViewDelegate {
  func tableView(
    _ tableView: NSTableView,
    viewFor tableColumn: NSTableColumn?,
    row: Int
  )
    -> NSView?
  {
    return tableView.makeView(withIdentifier: .init("FileCell"), owner: self)
  }

  func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
    return 66.0
  }
}

class FileCell: NSTableCellView {
  @IBOutlet private weak var fileNameLabel: NSTextField!
  @IBOutlet private weak var progress: NSProgressIndicator!
  @IBOutlet private weak var resultLabel: NSTextField!

  deinit {
    subscriber = .none
  }

  override var objectValue: Any? {
    didSet {
      render()
    }
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    clear()
    objectValue = .none
  }

  var subscriber: Any? {
    willSet {
      subscriber.map(Progress.removeSubscriber)
    }
  }

  private func clear() {
    fileNameLabel.stringValue = ""
    resultLabel.stringValue = ""
    progress.doubleValue = 0.0
    progress.minValue = 0.0
    progress.maxValue = 1.0
    subscriber = .none
  }

  private func render() {
    guard let fileObject = objectValue as? FileObject else {
      return
    }
    fileNameLabel.stringValue = fileObject.url.path
    resultLabel.stringValue = fileObject.lastKnownResult
    progress.doubleValue = fileObject.lastKnownProgress

    subscriber = Progress.addSubscriber(forFileURL: fileObject.url) { [weak self] (progress) -> Progress.UnpublishingHandler? in
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
    resultLabel.stringValue = object.userInfo[.result] as? String ?? ""
    progress.doubleValue = object.fractionCompleted
  }
}
