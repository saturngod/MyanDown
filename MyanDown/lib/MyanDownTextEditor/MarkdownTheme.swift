//
//  MarkdownTheme.swift
//  MyanDown
//
//  Created by Bonjoy on 8/29/25.
//

import AppKit

struct MarkdownTheme {
    let baseFont: NSFont
    let baseColor: NSColor

    let headerColor: NSColor
    let headerBaseFontSize: CGFloat

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

    func headerFont(for level: Int) -> NSFont {
        let clampedLevel = min(max(level, 1), 6)
        let size = max(headerBaseFontSize - CGFloat(clampedLevel - 1) * 2, baseFont.pointSize)
        return NSFont.boldSystemFont(ofSize: size)
    }

    static let standard = MarkdownTheme(
        baseFont: NSFont.monospacedSystemFont(ofSize: 14, weight: .regular),
        baseColor: NSColor.labelColor,
        headerColor: NSColor.systemBlue,
        headerBaseFontSize: 20,
        codeFont: NSFont.monospacedSystemFont(ofSize: 12, weight: .regular),
        codeForegroundColor: NSColor.systemRed,
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
        htmlFont: NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
    )
}