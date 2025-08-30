//
//  MyanDownTextEditor.swift
//  MyanDown
//
//  Created by Bonjoy on 8/29/25.
//

import SwiftUI
import AppKit

struct MyanDownTextEditor: NSViewRepresentable {
    @Binding var text: String
    var configuration: MyanDownEditorConfiguration = .standard
    
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        let textView = MarkdownNSTextView()
        
        // Basic setup
        textView.string = text
        textView.isEditable = true
        textView.isSelectable = true
        textView.isRichText = true
        textView.allowsUndo = true
        textView.font = configuration.theme.baseFont
        textView.textColor = configuration.theme.baseColor
        textView.delegate = context.coordinator
        
        // Layout - fix for long text rendering
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        textView.textContainer?.widthTracksTextView = true
        textView.textContainer?.containerSize = NSSize(width: 0, height: CGFloat.greatestFiniteMagnitude)
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.minSize = NSSize(width: 0, height: 0)
        
        // Better scroll behavior - minimal padding to prevent layout issues
        textView.textContainer?.lineFragmentPadding = configuration.lineFragmentPadding
        textView.textContainerInset = configuration.textContainerInset
        
        // Paragraph style for line height
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = configuration.lineHeightMultiple
        textView.defaultParagraphStyle = paragraphStyle
        textView.typingAttributes[.paragraphStyle] = paragraphStyle
        if let storage = textView.textStorage {
            let range = NSRange(location: 0, length: (storage.string as NSString).length)
            storage.addAttributes([.paragraphStyle: paragraphStyle], range: range)
        }
        
        scrollView.documentView = textView
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = false
        
        // Apply initial highlighting
        if configuration.enablesLiveHighlighting {
            DispatchQueue.main.async {
                context.coordinator.applyHighlighting(to: textView)
            }
        }

        // Focus on appear if requested
        if configuration.focusOnAppear {
            DispatchQueue.main.async {
                textView.window?.makeFirstResponder(textView)
            }
        }
        
        return scrollView
    }
    
    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView else { return }
        if textView.string != text {
            textView.string = text
            if configuration.enablesLiveHighlighting {
                context.coordinator.applyHighlighting(to: textView)
            }
        }
        // Ensure typing attributes keep the configured paragraph style
        if let style = textView.typingAttributes[.paragraphStyle] as? NSParagraphStyle,
           abs(style.lineHeightMultiple - configuration.lineHeightMultiple) > 0.0001 {
            let ps = NSMutableParagraphStyle()
            ps.lineHeightMultiple = configuration.lineHeightMultiple
            textView.typingAttributes[.paragraphStyle] = ps
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: MyanDownTextEditor
        let highlighter: MarkdownHighlighter
        
        init(_ parent: MyanDownTextEditor) {
            self.parent = parent
            self.highlighter = MarkdownHighlighter(configuration: parent.configuration)
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            parent.text = textView.string
            // Notify edited state if environment object is present (optional via Notification)
            NotificationCenter.default.post(name: .myanDownTextDidEdit, object: nil)
            
            // Apply highlighting immediately without layout disruption
            if parent.configuration.enablesLiveHighlighting {
                applyHighlighting(to: textView)
            }
        }
        
        func applyHighlighting(to textView: NSTextView) {
            highlighter.applyHighlighting(to: textView)
        }
    }
}

extension Notification.Name {
    static let myanDownTextDidEdit = Notification.Name("myanDownTextDidEdit")
}