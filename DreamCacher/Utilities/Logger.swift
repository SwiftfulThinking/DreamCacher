//
//  DreamCacherLogger.swift
//  DreamCacher
//
//  Created by Nick Sarno on 8/13/21.
//

import Foundation

// MARK: LOGGER
/// Logger should be used for all logging (printing) throughout the application.
///
/// - This is a utility class that is globally generic.
/// - All functions/variables should be static and there should be no 'instance' created.
/// - ALL print statements should route through the logger.
/// - For security reasons, printing will be turned off in production builds.
final class Logger { }

// MARK: PUBLIC

extension Logger {
    
    
    /// Determines if Logger is allowed to print to console.
    ///
    /// isPrintEnabled should be FALSE for all production builds. This should only be overridden for developer purposes to view console.
    static private(set) var isPrintEnabled: Bool = false {
        didSet {
            Logger.log(type: .info, object: "Logger isPrintEnabled set to '\(isPrintEnabled)'")
        }
    }
    
    /// Use this to override isPrintEnabled boolean.
    ///
    /// This should be the ONLY function in the entire app that sets isPrintEnabled.
    ///
    /// - Parameter isPrintEnabled: New override enable/disable printing to console.
    static func updateConfiguration(isPrintEnabled: Bool) {
        self.isPrintEnabled = isPrintEnabled
    }
    
    /// This function should be called for all logging throughout the application and should replace any existing print() statements.
    ///
    ///    It is safe to call log() in all schemes. Within the function is logic to determine if the log should print to the console and/or be to add the logHistory.
    ///
    /// - Parameters:
    ///   - type: The type of analytic to log.
    ///   - object: The content to log. Usually a String.
    ///   - filename: DO NOT SET. Default parameter will use the current #file.
    ///   - line: DO NOT SET. Default parameter will use the current #line.
    ///   - functionName: DO NOT SET. Default parameter will use the current #function.
    static func log(type: LogType, object: Any, filename: String = #file, line: Int = #line, functionName: String = #function) {
        let message = "[\(sourceFileName(filePath: filename))]: \(line) \(functionName) -> \(object)"

        if isPrintEnabled {
            Swift.print("\(type.rawValue) " + message)
        }
    }
  
    // MARK: PRIVATE
    
    /// Used internally to get the fileName that the log is deriving from.
    static private func sourceFileName(filePath: String) -> String {
        let components = filePath.components(separatedBy: "/")
        return components.last ?? ""
    }
    
}

// MARK: LOGGER+ENUMS

extension Logger {
    
    enum LogType: String, CaseIterable {
        
        /// Developer should never call 'none'. This can be used as a filtering mechanism for developers reviewing logHistory.
        case none = "❌"
        
        /// Use 'analytic'' for all analytic events.
        case analytic = "📈"
        
        /// Use 'info' for informative tasks, such as tracking functions. These logs should not be considered issues or errors.
        case info = "👋"
        
        /// Use 'warning' for issues or errors that should not occur, but will not negatively affect user experience.
        case warning = "⚠️"
        
        /// Use 'severe' for issues or errors that will negatively affect user experience, such as crashes or failing scenarios. Production builds should not have any 'severe' occurrences.
        case severe = "🚨"
    }

    
}

// MARK: LOGGER+MODEL

extension Logger {
    
    struct LogModel: Hashable {
        let type: LogType
        let time: Date
        let log: String
    }
    
}
