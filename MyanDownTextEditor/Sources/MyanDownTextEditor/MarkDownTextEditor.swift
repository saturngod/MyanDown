import SwiftUI
import AppKit

// MARK: - Markdown Theme & Configuration

struct MarkdownTheme : @unchecked Sendable{
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

public struct MarkdownEditorConfiguration : Sendable{
    var theme: MarkdownTheme
    var lineFragmentPadding: CGFloat
    var textContainerInset: NSSize
    var enablesLiveHighlighting: Bool
    var focusOnAppear: Bool

    static let standard = MarkdownEditorConfiguration(
        theme: .standard,
        lineFragmentPadding: 5,
        textContainerInset: NSSize(width: 5, height: 5),
        enablesLiveHighlighting: true,
        focusOnAppear: true
    )
}
// MARK: - NSTextView with keyboard shortcuts

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


// MARK: - Language Definitions

struct LanguageDefinition {
    let keywords: [String]
    let types: [String]?
    let operators: [String]?
    let stringPattern: String
    let commentPatterns: [String]
    let variablePattern: String?
    let numberPattern: String
    let functionPattern: String?
    
    init(keywords: [String],
         types: [String]? = nil,
         operators: [String]? = nil,
         stringPattern: String = "([\"'])(?:[^\\\\\\1]|\\\\.)*?\\1",
         commentPatterns: [String] = ["//.*$", "/\\*[\\s\\S]*?\\*/"],
         variablePattern: String? = nil,
         numberPattern: String = "\\b\\d+(?:\\.\\d+)?\\b",
         functionPattern: String? = nil) {
        self.keywords = keywords
        self.types = types
        self.operators = operators
        self.stringPattern = stringPattern
        self.commentPatterns = commentPatterns
        self.variablePattern = variablePattern
        self.numberPattern = numberPattern
        self.functionPattern = functionPattern
    }
}

// MARK: - Code Syntax Highlighter

final class CodeSyntaxHighlighter {
    
