//
//  MarkdownTheme.swift
//  MyanDown
//
//  Created by Bonjoy on 8/29/25.
//

import AppKit

struct MarkdownTheme {
    let baseFontSize: CGFloat
    let baseFont: NSFont
    let baseColor: NSColor

    let headerColor: NSColor
    let headerFont: NSFont

    let codeFont: NSFont
    let codeForegroundColor: NSColor
    let codeBackgroundColor: NSColor

    let linkColor: NSColor
    let imageColor: NSColor

    let listColor: NSColor
    let listFont: NSFont
    let italicFont: NSFont
    let blockquoteColor: NSColor
    let blockquoteFont: NSFont
    let ruleColor: NSColor

    let strikeColor: NSColor
    let escapeColor: NSColor
    let htmlColor: NSColor
    let htmlFont: NSFont

    static let standard: MarkdownTheme = {
        // Try to load from VSCode light theme first, fallback to basic theme
        if let lightTheme = VSCodeTheme.light {
            return lightTheme.toMarkdownTheme()
        }
        
        // Fallback if VSCode theme loading fails
        return MarkdownTheme(
            baseFontSize: 14,
            baseFont: NSFont.monospacedSystemFont(ofSize: 14, weight: .regular),
            baseColor: NSColor.labelColor,
            headerColor: NSColor.systemBlue,
            headerFont: NSFont.boldSystemFont(ofSize: 14),
            codeFont: NSFont.monospacedSystemFont(ofSize: 14, weight: .regular),
            codeForegroundColor: NSColor.labelColor,
            codeBackgroundColor: NSColor.controlBackgroundColor,
            linkColor: NSColor.systemBlue,
            imageColor: NSColor.systemPurple,
            listColor: NSColor.systemOrange,
            listFont: NSFont.boldSystemFont(ofSize: 14),
            italicFont: NSFontManager.shared.font(withFamily: "Monaco", traits: .italicFontMask, weight: 5, size: 14) ?? NSFont.monospacedSystemFont(ofSize: 14, weight: .regular),
            blockquoteColor: NSColor.systemGray,
            blockquoteFont: NSFontManager.shared.font(withFamily: "Monaco", traits: .italicFontMask, weight: 5, size: 14) ?? NSFont.monospacedSystemFont(ofSize: 14, weight: .regular),
            ruleColor: NSColor.systemGray,
            strikeColor: NSColor.systemGray,
            escapeColor: NSColor.systemYellow,
            htmlColor: NSColor.systemPink,
            htmlFont: NSFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        )
    }()
    
    static func fromVSCodeTheme(path: String) -> MarkdownTheme? {
        guard let vsCodeTheme = VSCodeTheme.load(from: path) else {
            return nil
        }
        return vsCodeTheme.toMarkdownTheme()
    }
    
    static func fromVSCodeTheme(named themeName: String) -> MarkdownTheme? {
        // Check cache first
        if let cachedTheme = cachedTheme(named: themeName) {
            return cachedTheme
        }
        
        guard let vsCodeTheme = VSCodeTheme.loadFromBundle(named: themeName) else {
            return nil
        }
        
        let theme = vsCodeTheme.toMarkdownTheme()
        setCachedTheme(theme, named: themeName)
        return theme
    }
    
    // MARK: - Theme Cache
    private static var themeCache: [String: MarkdownTheme] = [:]
    private static let cacheQueue = DispatchQueue(label: "com.myandown.markdown-theme-cache", attributes: .concurrent)
    
    static let githubLight: MarkdownTheme = {
        return fromVSCodeTheme(named: "light") ?? standard
    }()
    
    // MARK: - Convenience Methods
    
    /// Creates a copy of a theme with a unified font size for all elements
    /// - Parameters:
    ///   - baseFontSize: The font size to use for all elements
    ///   - baseTheme: The theme to copy colors and other properties from (defaults to .standard)
    /// - Returns: A new MarkdownTheme with unified font sizing
    static func withUnifiedFontSize(_ fontSize: CGFloat, basedOn baseTheme: MarkdownTheme = .standard) -> MarkdownTheme {
        return MarkdownTheme(
            baseFontSize: fontSize,
            baseFont: NSFont.monospacedSystemFont(ofSize: fontSize, weight: .regular),
            baseColor: baseTheme.baseColor,
            headerColor: baseTheme.headerColor,
            headerFont: NSFont.boldSystemFont(ofSize: fontSize),
            codeFont: NSFont.monospacedSystemFont(ofSize: fontSize, weight: .regular),
            codeForegroundColor: baseTheme.codeForegroundColor,
            codeBackgroundColor: baseTheme.codeBackgroundColor,
            linkColor: baseTheme.linkColor,
            imageColor: baseTheme.imageColor,
            listColor: baseTheme.listColor,
            listFont: NSFont.boldSystemFont(ofSize: fontSize),
            italicFont: NSFontManager.shared.font(withFamily: "Monaco", traits: .italicFontMask, weight: 5, size: fontSize) ?? NSFont.monospacedSystemFont(ofSize: fontSize, weight: .regular),
            blockquoteColor: baseTheme.blockquoteColor,
            blockquoteFont: NSFontManager.shared.font(withFamily: "Monaco", traits: .italicFontMask, weight: 5, size: fontSize) ?? NSFont.monospacedSystemFont(ofSize: fontSize, weight: .regular),
            ruleColor: baseTheme.ruleColor,
            strikeColor: baseTheme.strikeColor,
            escapeColor: baseTheme.escapeColor,
            htmlColor: baseTheme.htmlColor,
            htmlFont: NSFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
        )
    }
    
    static func cachedTheme(named themeName: String) -> MarkdownTheme? {
        return cacheQueue.sync { themeCache[themeName] }
    }
    
    static func setCachedTheme(_ theme: MarkdownTheme, named themeName: String) {
        cacheQueue.async(flags: .barrier) {
            themeCache[themeName] = theme
        }
    }
}