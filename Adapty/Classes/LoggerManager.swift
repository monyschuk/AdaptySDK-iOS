//
//  LoggerManager.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 01/04/2020.
//

import Foundation

@objc public enum AdaptyLogLevel: Int {
    case none
    case errors
    case verbose
    case all
}

class LoggerManager {
    static var logLevel: AdaptyLogLevel = .none

    static func logError(_ error: Any) {
        guard isAllowedToLog(.errors) else {
            return
        }

        print("\n\(prefix) - ERROR.\n\(error)")
    }

    static func logMessage(_ message: String) {
        guard isAllowedToLog(.verbose) else {
            return
        }

        print("\n\(prefix) - INFO.\n\(message)")
    }

    static func logGlobalMessage(_ message: String) {
        guard isAllowedToLog(.all) else {
            return
        }

        print("\n\(prefix) - INFO.\n\(message)")
    }

    private static func isAllowedToLog(_ level: AdaptyLogLevel) -> Bool {
        return logLevel.rawValue >= level.rawValue
    }

    private static var prefix: String {
        return "\(dateTime) [Adapty v\(Adapty.SDKVersion)(\(Adapty.SDKBuild))]"
    }

    private static var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSZ"
        return formatter
    }()

    private static var dateTime: String {
        return formatter.string(from: Date())
    }
}
