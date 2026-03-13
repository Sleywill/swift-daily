//
//  Day003_StringExtensions.swift
//  swift-daily
//
//  Practical String extensions for everyday iOS development.
//  Covers validation, formatting, and safe subscripting.
//

import Foundation

// MARK: - Validation

extension String {

    /// Returns true if the string is a valid email address.
    ///
    /// Uses a standard RFC 5322 simplified pattern suitable for
    /// client-side validation before submitting to an API.
    ///
    /// - Example:
    ///   - "user@example.com".isValidEmail  // true
    ///   - "not-an-email".isValidEmail      // false
    var isValidEmail: Bool {
        let pattern = #"^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$"#
        return range(of: pattern, options: .regularExpression) != nil
    }

    /// Returns true if the string contains only digit characters.
    ///
    /// - Example:
    ///   - "12345".isNumeric   // true
    ///   - "123abc".isNumeric  // false
    var isNumeric: Bool {
        !isEmpty && allSatisfy(\.isNumber)
    }

    /// Returns true if the string has no non-whitespace characters.
    ///
    /// - Example:
    ///   - "  hello  ".isBlank  // false
    ///   - "   ".isBlank        // true
    var isBlank: Bool {
        trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

// MARK: - Formatting

extension String {

    /// Returns the string with leading and trailing whitespace removed.
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Truncates the string to maxLength characters, appending a suffix if needed.
    ///
    /// - Parameters:
    ///   - maxLength: The maximum number of characters before truncation.
    ///   - suffix: Appended when truncation occurs. Defaults to ellipsis.
    func truncated(to maxLength: Int, suffix: String = "…") -> String {
        guard count > maxLength else { return self }
        return String(prefix(maxLength)) + suffix
    }

    /// Converts a snake_case or kebab-case string to camelCase.
    ///
    /// - Example:
    ///   - "user_first_name".camelCased   // "userFirstName"
    ///   - "background-color".camelCased  // "backgroundColor"
    var camelCased: String {
        let parts = components(separatedBy: CharacterSet(charactersIn: "_-"))
        return parts.enumerated().map { index, part in
            index == 0 ? part.lowercased() : part.capitalized
        }.joined()
    }

    /// Returns a new string with only the first character uppercased.
    /// Unlike capitalized, this does not lowercase the remaining characters.
    var firstUppercased: String {
        guard let first else { return self }
        return String(first).uppercased() + dropFirst()
    }
}

// MARK: - Safe Subscripting

extension String {

    /// Safely accesses a character at the given integer index.
    /// Returns nil if the index is out of bounds.
    subscript(safe index: Int) -> Character? {
        guard index >= 0, index < count else { return nil }
        return self[self.index(startIndex, offsetBy: index)]
    }

    /// Safely accesses a substring for the given integer range.
    /// Returns nil if the range is out of bounds.
    subscript(safe range: Range<Int>) -> String? {
        guard range.lowerBound >= 0, range.upperBound <= count else { return nil }
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(startIndex, offsetBy: range.upperBound)
        return String(self[start..<end])
    }
}