    private static let languages: [String: LanguageDefinition] = [
        "javascript": LanguageDefinition(
            keywords: ["abstract", "arguments", "await", "boolean", "break", "byte", "case", "catch", "char", "class", "const", "continue", "debugger", "default", "delete", "do", "double", "else", "enum", "eval", "export", "extends", "false", "final", "finally", "float", "for", "function", "goto", "if", "implements", "import", "in", "instanceof", "int", "interface", "let", "long", "native", "new", "null", "package", "private", "protected", "public", "return", "short", "static", "super", "switch", "synchronized", "this", "throw", "throws", "transient", "true", "try", "typeof", "var", "void", "volatile", "while", "with", "yield", "async", "console", "log", "window", "document"],
            types: ["Array", "Object", "String", "Number", "Boolean", "Function", "Promise", "Map", "Set"],
            stringPattern: "([\"'`])(?:[^\\\\\\1]|\\\\.)*?\\1"
        ),
        
        "js": LanguageDefinition(
            keywords: ["abstract", "arguments", "await", "boolean", "break", "byte", "case", "catch", "char", "class", "const", "continue", "debugger", "default", "delete", "do", "double", "else", "enum", "eval", "export", "extends", "false", "final", "finally", "float", "for", "function", "goto", "if", "implements", "import", "in", "instanceof", "int", "interface", "let", "long", "native", "new", "null", "package", "private", "protected", "public", "return", "short", "static", "super", "switch", "synchronized", "this", "throw", "throws", "transient", "true", "try", "typeof", "var", "void", "volatile", "while", "with", "yield", "async", "console", "log", "window", "document"],
            types: ["Array", "Object", "String", "Number", "Boolean", "Function", "Promise", "Map", "Set"],
            stringPattern: "([\"'`])(?:[^\\\\\\1]|\\\\.)*?\\1"
        ),
        
        "typescript": LanguageDefinition(
            keywords: ["abstract", "any", "as", "asserts", "async", "await", "boolean", "break", "case", "catch", "class", "const", "continue", "declare", "default", "delete", "do", "else", "enum", "export", "extends", "false", "finally", "for", "from", "function", "get", "if", "implements", "import", "in", "infer", "instanceof", "interface", "is", "keyof", "let", "module", "namespace", "never", "new", "null", "number", "object", "of", "package", "private", "protected", "public", "readonly", "require", "return", "set", "static", "string", "super", "switch", "symbol", "this", "throw", "true", "try", "type", "typeof", "undefined", "unique", "unknown", "var", "void", "while", "with", "yield"],
            types: ["Array", "Object", "String", "Number", "Boolean", "Function", "Promise", "Map", "Set", "any", "unknown", "never", "void"],
            stringPattern: "([\"'`])(?:[^\\\\\\1]|\\\\.)*?\\1"
        ),
        
        "ts": LanguageDefinition(
            keywords: ["abstract", "any", "as", "asserts", "async", "await", "boolean", "break", "case", "catch", "class", "const", "continue", "declare", "default", "delete", "do", "else", "enum", "export", "extends", "false", "finally", "for", "from", "function", "get", "if", "implements", "import", "in", "infer", "instanceof", "interface", "is", "keyof", "let", "module", "namespace", "never", "new", "null", "number", "object", "of", "package", "private", "protected", "public", "readonly", "require", "return", "set", "static", "string", "super", "switch", "symbol", "this", "throw", "true", "try", "type", "typeof", "undefined", "unique", "unknown", "var", "void", "while", "with", "yield"],
            types: ["Array", "Object", "String", "Number", "Boolean", "Function", "Promise", "Map", "Set", "any", "unknown", "never", "void"],
            stringPattern: "([\"'`])(?:[^\\\\\\1]|\\\\.)*?\\1"
        ),
        
        "jsx": LanguageDefinition(
            keywords: ["abstract", "arguments", "await", "boolean", "break", "byte", "case", "catch", "char", "class", "const", "continue", "debugger", "default", "delete", "do", "double", "else", "enum", "eval", "export", "extends", "false", "final", "finally", "float", "for", "function", "goto", "if", "implements", "import", "in", "instanceof", "int", "interface", "let", "long", "native", "new", "null", "package", "private", "protected", "public", "return", "short", "static", "super", "switch", "synchronized", "this", "throw", "throws", "transient", "true", "try", "typeof", "var", "void", "volatile", "while", "with", "yield", "async", "React", "useState", "useEffect", "useContext", "props", "state", "render"],
            types: ["Array", "Object", "String", "Number", "Boolean", "Function", "Promise", "Map", "Set", "Component", "Element"],
            stringPattern: "([\"'`])(?:[^\\\\\\1]|\\\\.)*?\\1"
        ),
        
        "tsx": LanguageDefinition(
            keywords: ["abstract", "any", "as", "asserts", "async", "await", "boolean", "break", "case", "catch", "class", "const", "continue", "declare", "default", "delete", "do", "else", "enum", "export", "extends", "false", "finally", "for", "from", "function", "get", "if", "implements", "import", "in", "infer", "instanceof", "interface", "is", "keyof", "let", "module", "namespace", "never", "new", "null", "number", "object", "of", "package", "private", "protected", "public", "readonly", "require", "return", "set", "static", "string", "super", "switch", "symbol", "this", "throw", "true", "try", "type", "typeof", "undefined", "unique", "unknown", "var", "void", "while", "with", "yield", "React", "useState", "useEffect", "useContext", "props", "state", "render"],
            types: ["Array", "Object", "String", "Number", "Boolean", "Function", "Promise", "Map", "Set", "Component", "Element", "any", "unknown", "never", "void"],
            stringPattern: "([\"'`])(?:[^\\\\\\1]|\\\\.)*?\\1"
        ),
        
        "swift": LanguageDefinition(
            keywords: ["associatedtype", "class", "deinit", "enum", "extension", "func", "import", "init", "inout", "internal", "let", "operator", "private", "protocol", "public", "static", "struct", "subscript", "typealias", "var", "break", "case", "continue", "default", "defer", "do", "else", "fallthrough", "for", "guard", "if", "in", "repeat", "return", "switch", "where", "while", "as", "catch", "false", "is", "nil", "rethrows", "super", "self", "Self", "throw", "throws", "true", "try", "async", "await", "print"],
            types: ["Any", "AnyObject", "AnyClass", "String", "Int", "Double", "Float", "Bool", "Array", "Dictionary", "Set", "Optional", "Result", "Error"],
            stringPattern: "\"(?:[^\"\\\\]|\\\\.)*\""
        ),
        
        "php": LanguageDefinition(
            keywords: ["abstract", "and", "array", "as", "break", "callable", "case", "catch", "class", "clone", "const", "continue", "declare", "default", "die", "do", "echo", "else", "elseif", "empty", "enddeclare", "endfor", "endforeach", "endif", "endswitch", "endwhile", "eval", "exit", "extends", "final", "finally", "for", "foreach", "function", "global", "goto", "if", "implements", "include", "include_once", "instanceof", "insteadof", "interface", "isset", "list", "namespace", "new", "or", "print", "private", "protected", "public", "require", "require_once", "return", "static", "switch", "throw", "trait", "try", "unset", "use", "var", "while", "xor", "yield"],
            types: ["string", "int", "float", "bool", "array", "object", "resource", "null", "mixed"],
            stringPattern: "([\"'])(?:[^\\\\\\1]|\\\\.)*?\\1",
            variablePattern: "\\$[a-zA-Z_\\x7f-\\xff][a-zA-Z0-9_\\x7f-\\xff]*"
        ),
        
        "java": LanguageDefinition(
            keywords: ["abstract", "assert", "boolean", "break", "byte", "case", "catch", "char", "class", "const", "continue", "default", "do", "double", "else", "enum", "extends", "final", "finally", "float", "for", "goto", "if", "implements", "import", "instanceof", "int", "interface", "long", "native", "new", "package", "private", "protected", "public", "return", "short", "static", "strictfp", "super", "switch", "synchronized", "this", "throw", "throws", "transient", "try", "void", "volatile", "while", "System", "out", "println", "print"],
            types: ["String", "Integer", "Double", "Float", "Boolean", "Character", "Byte", "Short", "Long", "Object", "Array", "List", "Map", "Set"],
            stringPattern: "\"(?:[^\"\\\\]|\\\\.)*\""
        ),
        
        "csharp": LanguageDefinition(
            keywords: ["abstract", "as", "base", "bool", "break", "byte", "case", "catch", "char", "checked", "class", "const", "continue", "decimal", "default", "delegate", "do", "double", "else", "enum", "event", "explicit", "extern", "false", "finally", "fixed", "float", "for", "foreach", "goto", "if", "implicit", "in", "int", "interface", "internal", "is", "lock", "long", "namespace", "new", "null", "object", "operator", "out", "override", "params", "private", "protected", "public", "readonly", "ref", "return", "sbyte", "sealed", "short", "sizeof", "stackalloc", "static", "string", "struct", "switch", "this", "throw", "true", "try", "typeof", "uint", "ulong", "unchecked", "unsafe", "ushort", "using", "virtual", "void", "volatile", "while", "Console", "WriteLine", "Write"],
            types: ["string", "int", "double", "float", "bool", "char", "byte", "short", "long", "decimal", "object", "Array", "List", "Dictionary"],
            stringPattern: "\"(?:[^\"\\\\]|\\\\.)*\""
        ),
        
        "c#": LanguageDefinition(
            keywords: ["abstract", "as", "base", "bool", "break", "byte", "case", "catch", "char", "checked", "class", "const", "continue", "decimal", "default", "delegate", "do", "double", "else", "enum", "event", "explicit", "extern", "false", "finally", "fixed", "float", "for", "foreach", "goto", "if", "implicit", "in", "int", "interface", "internal", "is", "lock", "long", "namespace", "new", "null", "object", "operator", "out", "override", "params", "private", "protected", "public", "readonly", "ref", "return", "sbyte", "sealed", "short", "sizeof", "stackalloc", "static", "string", "struct", "switch", "this", "throw", "true", "try", "typeof", "uint", "ulong", "unchecked", "unsafe", "ushort", "using", "virtual", "void", "volatile", "while", "Console", "WriteLine", "Write"],
            types: ["string", "int", "double", "float", "bool", "char", "byte", "short", "long", "decimal", "object", "Array", "List", "Dictionary"],
            stringPattern: "\"(?:[^\"\\\\]|\\\\.)*\""
        ),
        
        "bash": LanguageDefinition(
            keywords: ["if", "then", "else", "elif", "fi", "case", "esac", "for", "select", "while", "until", "do", "done", "function", "time", "coproc", "in", "break", "continue", "return", "exit", "export", "local", "readonly", "declare", "typeset", "unset", "shift", "test", "eval", "exec", "source", "alias", "unalias", "history", "jobs", "bg", "fg", "wait", "kill", "trap", "echo", "printf", "read", "cd", "pwd", "pushd", "popd", "dirs", "ls", "cat", "grep", "awk", "sed", "sort", "uniq", "wc", "head", "tail", "find", "xargs", "chmod", "chown", "cp", "mv", "rm", "mkdir", "rmdir", "touch", "ln", "mount", "umount", "ps", "top", "df", "du", "free", "uname", "whoami", "id", "groups", "su", "sudo"],
            types: [],
            stringPattern: "([\"'])(?:[^\\\\\\1]|\\\\.)*?\\1",
            commentPatterns: ["#.*$"],
            variablePattern: "\\$[a-zA-Z_][a-zA-Z0-9_]*|\\$\\{[^}]+\\}"
        ),
        
        "sh": LanguageDefinition(
            keywords: ["if", "then", "else", "elif", "fi", "case", "esac", "for", "select", "while", "until", "do", "done", "function", "time", "coproc", "in", "break", "continue", "return", "exit", "export", "local", "readonly", "declare", "typeset", "unset", "shift", "test", "eval", "exec", "source", "alias", "unalias", "history", "jobs", "bg", "fg", "wait", "kill", "trap", "echo", "printf", "read", "cd", "pwd", "pushd", "popd", "dirs", "ls", "cat", "grep", "awk", "sed", "sort", "uniq", "wc", "head", "tail", "find", "xargs", "chmod", "chown", "cp", "mv", "rm", "mkdir", "rmdir", "touch", "ln", "mount", "umount", "ps", "top", "df", "du", "free", "uname", "whoami", "id", "groups", "su", "sudo"],
            types: [],
            stringPattern: "([\"'])(?:[^\\\\\\1]|\\\\.)*?\\1",
            commentPatterns: ["#.*$"],
            variablePattern: "\\$[a-zA-Z_][a-zA-Z0-9_]*|\\$\\{[^}]+\\}"
        ),
        
        "python": LanguageDefinition(
            keywords: ["and", "as", "assert", "break", "class", "continue", "def", "del", "elif", "else", "except", "exec", "finally", "for", "from", "global", "if", "import", "in", "is", "lambda", "not", "or", "pass", "print", "raise", "return", "try", "while", "with", "yield", "True", "False", "None", "async", "await", "nonlocal"],
            types: ["int", "float", "str", "bool", "list", "dict", "tuple", "set", "frozenset", "bytes", "bytearray"],
            stringPattern: "([\"'])(?:[^\\\\\\1]|\\\\.)*?\\1|\"\"\"[\\s\\S]*?\"\"\"|'''[\\s\\S]*?'''",
            commentPatterns: ["#.*$"]
        ),
        
        "py": LanguageDefinition(
            keywords: ["and", "as", "assert", "break", "class", "continue", "def", "del", "elif", "else", "except", "exec", "finally", "for", "from", "global", "if", "import", "in", "is", "lambda", "not", "or", "pass", "print", "raise", "return", "try", "while", "with", "yield", "True", "False", "None", "async", "await", "nonlocal"],
            types: ["int", "float", "str", "bool", "list", "dict", "tuple", "set", "frozenset", "bytes", "bytearray"],
            stringPattern: "([\"'])(?:[^\\\\\\1]|\\\\.)*?\\1|\"\"\"[\\s\\S]*?\"\"\"|'''[\\s\\S]*?'''",
            commentPatterns: ["#.*$"]
        ),

        // JSON
        "json": LanguageDefinition(
            keywords: ["true", "false", "null"],
            types: nil,
            operators: nil,
            stringPattern: "\"(?:[^\"\\\\]|\\\\.)*\"",
            commentPatterns: [],
            variablePattern: nil,
            numberPattern: "-?\\d+(?:\\.\\d+)?(?:[eE][+-]?\\d+)?"
        ),

        // Git/Diff/Patch (special line-based handling in highlighter)
        "diff": LanguageDefinition(keywords: [], commentPatterns: []),
        "git": LanguageDefinition(keywords: [], commentPatterns: []),
        "patch": LanguageDefinition(keywords: [], commentPatterns: []),

        // Elixir and aliases
        "elixir": LanguageDefinition(
            keywords: ["def", "defp", "defmodule", "defmacro", "defstruct", "do", "end", "fn", "when", "case", "cond", "if", "else", "receive", "after", "try", "catch", "rescue", "raise", "alias", "import", "require", "use", "with", "quote", "unquote", "true", "false", "nil"],
            types: ["String", "Integer", "Float", "List", "Map", "Tuple", "Atom"],
            operators: nil,
            stringPattern: "([\"'])(?:[^\\\\\\1]|\\\\.)*?\\1|\"\"\"[\\s\\S]*?\"\"\"|'''[\\s\\S]*?'''",
            commentPatterns: ["#.*$"]
        ),
        "ex": LanguageDefinition(
            keywords: ["def", "defp", "defmodule", "defmacro", "defstruct", "do", "end", "fn", "when", "case", "cond", "if", "else", "receive", "after", "try", "catch", "rescue", "raise", "alias", "import", "require", "use", "with", "quote", "unquote", "true", "false", "nil"],
            types: ["String", "Integer", "Float", "List", "Map", "Tuple", "Atom"],
            operators: nil,
            stringPattern: "([\"'])(?:[^\\\\\\1]|\\\\.)*?\\1|\"\"\"[\\s\\S]*?\"\"\"|'''[\\s\\S]*?'''",
            commentPatterns: ["#.*$"]
        ),
        "exs": LanguageDefinition(
            keywords: ["def", "defp", "defmodule", "defmacro", "defstruct", "do", "end", "fn", "when", "case", "cond", "if", "else", "receive", "after", "try", "catch", "rescue", "raise", "alias", "import", "require", "use", "with", "quote", "unquote", "true", "false", "nil"],
            types: ["String", "Integer", "Float", "List", "Map", "Tuple", "Atom"],
            operators: nil,
            stringPattern: "([\"'])(?:[^\\\\\\1]|\\\\.)*?\\1|\"\"\"[\\s\\S]*?\"\"\"|'''[\\s\\S]*?'''",
            commentPatterns: ["#.*$"]
        ),

        // VB.NET and aliases
        "vbnet": LanguageDefinition(
            keywords: ["Dim", "As", "Integer", "String", "Boolean", "Double", "Decimal", "Sub", "Function", "End", "If", "Then", "Else", "ElseIf", "While", "For", "Each", "In", "Next", "Return", "Public", "Private", "Protected", "Friend", "Class", "Module", "Imports", "Namespace", "Try", "Catch", "Finally", "Throw", "Select", "Case", "New", "Me", "MyBase", "MyClass", "Not", "And", "Or", "True", "False", "Nothing"],
            types: ["Integer", "String", "Boolean", "Double", "Decimal", "Object", "List", "Dictionary", "DateTime", "Byte", "Short", "Long", "Char"],
            operators: nil,
            stringPattern: "\"(?:[^\"]|\"\")*\"",
            commentPatterns: ["'.*$", "(?i)\\bREM\\b.*$"]
        ),
        // Alias
        "vb": LanguageDefinition(
            keywords: ["Dim", "As", "Integer", "String", "Boolean", "Double", "Decimal", "Sub", "Function", "End", "If", "Then", "Else", "ElseIf", "While", "For", "Each", "In", "Next", "Return", "Public", "Private", "Protected", "Friend", "Class", "Module", "Imports", "Namespace", "Try", "Catch", "Finally", "Throw", "Select", "Case", "New", "Me", "MyBase", "MyClass", "Not", "And", "Or", "True", "False", "Nothing"],
            types: ["Integer", "String", "Boolean", "Double", "Decimal", "Object", "List", "Dictionary", "DateTime", "Byte", "Short", "Long", "Char"],
            operators: nil,
            stringPattern: "\"(?:[^\"]|\"\")*\"",
            commentPatterns: ["'.*$", "(?i)\\bREM\\b.*$"]
        ),

        // AppleScript and alias
        "applescript": LanguageDefinition(
            keywords: ["tell", "end", "if", "then", "else", "repeat", "with", "without", "of", "to", "set", "get", "property", "script", "on", "try", "error", "return", "considering", "ignoring", "activate", "display", "do", "shell", "script"],
            types: ["integer", "real", "text", "string", "list", "record", "date", "boolean"],
            operators: nil,
            stringPattern: "\"(?:[^\"\\\\]|\\\\.)*\"",
            commentPatterns: ["--.*$", "\\(\\*[\\s\\S]*?\\*\\)"]
        ),
        "osascript": LanguageDefinition(
            keywords: ["tell", "end", "if", "then", "else", "repeat", "with", "without", "of", "to", "set", "get", "property", "script", "on", "try", "error", "return", "considering", "ignoring", "activate", "display", "do", "shell", "script"],
            types: ["integer", "real", "text", "string", "list", "record", "date", "boolean"],
            operators: nil,
            stringPattern: "\"(?:[^\"\\\\]|\\\\.)*\"",
            commentPatterns: ["--.*$", "\\(\\*[\\s\\S]*?\\*\\)"]
        ),

        // Alias for C# common short name and common misspelling
        "cs": LanguageDefinition(
            keywords: ["abstract", "as", "base", "bool", "break", "byte", "case", "catch", "char", "checked", "class", "const", "continue", "decimal", "default", "delegate", "do", "double", "else", "enum", "event", "explicit", "extern", "false", "finally", "fixed", "float", "for", "foreach", "goto", "if", "implicit", "in", "int", "interface", "internal", "is", "lock", "long", "namespace", "new", "null", "object", "operator", "out", "override", "params", "private", "protected", "public", "readonly", "ref", "return", "sbyte", "sealed", "short", "sizeof", "stackalloc", "static", "string", "struct", "switch", "this", "throw", "true", "try", "typeof", "uint", "ulong", "unchecked", "unsafe", "ushort", "using", "virtual", "void", "volatile", "while", "Console", "WriteLine", "Write"],
            types: ["string", "int", "double", "float", "bool", "char", "byte", "short", "long", "decimal", "object", "Array", "List", "Dictionary"],
            stringPattern: "\"(?:[^\"\\\\]|\\\\.)*\""
        ),
        "chsarp": LanguageDefinition(
            keywords: ["abstract", "as", "base", "bool", "break", "byte", "case", "catch", "char", "checked", "class", "const", "continue", "decimal", "default", "delegate", "do", "double", "else", "enum", "event", "explicit", "extern", "false", "finally", "fixed", "float", "for", "foreach", "goto", "if", "implicit", "in", "int", "interface", "internal", "is", "lock", "long", "namespace", "new", "null", "object", "operator", "out", "override", "params", "private", "protected", "public", "readonly", "ref", "return", "sbyte", "sealed", "short", "sizeof", "stackalloc", "static", "string", "struct", "switch", "this", "throw", "true", "try", "typeof", "uint", "ulong", "unchecked", "unsafe", "ushort", "using", "virtual", "void", "volatile", "while", "Console", "WriteLine", "Write"],
            types: ["string", "int", "double", "float", "bool", "char", "byte", "short", "long", "decimal", "object", "Array", "List", "Dictionary"],
            stringPattern: "\"(?:[^\"\\\\]|\\\\.)*\""
        )
        ,

        // Ruby and alias
        "ruby": LanguageDefinition(
            keywords: ["BEGIN", "END", "alias", "and", "begin", "break", "case", "class", "def", "defined?", "do", "else", "elsif", "end", "ensure", "false", "for", "if", "in", "module", "next", "nil", "not", "or", "redo", "rescue", "retry", "return", "self", "super", "then", "true", "undef", "unless", "until", "when", "while", "yield", "puts", "print", "require"],
            types: ["String", "Integer", "Float", "Array", "Hash", "Symbol", "Object", "NilClass", "TrueClass", "FalseClass"],
            stringPattern: "\"(?:[^\"\\\\]|\\\\.)*\"|'(?:[^'\\\\]|\\\\.)*'",
            commentPatterns: ["#.*$"]
        ),
        "rb": LanguageDefinition(
            keywords: ["BEGIN", "END", "alias", "and", "begin", "break", "case", "class", "def", "defined?", "do", "else", "elsif", "end", "ensure", "false", "for", "if", "in", "module", "next", "nil", "not", "or", "redo", "rescue", "retry", "return", "self", "super", "then", "true", "undef", "unless", "until", "when", "while", "yield", "puts", "print", "require"],
            types: ["String", "Integer", "Float", "Array", "Hash", "Symbol", "Object", "NilClass", "TrueClass", "FalseClass"],
            stringPattern: "\"(?:[^\"\\\\]|\\\\.)*\"|'(?:[^'\\\\]|\\\\.)*'",
            commentPatterns: ["#.*$"]
        ),

        // Go
        "go": LanguageDefinition(
            keywords: ["break", "case", "chan", "const", "continue", "default", "defer", "else", "fallthrough", "for", "func", "go", "goto", "if", "import", "interface", "map", "package", "range", "return", "select", "struct", "switch", "type", "var", "true", "false", "nil", "iota"],
            types: ["string", "int", "int8", "int16", "int32", "int64", "uint", "uint8", "uint16", "uint32", "uint64", "uintptr", "byte", "rune", "float32", "float64", "complex64", "complex128", "bool", "error"],
            stringPattern: "\"(?:[^\"\\]|\\\\.)*\"|'(?:[^'\\]|\\\\.)*'|`[\\s\\S]*?`",
            commentPatterns: ["//.*$", "/\\*[\\s\\S]*?\\*/"]
        ),

        // Rust and alias
        "rust": LanguageDefinition(
            keywords: ["as", "break", "const", "continue", "crate", "else", "enum", "extern", "false", "fn", "for", "if", "impl", "in", "let", "loop", "match", "mod", "move", "mut", "pub", "ref", "return", "Self", "self", "static", "struct", "super", "trait", "true", "type", "unsafe", "use", "where", "while", "async", "await", "dyn"],
            types: ["String", "str", "i8", "i16", "i32", "i64", "i128", "isize", "u8", "u16", "u32", "u64", "u128", "usize", "f32", "f64", "bool", "char", "Option", "Result", "Vec", "Box"],
            stringPattern: "\"(?:[^\"\\]|\\\\.)*\"|'(?:[^'\\]|\\\\.)*'|r#?\"[\\s\\S]*?\"#?",
            commentPatterns: ["//.*$", "/\\*[\\s\\S]*?\\*/"]
        ),
        "rs": LanguageDefinition(
            keywords: ["as", "break", "const", "continue", "crate", "else", "enum", "extern", "false", "fn", "for", "if", "impl", "in", "let", "loop", "match", "mod", "move", "mut", "pub", "ref", "return", "Self", "self", "static", "struct", "super", "trait", "true", "type", "unsafe", "use", "where", "while", "async", "await", "dyn"],
            types: ["String", "str", "i8", "i16", "i32", "i64", "i128", "isize", "u8", "u16", "u32", "u64", "u128", "usize", "f32", "f64", "bool", "char", "Option", "Result", "Vec", "Box"],
            stringPattern: "\"(?:[^\"\\]|\\\\.)*\"|'(?:[^'\\]|\\\\.)*'|r#?\"[\\s\\S]*?\"#?",
            commentPatterns: ["//.*$", "/\\*[\\s\\S]*?\\*/"]
        ),

        // SQL
        "sql": LanguageDefinition(
            keywords: ["SELECT", "FROM", "WHERE", "INSERT", "INTO", "VALUES", "UPDATE", "SET", "DELETE", "CREATE", "TABLE", "ALTER", "ADD", "DROP", "PRIMARY", "KEY", "FOREIGN", "NOT", "NULL", "JOIN", "LEFT", "RIGHT", "FULL", "OUTER", "INNER", "ON", "GROUP", "BY", "ORDER", "HAVING", "DISTINCT", "LIMIT", "OFFSET", "UNION", "ALL", "AND", "OR", "AS", "IN", "IS", "BETWEEN", "LIKE", "CASE", "WHEN", "THEN", "ELSE", "END"],
            types: ["INT", "INTEGER", "VARCHAR", "TEXT", "DATE", "DATETIME", "BOOLEAN", "FLOAT", "DOUBLE", "DECIMAL", "NUMERIC", "SERIAL", "BIGINT", "SMALLINT", "JSON", "UUID"],
            stringPattern: "'(?:[^'\\\\]|\\\\.)*'|\"(?:[^\"\\\\]|\\\\.)*\"",
            commentPatterns: ["--.*$", "/\\*[\\s\\S]*?\\*/"],
            numberPattern: "-?\\b\\d+(?:\\.\\d+)?\\b"
        ),

        // YAML and alias (handled specially too)
        "yaml": LanguageDefinition(
            keywords: ["true", "false", "null", "yes", "no", "on", "off"],
            stringPattern: "\"(?:[^\"\\\\]|\\\\.)*\"|'(?:[^'\\\\]|\\\\.)*'",
            commentPatterns: ["#.*$"],
            numberPattern: "-?\\b\\d+(?:\\.\\d+)?\\b"
        ),
        "yml": LanguageDefinition(
            keywords: ["true", "false", "null", "yes", "no", "on", "off"],
            stringPattern: "\"(?:[^\"\\\\]|\\\\.)*\"|'(?:[^'\\\\]|\\\\.)*'",
            commentPatterns: ["#.*$"],
            numberPattern: "-?\\b\\d+(?:\\.\\d+)?\\b"
        ),

        // HTML and CSS placeholders (handled specially)
        "html": LanguageDefinition(keywords: [], commentPatterns: []),
        "css": LanguageDefinition(keywords: [], commentPatterns: [])
    ]
    
