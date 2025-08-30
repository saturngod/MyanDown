//
//  MarkdownHighlighter.swift
//  MyanDown
//
//  Created by Bonjoy on 8/29/25.
//

import AppKit

final class MarkdownHighlighter {
    private let configuration: MyanDownEditorConfiguration
    private let vsCodeTheme: VSCodeTheme?

    // Precompiled regex patterns
    private let headerRegex = try! NSRegularExpression(pattern: "^(#{1,6})\\s+(.*)$", options: .anchorsMatchLines)
    private let altHeader1Regex = try! NSRegularExpression(pattern: "^(.+)\\n=+\\s*$", options: .anchorsMatchLines)
    private let altHeader2Regex = try! NSRegularExpression(pattern: "^(.+)\\n-+\\s*$", options: .anchorsMatchLines)
    private let boldItalicRegex = try! NSRegularExpression(pattern: "(\\*\\*\\*|___)([^*_\\n]+)(\\*\\*\\*|___)", options: [])
    private let boldRegex = try! NSRegularExpression(pattern: "(\\*\\*|__)([^*_\\n]+)(\\*\\*|__)", options: [])
    private let italicRegex = try! NSRegularExpression(pattern: "(?<!\\*|_)(\\*|_)([^*_\\n]+)(\\*|_)(?!\\*|_)", options: [])
    private let inlineCodeRegex = try! NSRegularExpression(pattern: "`([^`\\n]+)`", options: [])
    private let indentedCodeRegex = try! NSRegularExpression(pattern: "^(    |\\t)(.*)$", options: .anchorsMatchLines)
    private let fencedCodeRegex = try! NSRegularExpression(pattern: "```([a-zA-Z0-9_+#\\.-]+)?\\s*\\n([\\s\\S]*?)```", options: [])
    private let imageRegex = try! NSRegularExpression(pattern: "!\\[([^\\]]*)\\]\\(([^)]+)\\)", options: [])
    private let linkRegex = try! NSRegularExpression(pattern: "\\[([^\\]]+)\\]\\(([^)]+)\\)", options: [])
    private let autoLinkRegex = try! NSRegularExpression(pattern: "<(https?://[^>]+)>", options: [])
    private let emailRegex = try! NSRegularExpression(pattern: "<([a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,})>", options: [])
    private let strikeRegex = try! NSRegularExpression(pattern: "~~(.*?)~~", options: [])
    private let listRegex = try! NSRegularExpression(pattern: "^(\\s*)[-*+]\\s", options: .anchorsMatchLines)
    private let numberedListRegex = try! NSRegularExpression(pattern: "^(\\s*)\\d+\\.\\s", options: .anchorsMatchLines)
    private let blockquoteRegex = try! NSRegularExpression(pattern: "^(>+)\\s.*$", options: .anchorsMatchLines)
    private let hrRegex = try! NSRegularExpression(pattern: "^\\s*(-{3,}|\\*{3,}|_{3,})\\s*$", options: .anchorsMatchLines)
    private let escapeRegex = try! NSRegularExpression(pattern: "\\\\([\\\\`*_{}\\[\\]()#+\\-.!])", options: [])
    private let htmlRegex = try! NSRegularExpression(pattern: "<[^>]+>", options: [])

    init(configuration: MyanDownEditorConfiguration, vsCodeTheme: VSCodeTheme? = nil) {
        self.configuration = configuration
        self.vsCodeTheme = vsCodeTheme ?? VSCodeTheme.light
    }

