import Foundation

/// Replaces snippet triggers with their expansions in a piece of dictated text.
///
/// Rules:
/// - Whole-word match (so "my address" won't match inside "my addressing").
/// - Case-insensitive (SFSpeechRecognizer may capitalize; user may have saved
///   triggers in any case).
/// - Longer triggers are processed first, so that if two triggers overlap the
///   more-specific one wins (e.g. "meeting link zoom" beats "meeting link").
public enum SnippetExpander {
    public static func expand(_ text: String, using snippets: [Snippet]) -> String {
        guard !text.isEmpty, !snippets.isEmpty else { return text }
        let candidates = snippets
            .filter { !$0.trigger.isEmpty }
            .sorted { $0.trigger.count > $1.trigger.count }

        var result = text
        for snippet in candidates {
            let pattern = "\\b" + NSRegularExpression.escapedPattern(for: snippet.trigger) + "\\b"
            guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else { continue }
            let range = NSRange(result.startIndex..., in: result)
            let template = NSRegularExpression.escapedTemplate(for: snippet.expansion)
            result = regex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: template)
        }
        return result
    }
}