    static func supportsLanguage(_ language: String) -> Bool {
        return languages[language.lowercased()] != nil
    }
    
    static func highlightCode(_ code: String, language: String, theme: MarkdownTheme) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: code)
        let range = NSRange(location: 0, length: code.count)
        
        // Apply base styling (NO foreground color - let syntax highlighting set all colors)
        attributedString.addAttributes([
            .font: theme.codeFont
            // DON'T set foregroundColor here - let each syntax element set its own
        ], range: range)
        
        // Get language definition
        let lowerLang = language.lowercased()
        guard let langDef = languages[lowerLang] else {
            return attributedString
        }
        
        let text = code
        let nsText = text as NSString
        
        // Special case: Git/Diff/Patch - line-based coloring
        if ["diff", "git", "patch"].contains(lowerLang) {
            nsText.enumerateSubstrings(in: NSRange(location: 0, length: nsText.length), options: .byLines) { substring, lineRange, _, _ in
                guard let line = substring else { return }
                if line.hasPrefix("@@") {
                    attributedString.addAttribute(.foregroundColor, value: NSColor.systemOrange, range: lineRange)
                } else if line.hasPrefix("+++") || line.hasPrefix("---") {
                    attributedString.addAttribute(.foregroundColor, value: NSColor.systemBlue, range: lineRange)
                } else if line.hasPrefix("+") {
                    attributedString.addAttribute(.foregroundColor, value: NSColor.systemGreen, range: lineRange)
                } else if line.hasPrefix("-") {
                    attributedString.addAttribute(.foregroundColor, value: NSColor.systemRed, range: lineRange)
                } else if line.hasPrefix("diff ") || line.hasPrefix("index ") {
                    attributedString.addAttribute(.foregroundColor, value: NSColor.systemGray, range: lineRange)
                }
            }
            
            // Apply default color to any remaining unstyled text
            attributedString.enumerateAttribute(.foregroundColor, in: range, options: []) { color, attrRange, _ in
                if color == nil {
                    attributedString.addAttribute(.foregroundColor, value: theme.codeForegroundColor, range: attrRange)
                }
            }
            return attributedString
        }