    func applyHighlighting(to textView: NSTextView) {
        guard let textStorage = textView.textStorage else { return }
        let theme = configuration.theme
        let text = textStorage.string
        let fullRange = NSRange(location: 0, length: (text as NSString).length)
        let selectedRange = textView.selectedRange()

        textView.layoutManager?.ensureLayout(for: textView.textContainer!)

        textStorage.beginEditing()

        // Reset base attributes first (include paragraph style for line height)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = configuration.lineHeightMultiple
        textStorage.setAttributes([
            .foregroundColor: theme.baseColor,
            .font: theme.baseFont,
            .paragraphStyle: paragraphStyle
        ], range: fullRange)

        // Collect code block matches (ranges) first
        var fencedCodeMatches: [NSTextCheckingResult] = []
        var indentedCodeMatches: [NSTextCheckingResult] = []
        fencedCodeRegex.enumerateMatches(in: text, options: [], range: fullRange) { match, _, _ in
            guard let match else { return }
            fencedCodeMatches.append(match)
        }
        indentedCodeRegex.enumerateMatches(in: text, options: [], range: fullRange) { match, _, _ in
            guard let match else { return }
            // Skip indented lines that fall inside fenced code blocks
            var insideFenced = false
            for fenced in fencedCodeMatches {
                if NSIntersectionRange(match.range, fenced.range).length > 0 { insideFenced = true; break }
            }
            if !insideFenced { indentedCodeMatches.append(match) }
        }

        func intersectsAnyCode(_ range: NSRange) -> Bool {
            for m in fencedCodeMatches { if NSIntersectionRange(range, m.range).length > 0 { return true } }
            for m in indentedCodeMatches { if NSIntersectionRange(range, m.range).length > 0 { return true } }
            return false
        }

        // Headers (#)
        headerRegex.enumerateMatches(in: text, options: [], range: fullRange) { match, _, _ in
            guard let match else { return }
            if intersectsAnyCode(match.range) { return }
            textStorage.addAttributes([
                .foregroundColor: theme.headerColor,
                .font: theme.headerFont
            ], range: match.range)
        }

        // Alternative headers (=== / ---)
        altHeader1Regex.enumerateMatches(in: text, options: [], range: fullRange) { match, _, _ in
            guard let match else { return }
            if intersectsAnyCode(match.range) { return }
            textStorage.addAttributes([
                .foregroundColor: theme.headerColor,
                .font: theme.headerFont
            ], range: match.range)
        }

        altHeader2Regex.enumerateMatches(in: text, options: [], range: fullRange) { match, _, _ in
            guard let match else { return }
            if intersectsAnyCode(match.range) { return }
            textStorage.addAttributes([
                .foregroundColor: theme.headerColor,
                .font: theme.headerFont
            ], range: match.range)
        }

        // Bold + Italic
        boldItalicRegex.enumerateMatches(in: text, options: [], range: fullRange) { match, _, _ in
            guard let match else { return }
            if intersectsAnyCode(match.range) { return }
            let italicBold = NSFontManager.shared.font(withFamily: "Monaco", traits: [.boldFontMask, .italicFontMask], weight: 5, size: theme.baseFontSize) ?? NSFont.boldSystemFont(ofSize: theme.baseFontSize)
            textStorage.addAttributes([.font: italicBold], range: match.range)
        }

        // Bold
        boldRegex.enumerateMatches(in: text, options: [], range: fullRange) { match, _, _ in
            guard let match else { return }
            if intersectsAnyCode(match.range) { return }
            textStorage.addAttributes([.font: NSFont.boldSystemFont(ofSize: theme.baseFontSize)], range: match.range)
        }

        // Italic
        italicRegex.enumerateMatches(in: text, options: [], range: fullRange) { match, _, _ in
            guard let match else { return }
            if intersectsAnyCode(match.range) { return }
            textStorage.addAttributes([.font: theme.italicFont], range: match.range)
        }

        // Inline code - skip if already inside fenced code blocks
        inlineCodeRegex.enumerateMatches(in: text, options: [], range: fullRange) { match, _, _ in
            guard let match else { return }
            
            // Check if this inline code is inside a fenced code block
            var isInsideFencedCode = false
            fencedCodeRegex.enumerateMatches(in: text, options: [], range: fullRange) { fencedMatch, _, _ in
                guard let fencedMatch = fencedMatch else { return }
                if NSLocationInRange(match.range.location, fencedMatch.range) {
                    isInsideFencedCode = true
                }
            }
            
            // Only apply inline code highlighting if not inside fenced code block
            if !isInsideFencedCode {
                textStorage.addAttributes([
                    .foregroundColor: theme.codeForegroundColor,
                    .backgroundColor: theme.codeBackgroundColor,
                    .font: theme.codeFont
                ], range: match.range)
            }
        }

        // (Defer applying code block styling until the very end)


        // Images
        imageRegex.enumerateMatches(in: text, options: [], range: fullRange) { match, _, _ in
            guard let match else { return }
            if intersectsAnyCode(match.range) { return }
            textStorage.addAttributes([
                .foregroundColor: theme.imageColor,
                .font: NSFont.boldSystemFont(ofSize: theme.baseFontSize)
            ], range: match.range)
        }

        // Links (including auto/email)
        [linkRegex, autoLinkRegex, emailRegex].forEach { regex in
            regex.enumerateMatches(in: text, options: [], range: fullRange) { match, _, _ in
                guard let match else { return }
                if intersectsAnyCode(match.range) { return }
                textStorage.addAttributes([
                    .foregroundColor: theme.linkColor,
                    .underlineStyle: NSUnderlineStyle.single.rawValue
                ], range: match.range)
            }
        }

        // Strikethrough
        strikeRegex.enumerateMatches(in: text, options: [], range: fullRange) { match, _, _ in
            guard let match else { return }
            if intersectsAnyCode(match.range) { return }
            textStorage.addAttributes([
                .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                .foregroundColor: theme.strikeColor
            ], range: match.range)
        }

        // Lists
        [listRegex, numberedListRegex].forEach { regex in
            regex.enumerateMatches(in: text, options: [], range: fullRange) { match, _, _ in
                guard let match else { return }
                if intersectsAnyCode(match.range) { return }
                textStorage.addAttributes([
                    .foregroundColor: theme.listColor,
                    .font: theme.listFont
                ], range: match.range)
            }
        }

        // Blockquotes
        blockquoteRegex.enumerateMatches(in: text, options: [], range: fullRange) { match, _, _ in
            guard let match else { return }
            if intersectsAnyCode(match.range) { return }
            textStorage.addAttributes([
                .foregroundColor: theme.blockquoteColor,
                .font: theme.blockquoteFont
            ], range: match.range)
        }

        // Horizontal rules
        hrRegex.enumerateMatches(in: text, options: [], range: fullRange) { match, _, _ in
            guard let match else { return }
            if intersectsAnyCode(match.range) { return }
            textStorage.addAttributes([
                .foregroundColor: theme.ruleColor,
                .font: NSFont.boldSystemFont(ofSize: theme.baseFontSize)
            ], range: match.range)
        }

        // Escaped characters
        escapeRegex.enumerateMatches(in: text, options: [], range: fullRange) { match, _, _ in
            guard let match else { return }
            if intersectsAnyCode(match.range) { return }
            textStorage.addAttributes([
                .foregroundColor: theme.escapeColor
            ], range: match.range)
        }

        // HTML tags
        htmlRegex.enumerateMatches(in: text, options: [], range: fullRange) { match, _, _ in
            guard let match else { return }
            if intersectsAnyCode(match.range) { return }
            textStorage.addAttributes([
                .foregroundColor: theme.htmlColor,
                .font: theme.htmlFont
            ], range: match.range)
        }

        // === Apply code blocks LAST so they override any prior markdown styling ===
        // Fenced code blocks with optional language
        for match in fencedCodeMatches {
            let languageRange = match.range(at: 1)
            let codeRange = match.range(at: 2)
            // Background for whole block
            textStorage.addAttribute(.backgroundColor, value: theme.codeBackgroundColor, range: match.range)
            // Apply base code font to code content
            if codeRange.location != NSNotFound && codeRange.length > 0 {
                textStorage.addAttribute(.font, value: theme.codeFont, range: codeRange)
                let codeContent = (text as NSString).substring(with: codeRange)
                var language = ""
                if languageRange.location != NSNotFound && languageRange.length > 0 {
                    language = (text as NSString).substring(with: languageRange).lowercased()
                }
                if !language.isEmpty && CodeSyntaxHighlighter.supportsLanguage(language) {
                    let highlighted = CodeSyntaxHighlighter.highlightCode(codeContent, language: language, theme: theme, vsCodeTheme: vsCodeTheme)
                    highlighted.enumerateAttributes(in: NSRange(location: 0, length: highlighted.length), options: []) { attrs, attrRange, _ in
                        let adjusted = NSRange(location: codeRange.location + attrRange.location, length: attrRange.length)
                        if adjusted.location >= 0 && adjusted.location + adjusted.length <= textStorage.length {
                            for (key, value) in attrs {
                                textStorage.addAttribute(key, value: value, range: adjusted)
                            }
                        }
                    }
                } else {
                    textStorage.addAttribute(.foregroundColor, value: theme.codeForegroundColor, range: codeRange)
                }
            }
            // Style fences and language token
            let fullBlockText = (text as NSString).substring(with: match.range)
            let lines = fullBlockText.components(separatedBy: .newlines)
            if !lines.isEmpty {
                let firstLineStart = match.range.location
                let fenceMarkerRange = NSRange(location: firstLineStart, length: 3)
                textStorage.addAttributes([
                    .foregroundColor: NSColor.systemGray,
                    .font: theme.codeFont
                ], range: fenceMarkerRange)
                if languageRange.location != NSNotFound && languageRange.length > 0 {
                    textStorage.addAttributes([
                        .foregroundColor: NSColor.systemOrange,
                        .font: theme.codeFont
                    ], range: languageRange)
                }
            }
            if lines.count > 1, let lastLine = lines.last, lastLine.hasPrefix("```") {
                let lastLineStart = match.range.location + match.range.length - lastLine.count
                let closingFenceRange = NSRange(location: lastLineStart, length: 3)
                textStorage.addAttributes([
                    .foregroundColor: NSColor.systemGray,
                    .font: theme.codeFont
                ], range: closingFenceRange)
            }
        }

        // Indented code blocks (not inside fenced)
        for match in indentedCodeMatches {
            textStorage.addAttributes([
                .foregroundColor: theme.codeForegroundColor,
                .backgroundColor: theme.codeBackgroundColor,
                .font: theme.codeFont
            ], range: match.range)
        }

        textStorage.endEditing()
        textView.setSelectedRange(selectedRange)
    }
}