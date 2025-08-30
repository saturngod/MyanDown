//
//  MyanDownEditorConfiguration.swift
//  MyanDown
//
//  Created by Bonjoy on 8/29/25.
//

import Foundation

struct MyanDownEditorConfiguration {
    var theme: MarkdownTheme
    var lineFragmentPadding: CGFloat
    var textContainerInset: NSSize
    var lineHeightMultiple: CGFloat
    var enablesLiveHighlighting: Bool
    var focusOnAppear: Bool

    static let standard = MyanDownEditorConfiguration(
        theme: .standard,
        lineFragmentPadding: 5,
        textContainerInset: NSSize(width: 5, height: 5),
        lineHeightMultiple: 1.2,
        enablesLiveHighlighting: true,
        focusOnAppear: true
    )
}
