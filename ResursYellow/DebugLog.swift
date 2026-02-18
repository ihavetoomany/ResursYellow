//
//  DebugLog.swift — instrumentation for memory/optimization audit. Remove after verification.
//

import Foundation

// #region agent log
private let _debugLogPath = "/Users/R01501/Desktop/ResursApps/ResursYellow/.cursor/debug.log"
func _debugLog(_ message: String, location: String = #file + ":" + String(#line), data: [String: Any] = [:], hypothesisId: String = "") {
    var payload: [String: Any] = ["message": message, "location": (location as NSString).lastPathComponent, "timestamp": Int(Date().timeIntervalSince1970 * 1000)]
    if !data.isEmpty { payload["data"] = data }
    if !hypothesisId.isEmpty { payload["hypothesisId"] = hypothesisId }
    guard let json = try? JSONSerialization.data(withJSONObject: payload),
          let line = String(data: json + Data("\n".utf8), encoding: .utf8) else { return }
    guard let lineData = line.data(using: .utf8) else { return }
    if FileManager.default.fileExists(atPath: _debugLogPath),
       let handle = try? FileHandle(forUpdating: URL(fileURLWithPath: _debugLogPath)) {
        handle.seekToEndOfFile()
        handle.write(lineData)
        try? handle.close()
    } else {
        FileManager.default.createFile(atPath: _debugLogPath, contents: lineData)
    }
}
// #endregion
