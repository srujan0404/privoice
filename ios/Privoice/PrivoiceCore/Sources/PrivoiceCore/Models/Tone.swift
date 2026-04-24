import Foundation

public enum Tone: String, Codable, Sendable, CaseIterable, Identifiable {
    case casual
    case professional
    case friendly

    public static let `default`: Tone = .casual

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .casual: return "Casual"
        case .professional: return "Professional"
        case .friendly: return "Friendly"
        }
    }

    public var tagline: String {
        switch self {
        case .casual: return "How you'd text your best friend."
        case .professional: return "Clean, polished, ready to send to your boss."
        case .friendly: return "Warm and approachable, great for most people."
        }
    }

    public var exampleText: String {
        switch self {
        case .casual: return "Gonna be late, start without me"
        case .professional: return "I'll be arriving late. Please start without me."
        case .friendly: return "Running a bit late — go ahead and start without me!"
        }
    }
}