        // Special case: HTML - tag/attribute-focused coloring
        if lowerLang == "html" {
            // Comments
            if let commentRegex = try? NSRegularExpression(pattern: "<!--[\\s\\S]*?-->", options: []) {
                commentRegex.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
                    guard let match else { return }
                    attributedString.addAttribute(.foregroundColor, value: NSColor.systemGray, range: match.range)
                }
            }

            // Tag names
            if let tagNameRegex = try? NSRegularExpression(pattern: "</?([a-zA-Z][a-zA-Z0-9:-]*)\\b", options: []) {
                tagNameRegex.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
                    guard let match else { return }
                    let nameRange = match.range(at: 1)
                    attributedString.addAttribute(.foregroundColor, value: NSColor.systemPurple, range: nameRange)
                }
            }

            // Attributes name=value
            if let attrRegex = try? NSRegularExpression(pattern: "([a-zA-Z_:][-a-zA-Z0-9_:.]*)\\s*=\\s*(\"[^\\\"]*\"|'[^']*')", options: []) {
                attrRegex.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
                    guard let match else { return }
                    let nameRange = match.range(at: 1)
                    let valueRange = match.range(at: 2)
                    attributedString.addAttribute(.foregroundColor, value: NSColor.systemBlue, range: nameRange)
                    attributedString.addAttribute(.foregroundColor, value: NSColor.systemGreen, range: valueRange)
                }
            }

            // Default color for remaining
            attributedString.enumerateAttribute(.foregroundColor, in: range, options: []) { color, attrRange, _ in
                if color == nil {
                    attributedString.addAttribute(.foregroundColor, value: theme.codeForegroundColor, range: attrRange)
                }
            }
            return attributedString
        }

        // Special case: CSS - selectors/properties/at-rules/colors
        if lowerLang == "css" {
            // Comments
            if let commentRegex = try? NSRegularExpression(pattern: "/\\*[\\s\\S]*?\\*/", options: []) {
                commentRegex.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
                    guard let match else { return }
                    attributedString.addAttribute(.foregroundColor, value: NSColor.systemGray, range: match.range)
                }
            }

            // Strings
            if let cssString = try? NSRegularExpression(pattern: "([\\\"'])(?:[^\\\\\\1]|\\\\.)*?\\1", options: []) {
                cssString.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
                    guard let match else { return }
                    attributedString.addAttribute(.foregroundColor, value: NSColor.systemGreen, range: match.range)
                }
            }

            // @rules
            if let atRule = try? NSRegularExpression(pattern: "^\\s*@\\w+", options: .anchorsMatchLines) {
                atRule.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
                    guard let match else { return }
                    attributedString.addAttribute(.foregroundColor, value: NSColor.systemPurple, range: match.range)
                }
            }

            // Property names before colon
            if let propName = try? NSRegularExpression(pattern: "^\\s*([A-Za-z_-][A-Za-z0-9_-]*)\\s*:", options: .anchorsMatchLines) {
                propName.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
                    guard let match else { return }
                    let nameRange = match.range(at: 1)
                    attributedString.addAttribute(.foregroundColor, value: NSColor.systemBlue, range: nameRange)
                }
            }

            // Hex colors
            if let hex = try? NSRegularExpression(pattern: "#[0-9a-fA-F]{3,8}\\b", options: []) {
                hex.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
                    guard let match else { return }
                    attributedString.addAttribute(.foregroundColor, value: NSColor.systemTeal, range: match.range)
                }
            }

            // Selectors tokens: .class, #id, :pseudo, ::pseudo
            if let selectorToken = try? NSRegularExpression(pattern: "(\\.[-\\w]+|#[-\\w]+|::?[-\\w]+)", options: []) {
                selectorToken.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
                    guard let match else { return }
                    attributedString.addAttribute(.foregroundColor, value: NSColor.systemPurple, range: match.range)
                }
            }

            // Numbers with units
            if let numUnit = try? NSRegularExpression(pattern: "\\b\\d+(?:\\.\\d+)?(?:px|em|rem|vh|vw|%|s|ms)?\\b", options: []) {
                numUnit.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
                    guard let match else { return }
                    attributedString.addAttribute(.foregroundColor, value: NSColor.systemOrange, range: match.range)
                }
            }

            // Default color for remaining
            attributedString.enumerateAttribute(.foregroundColor, in: range, options: []) { color, attrRange, _ in
                if color == nil {
                    attributedString.addAttribute(.foregroundColor, value: theme.codeForegroundColor, range: attrRange)
                }
            }
            return attributedString
        }

        // Special case: YAML - keys/anchors/booleans
        if lowerLang == "yaml" || lowerLang == "yml" {
            // Comments
            if let commentRegex = try? NSRegularExpression(pattern: "#.*$", options: .anchorsMatchLines) {
                commentRegex.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
                    guard let match else { return }
                    attributedString.addAttribute(.foregroundColor, value: NSColor.systemGray, range: match.range)
                }
            }

            // Strings
            if let stringRegex = try? NSRegularExpression(pattern: "([\\\"'])(?:[^\\\\\\1]|\\\\.)*?\\1", options: []) {
                stringRegex.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
                    guard let match else { return }
                    attributedString.addAttribute(.foregroundColor, value: NSColor.systemGreen, range: match.range)
                }
            }

            // Numbers
            if let numberRegex = try? NSRegularExpression(pattern: "-?\\b\\d+(?:\\.\\d+)?\\b", options: []) {
                numberRegex.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
                    guard let match else { return }
                    attributedString.addAttribute(.foregroundColor, value: NSColor.systemOrange, range: match.range)
                }
            }

            // Keys at line start before colon
            if let keyRegex = try? NSRegularExpression(pattern: "^\\s*([^\\s:#][^:]*?)\\s*:", options: .anchorsMatchLines) {
                keyRegex.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
                    guard let match else { return }
                    let keyRange = match.range(at: 1)
                    attributedString.addAttribute(.foregroundColor, value: NSColor.systemBlue, range: keyRange)
                }
            }

            // Booleans/null common literals
            if let boolRegex = try? NSRegularExpression(pattern: "(?i)\\b(true|false|null|yes|no|on|off)\\b", options: []) {
                boolRegex.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
                    guard let match else { return }
                    attributedString.addAttribute(.foregroundColor, value: NSColor.systemPurple, range: match.range)
                }
            }

            // Anchors and aliases &name or *name
            if let anchorRegex = try? NSRegularExpression(pattern: "[&*][A-Za-z0-9_-]+", options: []) {
                anchorRegex.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
                    guard let match else { return }
                    attributedString.addAttribute(.foregroundColor, value: NSColor.systemTeal, range: match.range)
                }
            }

            // Default color for remaining
            attributedString.enumerateAttribute(.foregroundColor, in: range, options: []) { color, attrRange, _ in
                if color == nil {
                    attributedString.addAttribute(.foregroundColor, value: theme.codeForegroundColor, range: attrRange)
                }
            }
            return attributedString
        }
        
        // Apply syntax highlighting in order (comments first to avoid conflicts)
        
        // 1. Comments (gray)
        for commentPattern in langDef.commentPatterns {
            if let commentRegex = try? NSRegularExpression(pattern: commentPattern, options: .anchorsMatchLines) {
                commentRegex.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
                    guard let match = match else { return }
                    attributedString.addAttribute(.foregroundColor, value: NSColor.systemGray, range: match.range)
                }
            }
        }
        
        // 2. Strings (green)
        if let stringRegex = try? NSRegularExpression(pattern: langDef.stringPattern, options: []) {
            stringRegex.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
                guard let match = match else { return }
                attributedString.addAttribute(.foregroundColor, value: NSColor.systemGreen, range: match.range)
            }
        }
        
        // 3. Numbers (orange)
        if let numberRegex = try? NSRegularExpression(pattern: langDef.numberPattern, options: []) {
            numberRegex.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
                guard let match = match else { return }
                attributedString.addAttribute(.foregroundColor, value: NSColor.systemOrange, range: match.range)
            }
        }
        
        // 4. Variables (blue) - for languages that have them
        if let variablePattern = langDef.variablePattern,
           let variableRegex = try? NSRegularExpression(pattern: variablePattern, options: []) {
            variableRegex.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
                guard let match = match else { return }
                attributedString.addAttribute(.foregroundColor, value: NSColor.systemBlue, range: match.range)
            }
        }
        
        // 5. Keywords (purple)
        for keyword in langDef.keywords {
            if let keywordRegex = try? NSRegularExpression(pattern: "\\b\(NSRegularExpression.escapedPattern(for: keyword))\\b", options: []) {
                keywordRegex.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
                    guard let match = match else { return }
                    attributedString.addAttribute(.foregroundColor, value: NSColor.systemPurple, range: match.range)
                }
            }
        }
        
        // 6. Types (cyan/teal)
        if let types = langDef.types {
            for type in types {
                if let typeRegex = try? NSRegularExpression(pattern: "\\b\(NSRegularExpression.escapedPattern(for: type))\\b", options: []) {
                    typeRegex.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
                        guard let match = match else { return }
                        attributedString.addAttribute(.foregroundColor, value: NSColor.systemTeal, range: match.range)
                    }
                }
            }
        }
        
        // JSON: highlight keys ("key":) as blue to distinguish from string values
        if lowerLang == "json" {
            if let keyRegex = try? NSRegularExpression(pattern: "^\\s*(\"[^\"]+?\")\\s*:", options: .anchorsMatchLines) {
                keyRegex.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
                    guard let match = match else { return }
                    let keyRange = match.range(at: 1)
                    attributedString.addAttribute(.foregroundColor, value: NSColor.systemBlue, range: keyRange)
                }
            }
        }
        
        // Apply default color to any remaining unstyled text
        attributedString.enumerateAttribute(.foregroundColor, in: range, options: []) { color, attrRange, _ in
            if color == nil {
                // This text has no color set, give it the default code color
                attributedString.addAttribute(.foregroundColor, value: theme.codeForegroundColor, range: attrRange)
            }
        }
        
        return attributedString
    }
}

