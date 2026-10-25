import Cocoa
import FlutterMacOS
import ApplicationServices
import ServiceManagement

/// The app lives in the menu bar, so the single window doubles as the regular
/// app panel and as the tiny floating capture overlay. The panel subclass is
/// required to show the overlay without activating the app.
class MainFlutterWindow: NSPanel {
  private var selectionChannel: FlutterMethodChannel?
  private var startupChannel: FlutterMethodChannel?
  private var overlayChannel: FlutterMethodChannel?
  private var hidWindowAtLaunch = false

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    // Transparent background so the capture overlay can float without a frame.
    self.isOpaque = false
    self.backgroundColor = .clear
    self.hidesOnDeactivate = false
    // The app starts in the menu bar; `showPanel` raises the opacity again.
    self.alphaValue = 0

    let messenger = flutterViewController.engine.binaryMessenger

    selectionChannel = FlutterMethodChannel(
      name: "wordlearn/selection",
      binaryMessenger: messenger
    )
    selectionChannel?.setMethodCallHandler { [weak self] call, result in
      self?.handleSelection(call, result: result)
    }

    overlayChannel = FlutterMethodChannel(
      name: "wordlearn/overlay",
      binaryMessenger: messenger
    )
    overlayChannel?.setMethodCallHandler { [weak self] call, result in
      self?.handleOverlay(call, result: result)
    }

    // Backs the `launch_at_startup` Dart package on macOS.
    startupChannel = FlutterMethodChannel(
      name: "launch_at_startup",
      binaryMessenger: messenger
    )
    startupChannel?.setMethodCallHandler { [weak self] call, result in
      self?.handleLaunchAtStartup(call, result: result)
    }

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }

  /// The app starts in the menu bar only, so the window is hidden on its first
  /// ordering pass and shown later by `window_manager`.
  override func order(_ place: NSWindow.OrderingMode, relativeTo otherWin: Int) {
    super.order(place, relativeTo: otherWin)
    guard !hidWindowAtLaunch else { return }
    hidWindowAtLaunch = true
    setIsVisible(false)
  }

  private func handleSelection(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "readSelectedText":
      guard AXIsProcessTrusted() else {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        _ = AXIsProcessTrustedWithOptions(options as CFDictionary)
        result(
          FlutterError(
            code: "accessibility",
            message: "Erişilebilirlik izni gerekli.",
            details: nil
          )
        )
        return
      }
      result(readSelectedText())
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func handleOverlay(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "enter":
      styleMask.insert(.nonactivatingPanel)
      level = .floating
      collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
      hasShadow = false
      ignoresMouseEvents = true
      hidesOnDeactivate = false
      result(nil)
    case "show":
      // `orderFrontRegardless` shows the panel without activating the app, so
      // the user keeps typing in the app they captured from. The short alpha
      // fade hides the frame that still holds the previous root widget.
      alphaValue = 0
      orderFrontRegardless()
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) { [weak self] in
        self?.alphaValue = 1
      }
      result(nil)
    case "hide":
      alphaValue = 1
      orderOut(nil)
      result(nil)
    case "exit":
      ignoresMouseEvents = false
      styleMask.remove(.nonactivatingPanel)
      level = .normal
      collectionBehavior = []
      hasShadow = true
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  /// Reads the selection of the frontmost app, first through the Accessibility
  /// API and then with a copy shortcut for apps that expose no AX selection.
  private func readSelectedText() -> String? {
    if let selected = readSelectionThroughAccessibility() {
      return selected
    }
    return copyFocusedSelection()
  }

  private func readSelectionThroughAccessibility() -> String? {
    let systemWide = AXUIElementCreateSystemWide()
    var focusedRef: CFTypeRef?
    guard
      AXUIElementCopyAttributeValue(
        systemWide,
        kAXFocusedUIElementAttribute as CFString,
        &focusedRef
      ) == .success,
      let focusedRef
    else {
      return nil
    }
    let focusedElement = focusedRef as! AXUIElement

    var selectedRef: CFTypeRef?
    guard
      AXUIElementCopyAttributeValue(
        focusedElement,
        kAXSelectedTextAttribute as CFString,
        &selectedRef
      ) == .success,
      let selected = selectedRef as? String
    else {
      return nil
    }

    let trimmed = selected.trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmed.isEmpty ? nil : trimmed
  }

  /// Sends Cmd+C to the frontmost app and restores the previous pasteboard text.
  private func copyFocusedSelection() -> String? {
    let pasteboard = NSPasteboard.general
    let previousText = pasteboard.string(forType: .string)
    let previousChangeCount = pasteboard.changeCount

    let source = CGEventSource(stateID: .combinedSessionState)
    let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 0x08, keyDown: true)
    let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 0x08, keyDown: false)
    keyDown?.flags = .maskCommand
    keyUp?.flags = .maskCommand
    keyDown?.post(tap: .cghidEventTap)
    keyUp?.post(tap: .cghidEventTap)

    let deadline = Date().addingTimeInterval(0.25)
    while pasteboard.changeCount == previousChangeCount && Date() < deadline {
      usleep(15_000)
    }

    guard pasteboard.changeCount != previousChangeCount else { return nil }
    let copied = pasteboard.string(forType: .string)

    if let previousText {
      pasteboard.clearContents()
      pasteboard.setString(previousText, forType: .string)
    }

    guard let copied else { return nil }
    let trimmed = copied.trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmed.isEmpty ? nil : trimmed
  }

  private func handleLaunchAtStartup(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard #available(macOS 13.0, *) else {
      result(call.method == "launchAtStartupIsEnabled" ? false : nil)
      return
    }

    let service = SMAppService.mainApp
    switch call.method {
    case "launchAtStartupIsEnabled":
      result(service.status == .enabled)
    case "launchAtStartupSetEnabled":
      let enabled = (call.arguments as? [String: Any])?["setEnabledValue"] as? Bool ?? false
      do {
        if enabled {
          if service.status != .enabled {
            try service.register()
          }
        } else if service.status == .enabled {
          try service.unregister()
        }
        result(nil)
      } catch {
        result(
          FlutterError(
            code: "launch_at_startup",
            message: error.localizedDescription,
            details: nil
          )
        )
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
