// Day002_PropertyWrappers.swift
// swift-daily — Daily Swift patterns and experiments
//
// Topic: Property Wrappers
// Practical examples of custom @propertyWrapper types in Swift.
// Property wrappers let you extract common get/set logic into reusable types.

import Foundation
import SwiftUI

// MARK: - @Clamped

/// Clamps a value between a minimum and maximum bound.
///
/// Useful for sliders, ratings, health stats, or any numeric value
/// that must stay within a valid range.
///
/// Usage:
/// ```swift
/// @Clamped(0...100) var progress: Double = 0
/// progress = 150   // → 100
/// progress = -5    // → 0
/// progress = 42    // → 42
/// ```
@propertyWrapper
struct Clamped<Value: Comparable> {
    private var value: Value
    private let range: ClosedRange<Value>

    init(wrappedValue: Value, _ range: ClosedRange<Value>) {
        self.range = range
        self.value = min(max(wrappedValue, range.lowerBound), range.upperBound)
    }

    var wrappedValue: Value {
        get { value }
        set { value = min(max(newValue, range.lowerBound), range.upperBound) }
    }
}

// MARK: - @UserDefault

/// Persists a value in UserDefaults with a type-safe interface.
///
/// Eliminates boilerplate when reading/writing simple preferences.
///
/// Usage:
/// ```swift
/// @UserDefault("has_seen_onboarding") var hasSeenOnboarding: Bool = false
/// hasSeenOnboarding = true  // Persisted immediately
/// ```
@propertyWrapper
struct UserDefault<T> {
    let key: String
    let defaultValue: T

    init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    var wrappedValue: T {
        get { UserDefaults.standard.object(forKey: key) as? T ?? defaultValue }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }
}

// MARK: - @Trimmed

/// Automatically trims whitespace and newlines from a String.
///
/// Great for form inputs where leading/trailing spaces are unwanted.
///
/// Usage:
/// ```swift
/// @Trimmed var username: String = ""
/// username = "  aleksei  "  // stored as "aleksei"
/// ```
@propertyWrapper
struct Trimmed {
    private var value: String = ""

    init(wrappedValue: String) {
        self.value = wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var wrappedValue: String {
        get { value }
        set { value = newValue.trimmingCharacters(in: .whitespacesAndNewlines) }
    }
}

// MARK: - @Logged

/// Logs every set operation to the console with the property name.
///
/// Handy during debugging to trace state changes without adding print
/// statements everywhere.
///
/// Usage:
/// ```swift
/// @Logged("authState") var isAuthenticated: Bool = false
/// isAuthenticated = true  // prints: [Logged] authState: false → true
/// ```
@propertyWrapper
struct Logged<T: CustomStringConvertible> {
    private var value: T
    private let label: String

    init(wrappedValue: T, _ label: String) {
        self.value = wrappedValue
        self.label = label
    }

    var wrappedValue: T {
        get { value }
        set {
            print("[Logged] \(label): \(value) → \(newValue)")
            value = newValue
        }
    }
}

// MARK: - Example Usage

struct PlayerStats {
    @Clamped(0...100) var health: Int = 100
    @Clamped(0...9999) var score: Int = 0
    @Logged("level") var level: Int = 1
}

struct AppSettings {
    @UserDefault("dark_mode_enabled", defaultValue: false) var darkModeEnabled: Bool
    @UserDefault("font_size", defaultValue: 16.0) var fontSize: Double
}

struct RegistrationForm {
    @Trimmed var email: String = ""
    @Trimmed var username: String = ""
}

// Quick demo
var player = PlayerStats()
player.health = 150    // clamped to 100
player.health = -10    // clamped to 0
player.level = 5       // prints: [Logged] level: 1 → 5

var form = RegistrationForm()
form.email = "  user@example.com  "
// form.email is now "user@example.com"