// MARK: - Highlighter

final class MarkdownHighlighter {
    private let configuration: MarkdownEditorConfiguration

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

    init(configuration: MarkdownEditorConfiguration) {
        self.configuration = configuration
    }

    @MainActor func applyHighlighting(to textView: NSTextView) {
        guard let textStorage = textView.textStorage else { return }
        let theme = configuration.theme
        let text = textStorage.string
        let fullRange = NSRange(location: 0, length: (text as NSString).length)
        let selectedRange = textView.selectedRange()

        textView.layoutManager?.ensureLayout(for: textView.textContainer!)

        textStorage.beginEditing()

        // Reset base attributes first
        textStorage.setAttributes([
            .foregroundColor: theme.baseColor,
            .font: theme.baseFont
        ], range: fullRange)

        // *** FENCED CODE BLOCKS FIRST - to prevent other rules from overriding ***
        fencedCodeRegex.enumerateMatches(in: text, options: [], range: fullRange) { match, _, _ in
            guard let match else { return }
            
            // Extract language and code content
            let languageRange = match.range(at: 1)
            let codeRange = match.range(at: 2)
            
            // Apply background to the entire block first
            textStorage.addAttribute(.backgroundColor, value: theme.codeBackgroundColor, range: match.range)
            
            // Extract language
            var language = ""
            if languageRange.location != NSNotFound && languageRange.length > 0 {
                language = (text as NSString).substring(with: languageRange).lowercased()
            }
            
            // Extract code content
            if codeRange.location != NSNotFound && codeRange.length > 0 {
                let codeContent = (text as NSString).substring(with: codeRange)
                
                // Apply base code font to entire code content first
                textStorage.addAttribute(.font, value: theme.codeFont, range: codeRange)
                
                // Apply syntax highlighting if we have a supported language
                if !language.isEmpty && CodeSyntaxHighlighter.supportsLanguage(language) {
                    // Get syntax highlighted version
                    let highlightedCode = CodeSyntaxHighlighter.highlightCode(codeContent, language: language, theme: theme)
                    
                    // Apply highlighted attributes
                    highlightedCode.enumerateAttributes(in: NSRange(location: 0, length: highlightedCode.length), options: []) { attrs, attrRange, _ in
                        let adjustedRange = NSRange(location: codeRange.location + attrRange.location, length: attrRange.length)
                        // Safety check
                        if adjustedRange.location >= 0 &&
                           adjustedRange.location + adjustedRange.length <= textStorage.length {
                            // Apply each attribute
                            for (key, value) in attrs {
                                textStorage.addAttribute(key, value: value, range: adjustedRange)
                            }
                        }
                    }
                } else {
                    // Default code highlighting for unsupported languages
                    textStorage.addAttribute(.foregroundColor, value: theme.codeForegroundColor, range: codeRange)
                }
            }
            
            // Style fence markers and language identifier
            let fullBlockText = (text as NSString).substring(with: match.range)
            let lines = fullBlockText.components(separatedBy: .newlines)
            
            // Style opening fence (``` + language)
            if !lines.isEmpty {
                let firstLineStart = match.range.location
                let fenceMarkerRange = NSRange(location: firstLineStart, length: 3)
                textStorage.addAttributes([
                    .foregroundColor: NSColor.systemGray,
                    .font: theme.codeFont
                ], range: fenceMarkerRange)
                
                // Style language identifier
                if languageRange.location != NSNotFound && languageRange.length > 0 {
                    textStorage.addAttributes([
                        .foregroundColor: NSColor.systemOrange,
                        .font: theme.codeFont
                    ], range: languageRange)
                }
            }
            
            // Style closing fence
            if lines.count > 1, let lastLine = lines.last, lastLine.hasPrefix("```") {
                let lastLineStart = match.range.location + match.range.length - lastLine.count
                let closingFenceRange = NSRange(location: lastLineStart, length: 3)
                textStorage.addAttributes([
                    .foregroundColor: NSColor.systemGray,
                    .font: theme.codeFont
                ], range: closingFenceRange)
            }
        }

        // Headers (#)
        headerRegex.enumerateMatches(in: text, options: [], range: fullRange) { match, _, _ in
            guard let match else { return }
            let headerLevel = match.range(at: 1).length
            textStorage.addAttributes([
                .foregroundColor: theme.headerColor,
                .font: theme.headerFont(for: headerLevel)
            ], range: match.range)
        }

        // Alternative headers (=== / ---)
        altHeader1Regex.enumerateMatches(in: text, options: [], range: fullRange) { match, _, _ in
            guard let match else { return }
            textStorage.addAttributes([
                .foregroundColor: theme.headerColor,
                .font: NSFont.boldSystemFont(ofSize: theme.headerBaseFontSize)
            ], range: match.range)
        }

        altHeader2Regex.enumerateMatches(in: text, options: [], range: fullRange) { match, _, _ in
            guard let match else { return }
            textStorage.addAttributes([
                .foregroundColor: theme.headerColor,
                .font: NSFont.boldSystemFont(ofSize: max(theme.headerBaseFontSize - 2, theme.baseFont.pointSize))
            ], range: match.range)
        }

        // Bold + Italic
        boldItalicRegex.enumerateMatches(in: text, options: [], range: fullRange) { match, _, _ in
            guard let match else { return }
            let italicBold = NSFontManager.shared.font(withFamily: "Monaco", traits: [.boldFontMask, .italicFontMask], weight: 5, size: theme.baseFont.pointSize) ?? NSFont.boldSystemFont(ofSize: theme.baseFont.pointSize)
            textStorage.addAttributes([.font: italicBold], range: match.range)
        }

        // Bold
        boldRegex.enumerateMatches(in: text, options: [], range: fullRange) { match, _, _ in
            guard let match else { return }
            textStorage.addAttributes([.font: NSFont.boldSystemFont(ofSize: theme.baseFont.pointSize)], range: match.range)
        }

        // Italic
        italicRegex.enumerateMatches(in: text, options: [], range: fullRange) { match, _, _ in
            guard let match else { return }
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

        // Indented code blocks - skip if already inside fenced code blocks
        indentedCodeRegex.enumerateMatches(in: text, options: [], range: fullRange) { match, _, _ in
            guard let match else { return }
            
            // Check if this indented code is inside a fenced code block
            var isInsideFencedCode = false
            fencedCodeRegex.enumerateMatches(in: text, options: [], range: fullRange) { fencedMatch, _, _ in
                guard let fencedMatch = fencedMatch else { return }
                if NSLocationInRange(match.range.location, fencedMatch.range) {
                    isInsideFencedCode = true
                }
            }
            
            // Only apply indented code highlighting if not inside fenced code block
            if !isInsideFencedCode {
                textStorage.addAttributes([
                    .foregroundColor: theme.codeForegroundColor,
                    .backgroundColor: theme.codeBackgroundColor,
                    .font: theme.codeFont
                ], range: match.range)
            }
        }


        // Images
        imageRegex.enumerateMatches(in: text, options: [], range: fullRange) { match, _, _ in
            guard let match else { return }
            textStorage.addAttributes([
                .foregroundColor: theme.imageColor,
                .font: NSFont.boldSystemFont(ofSize: theme.baseFont.pointSize)
            ], range: match.range)
        }

        // Links (including auto/email)
        [linkRegex, autoLinkRegex, emailRegex].forEach { regex in
            regex.enumerateMatches(in: text, options: [], range: fullRange) { match, _, _ in
                guard let match else { return }
                textStorage.addAttributes([
                    .foregroundColor: theme.linkColor,
                    .underlineStyle: NSUnderlineStyle.single.rawValue
                ], range: match.range)
            }
        }

        // Strikethrough
        strikeRegex.enumerateMatches(in: text, options: [], range: fullRange) { match, _, _ in
            guard let match else { return }
            textStorage.addAttributes([
                .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                .foregroundColor: theme.strikeColor
            ], range: match.range)
        }

        // Lists
        [listRegex, numberedListRegex].forEach { regex in
            regex.enumerateMatches(in: text, options: [], range: fullRange) { match, _, _ in
                guard let match else { return }
                textStorage.addAttributes([
                    .foregroundColor: theme.listColor,
                    .font: theme.listFont
                ], range: match.range)
            }
        }

        // Blockquotes
        blockquoteRegex.enumerateMatches(in: text, options: [], range: fullRange) { match, _, _ in
            guard let match else { return }
            textStorage.addAttributes([
                .foregroundColor: theme.blockquoteColor,
                .font: theme.blockquoteFont
            ], range: match.range)
        }

        // Horizontal rules
        hrRegex.enumerateMatches(in: text, options: [], range: fullRange) { match, _, _ in
            guard let match else { return }
            textStorage.addAttributes([
                .foregroundColor: theme.ruleColor,
                .font: NSFont.boldSystemFont(ofSize: theme.baseFont.pointSize)
            ], range: match.range)
        }

        // Escaped characters
        escapeRegex.enumerateMatches(in: text, options: [], range: fullRange) { match, _, _ in
            guard let match else { return }
            textStorage.addAttributes([
                .foregroundColor: theme.escapeColor
            ], range: match.range)
        }

        // HTML tags
        htmlRegex.enumerateMatches(in: text, options: [], range: fullRange) { match, _, _ in
            guard let match else { return }
            textStorage.addAttributes([
                .foregroundColor: theme.htmlColor,
                .font: theme.htmlFont
            ], range: match.range)
        }

        textStorage.endEditing()
        textView.setSelectedRange(selectedRange)
    }
}

public struct MarkdownTextEditor: NSViewRepresentable {
    @Binding var text: String
    var configuration: MarkdownEditorConfiguration = .standard
    
    public func makeNSView(context: Context) -> NSScrollView {
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
    
    public func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView else { return }
        if textView.string != text {
            textView.string = text
            if configuration.enablesLiveHighlighting {
                context.coordinator.applyHighlighting(to: textView)
            }
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public class Coordinator: NSObject, NSTextViewDelegate {
        var parent: MarkdownTextEditor
        let highlighter: MarkdownHighlighter
        
        init(_ parent: MarkdownTextEditor) {
            self.parent = parent
            self.highlighter = MarkdownHighlighter(configuration: parent.configuration)
        }
        
        public func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            parent.text = textView.string
            
            // Apply highlighting immediately without layout disruption
            if parent.configuration.enablesLiveHighlighting {
                applyHighlighting(to: textView)
            }
        }
        
        @MainActor func applyHighlighting(to textView: NSTextView) {
            highlighter.applyHighlighting(to: textView)
        }
    }
}
