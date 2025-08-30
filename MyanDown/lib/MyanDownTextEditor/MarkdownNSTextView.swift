//
//  MarkdownNSTextView.swift
//  MyanDown
//
//  Created by Bonjoy on 8/29/25.
//

import AppKit

final class MarkdownNSTextView: NSTextView {
    override var acceptsFirstResponder: Bool { true }

    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        guard event.type == .keyDown else { return super.performKeyEquivalent(with: event) }
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        guard flags.contains(.command), let chars = event.charactersIgnoringModifiers?.lowercased() else {
            return super.performKeyEquivalent(with: event)
        }

        switch chars {
        case "b":
            toggleMarkup("**")
            return true
        case "i":
            toggleMarkup("*")
            return true
        case "a":
            selectAll(nil)
            return true
        case "c":
            copy(nil)
            return true
        case "v":
            paste(nil)
            return true
        case "x":
            cut(nil)
            return true
        case "z":
            if flags.contains(.shift) {
                undoManager?.redo()
            } else {
                undoManager?.undo()
            }
            return true
        case "y":
            // Common alternate redo shortcut
            undoManager?.redo()
            return true
        default:
            return super.performKeyEquivalent(with: event)
        }
    }

    private func toggleMarkup(_ mark: String) {
        guard let storage = textStorage else { return }
        let nsText = string as NSString
        let sel = selectedRange()

        // If empty selection: insert paired marks and place caret between
        if sel.length == 0 {
            let insertion = mark + mark
            if shouldChangeText(in: sel, replacementString: insertion) {
                storage.replaceCharacters(in: sel, with: insertion)
                didChangeText()
                setSelectedRange(NSRange(location: sel.location + mark.count, length: 0))
            }
            return
        }

        // Try to unwrap if already wrapped with the same mark
        if sel.location >= mark.count && sel.location + sel.length + mark.count <= nsText.length {
            let beforeRange = NSRange(location: sel.location - mark.count, length: mark.count)
            let afterRange = NSRange(location: sel.location + sel.length, length: mark.count)
            let before = nsText.substring(with: beforeRange)
            let after = nsText.substring(with: afterRange)
            if before == mark && after == mark {
                storage.beginEditing()
                if shouldChangeText(in: afterRange, replacementString: "") {
                    storage.replaceCharacters(in: afterRange, with: "")
                }
                if shouldChangeText(in: beforeRange, replacementString: "") {
                    storage.replaceCharacters(in: beforeRange, with: "")
                }
                storage.endEditing()
                didChangeText()
                setSelectedRange(NSRange(location: sel.location - mark.count, length: sel.length))
                return
            }
        }

        // Otherwise wrap selection
        let afterRange = NSRange(location: sel.location + sel.length, length: 0)
        storage.beginEditing()
        if shouldChangeText(in: afterRange, replacementString: mark) {
            storage.replaceCharacters(in: afterRange, with: mark)
        }
        if shouldChangeText(in: sel, replacementString: mark) {
            storage.replaceCharacters(in: sel, with: mark)
        }
        storage.endEditing()
        didChangeText()
        setSelectedRange(NSRange(location: sel.location + mark.count, length: sel.length))
    }
}