//
//  CodeSyntaxHighlighter.swift
//  MyanDown
//
//  Created by Bonjoy on 8/29/25.
//

import AppKit

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
        ),

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
            stringPattern: "\"(?:[^\"\\\\]|\\\\.)*\"|'(?:[^'\\\\]|\\\\.)*'|`[\\s\\S]*?`",
            commentPatterns: ["//.*$", "/\\*[\\s\\S]*?\\*/"]
        ),

        // Rust and alias
        "rust": LanguageDefinition(
            keywords: ["as", "break", "const", "continue", "crate", "else", "enum", "extern", "false", "fn", "for", "if", "impl", "in", "let", "loop", "match", "mod", "move", "mut", "pub", "ref", "return", "Self", "self", "static", "struct", "super", "trait", "true", "type", "unsafe", "use", "where", "while", "async", "await", "dyn"],
            types: ["String", "str", "i8", "i16", "i32", "i64", "i128", "isize", "u8", "u16", "u32", "u64", "u128", "usize", "f32", "f64", "bool", "char", "Option", "Result", "Vec", "Box"],
            stringPattern: "\"(?:[^\"\\\\]|\\\\.)*\"|'(?:[^'\\\\]|\\\\.)*'|r#?\"[\\s\\S]*?\"#?",
            commentPatterns: ["//.*$", "/\\*[\\s\\S]*?\\*/"]
        ),
        "rs": LanguageDefinition(
            keywords: ["as", "break", "const", "continue", "crate", "else", "enum", "extern", "false", "fn", "for", "if", "impl", "in", "let", "loop", "match", "mod", "move", "mut", "pub", "ref", "return", "Self", "self", "static", "struct", "super", "trait", "true", "type", "unsafe", "use", "where", "while", "async", "await", "dyn"],
            types: ["String", "str", "i8", "i16", "i32", "i64", "i128", "isize", "u8", "u16", "u32", "u64", "u128", "usize", "f32", "f64", "bool", "char", "Option", "Result", "Vec", "Box"],
            stringPattern: "\"(?:[^\"\\\\]|\\\\.)*\"|'(?:[^'\\\\]|\\\\.)*'|r#?\"[\\s\\S]*?\"#?",
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
    
    static func highlightCode(_ code: String, language: String, theme: MarkdownTheme, vsCodeTheme: VSCodeTheme? = nil) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: code)
        let range = NSRange(location: 0, length: code.count)
        
        // Helper function to get color from VS Code theme or fallback to GitHub Light colors
        func getColor(for element: SyntaxElement, fallback: NSColor) -> NSColor {
            if let color = vsCodeTheme?.getColorForSyntaxElement(element) {
                return color
            }
            
            // Use GitHub Light theme colors as fallbacks instead of system colors
            func colorFromHex(_ hex: String) -> NSColor? {
                var hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
                
                if hexString.hasPrefix("#") {
                    hexString.removeFirst()
                }
                
                guard hexString.count == 6 else { return nil }
                
                var rgb: UInt64 = 0
                guard Scanner(string: hexString).scanHexInt64(&rgb) else { return nil }
                
                let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
                let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
                let blue = CGFloat(rgb & 0x0000FF) / 255.0
                
                return NSColor(red: red, green: green, blue: blue, alpha: 1.0)
            }
            
            switch element {
            case .comment:
                return colorFromHex("#6a737d") ?? fallback // Gray
            case .string:
                return colorFromHex("#032f62") ?? fallback // Dark blue
            case .keyword:
                return colorFromHex("#d73a49") ?? fallback // Red
            case .storage:
                return colorFromHex("#d73a49") ?? fallback // Red (same as keyword)
            case .entity:
                return colorFromHex("#6f42c1") ?? fallback // Purple
            case .constant:
                return colorFromHex("#005cc5") ?? fallback // Blue
            case .variable:
                return colorFromHex("#e36209") ?? fallback // Orange
            case .function:
                return colorFromHex("#6f42c1") ?? fallback // Purple (like entity)
            case .number:
                return colorFromHex("#005cc5") ?? fallback // Blue (like constant)
            case .support:
                return colorFromHex("#005cc5") ?? fallback // Blue
            default:
                return fallback
            }
        }
        
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
                    attributedString.addAttribute(.foregroundColor, value: getColor(for: .number, fallback: NSColor.systemOrange), range: lineRange)
                } else if line.hasPrefix("+++") || line.hasPrefix("---") {
                    attributedString.addAttribute(.foregroundColor, value: getColor(for: .function, fallback: NSColor.systemBlue), range: lineRange)
                } else if line.hasPrefix("+") {
                    attributedString.addAttribute(.foregroundColor, value: getColor(for: .string, fallback: NSColor.systemGreen), range: lineRange)
                } else if line.hasPrefix("-") {
                    attributedString.addAttribute(.foregroundColor, value: getColor(for: .keyword, fallback: NSColor.systemRed), range: lineRange)
                } else if line.hasPrefix("diff ") || line.hasPrefix("index ") {
                    attributedString.addAttribute(.foregroundColor, value: getColor(for: .comment, fallback: NSColor.systemGray), range: lineRange)
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
                    attributedString.addAttribute(.foregroundColor, value: getColor(for: .comment, fallback: NSColor.systemGray), range: match.range)
                }
            }

            // Tag names
            if let tagNameRegex = try? NSRegularExpression(pattern: "</?([a-zA-Z][a-zA-Z0-9:-]*)\\b", options: []) {
                tagNameRegex.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
                    guard let match else { return }
                    let nameRange = match.range(at: 1)
                    attributedString.addAttribute(.foregroundColor, value: getColor(for: .keyword, fallback: NSColor.systemPurple), range: nameRange)
                }
            }

            // Attributes name=value
            if let attrRegex = try? NSRegularExpression(pattern: "([a-zA-Z_:][-a-zA-Z0-9_:.]*)\\s*=\\s*(\"[^\\\"]*\"|'[^']*')", options: []) {
                attrRegex.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
                    guard let match else { return }
                    let nameRange = match.range(at: 1)
                    let valueRange = match.range(at: 2)
                    attributedString.addAttribute(.foregroundColor, value: getColor(for: .function, fallback: NSColor.systemBlue), range: nameRange)
                    attributedString.addAttribute(.foregroundColor, value: getColor(for: .string, fallback: NSColor.systemGreen), range: valueRange)
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
                    attributedString.addAttribute(.foregroundColor, value: getColor(for: .comment, fallback: NSColor.systemGray), range: match.range)
                }
            }

            // Strings
            if let cssString = try? NSRegularExpression(pattern: "([\\\"'])(?:[^\\\\\\1]|\\\\.)*?\\1", options: []) {
                cssString.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
                    guard let match else { return }
                    attributedString.addAttribute(.foregroundColor, value: getColor(for: .string, fallback: NSColor.systemGreen), range: match.range)
                }
            }

            // @rules
            if let atRule = try? NSRegularExpression(pattern: "^\\s*@\\w+", options: .anchorsMatchLines) {
                atRule.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
                    guard let match else { return }
                    attributedString.addAttribute(.foregroundColor, value: getColor(for: .keyword, fallback: NSColor.systemPurple), range: match.range)
                }
            }

            // Property names before colon
            if let propName = try? NSRegularExpression(pattern: "^\\s*([A-Za-z_-][A-Za-z0-9_-]*)\\s*:", options: .anchorsMatchLines) {
                propName.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
                    guard let match else { return }
                    let nameRange = match.range(at: 1)
                    attributedString.addAttribute(.foregroundColor, value: getColor(for: .function, fallback: NSColor.systemBlue), range: nameRange)
                }
            }

            // Hex colors
            if let hex = try? NSRegularExpression(pattern: "#[0-9a-fA-F]{3,8}\\b", options: []) {
                hex.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
                    guard let match else { return }
                    attributedString.addAttribute(.foregroundColor, value: getColor(for: .constant, fallback: NSColor.systemTeal), range: match.range)
                }
            }

            // Selectors tokens: .class, #id, :pseudo, ::pseudo
            if let selectorToken = try? NSRegularExpression(pattern: "(\\.[-\\w]+|#[-\\w]+|::?[-\\w]+)", options: []) {
                selectorToken.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
                    guard let match else { return }
                    attributedString.addAttribute(.foregroundColor, value: getColor(for: .type, fallback: NSColor.systemPurple), range: match.range)
                }
            }

            // Numbers with units
            if let numUnit = try? NSRegularExpression(pattern: "\\b\\d+(?:\\.\\d+)?(?:px|em|rem|vh|vw|%|s|ms)?\\b", options: []) {
                numUnit.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
                    guard let match else { return }
                    attributedString.addAttribute(.foregroundColor, value: getColor(for: .number, fallback: NSColor.systemOrange), range: match.range)
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
                    attributedString.addAttribute(.foregroundColor, value: getColor(for: .comment, fallback: NSColor.systemGray), range: match.range)
                }
            }

            // Strings
            if let stringRegex = try? NSRegularExpression(pattern: "([\\\"'])(?:[^\\\\\\1]|\\\\.)*?\\1", options: []) {
                stringRegex.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
                    guard let match else { return }
                    attributedString.addAttribute(.foregroundColor, value: getColor(for: .string, fallback: NSColor.systemGreen), range: match.range)
                }
            }

            // Numbers
            if let numberRegex = try? NSRegularExpression(pattern: "-?\\b\\d+(?:\\.\\d+)?\\b", options: []) {
                numberRegex.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
                    guard let match else { return }
                    attributedString.addAttribute(.foregroundColor, value: getColor(for: .number, fallback: NSColor.systemOrange), range: match.range)
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
                    attributedString.addAttribute(.foregroundColor, value: getColor(for: .keyword, fallback: NSColor.systemPurple), range: match.range)
                }
            }

            // Anchors and aliases &name or *name
            if let anchorRegex = try? NSRegularExpression(pattern: "[&*][A-Za-z0-9_-]+", options: []) {
                anchorRegex.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
                    guard let match else { return }
                    attributedString.addAttribute(.foregroundColor, value: getColor(for: .type, fallback: NSColor.systemTeal), range: match.range)
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
                    attributedString.addAttribute(.foregroundColor, value: getColor(for: .comment, fallback: NSColor.systemGray), range: match.range)
                }
            }
        }
        
        // 2. Strings (green)
        if let stringRegex = try? NSRegularExpression(pattern: langDef.stringPattern, options: []) {
            stringRegex.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
                guard let match = match else { return }
                attributedString.addAttribute(.foregroundColor, value: getColor(for: .string, fallback: NSColor.systemGreen), range: match.range)
            }
        }
        
        // 3. Numbers (orange)
        if let numberRegex = try? NSRegularExpression(pattern: langDef.numberPattern, options: []) {
            numberRegex.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
                guard let match = match else { return }
                attributedString.addAttribute(.foregroundColor, value: getColor(for: .number, fallback: NSColor.systemOrange), range: match.range)
            }
        }
        
        // 4. Variables (blue) - for languages that have them
        if let variablePattern = langDef.variablePattern,
           let variableRegex = try? NSRegularExpression(pattern: variablePattern, options: []) {
            variableRegex.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
                guard let match = match else { return }
                attributedString.addAttribute(.foregroundColor, value: getColor(for: .variable, fallback: NSColor.systemBlue), range: match.range)
            }
        }
        
        // 5. Storage keywords (class, public, private, static, etc.) - should be red like keywords
        let storageKeywords = ["class", "public", "private", "protected", "static", "final", "abstract", "interface", "struct", "enum", "var", "let", "const", "function", "func", "def", "import", "package", "namespace"]
        let languageStorageKeywords = storageKeywords.filter { langDef.keywords.contains($0) }
        if !languageStorageKeywords.isEmpty {
            let joinedStorageKeywords = languageStorageKeywords
                .map { NSRegularExpression.escapedPattern(for: $0) }
                .joined(separator: "|")
            if let storageRegex = try? NSRegularExpression(pattern: "\\b(?:\(joinedStorageKeywords))\\b", options: []) {
                storageRegex.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
                    guard let match = match else { return }
                    attributedString.addAttribute(.foregroundColor, value: getColor(for: .storage, fallback: NSColor.systemRed), range: match.range)
                }
            }
        }
        
        // 6. Other keywords (purple) – single combined regex for reliability
        if !langDef.keywords.isEmpty {
            let regularKeywords = langDef.keywords.filter { !storageKeywords.contains($0) }
            if !regularKeywords.isEmpty {
                let joinedKeywords = regularKeywords
                    .map { NSRegularExpression.escapedPattern(for: $0) }
                    .joined(separator: "|")
                if let keywordsRegex = try? NSRegularExpression(pattern: "\\b(?:\(joinedKeywords))\\b", options: []) {
                    keywordsRegex.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
                        guard let match = match else { return }
                        attributedString.addAttribute(.foregroundColor, value: getColor(for: .keyword, fallback: NSColor.systemPurple), range: match.range)
                    }
                }
            }
        }
        
        // 7. Types (cyan/teal) - built-in types
        if let types = langDef.types, !types.isEmpty {
            let joinedTypes = types
                .map { NSRegularExpression.escapedPattern(for: $0) }
                .joined(separator: "|")
            if let typeRegex = try? NSRegularExpression(pattern: "\\b(?:\(joinedTypes))\\b", options: []) {
                typeRegex.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
                    guard let match = match else { return }
                    attributedString.addAttribute(.foregroundColor, value: getColor(for: .support, fallback: NSColor.systemTeal), range: match.range)
                }
            }
        }
        // 8. Class and interface names (should use entity color - purple #6f42c1)
        // Highlight class names in class declarations: "class ClassName"
        if let classRegex = try? NSRegularExpression(pattern: "\\b(?:class|interface|struct|enum)\\s+([A-Z][A-Za-z0-9_]*)", options: []) {
            classRegex.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
                guard let match else { return }
                let nameRange = match.range(at: 1)
                attributedString.addAttribute(.foregroundColor, value: getColor(for: .entity, fallback: NSColor.systemPurple), range: nameRange)
            }
        }
        
        // Highlight interface/class names after implements/extends: "implements InterfaceName"
        if let implementsRegex = try? NSRegularExpression(pattern: "\\b(?:implements|extends)\\s+([A-Z][A-Za-z0-9_]*)", options: []) {
            implementsRegex.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
                guard let match else { return }
                let nameRange = match.range(at: 1)
                attributedString.addAttribute(.foregroundColor, value: getColor(for: .entity, fallback: NSColor.systemPurple), range: nameRange)
            }
        }
        
        // Highlight constructor names (same as class name in constructor calls): "new ClassName("
        if let constructorRegex = try? NSRegularExpression(pattern: "\\bnew\\s+([A-Z][A-Za-z0-9_]*)\\s*\\(", options: []) {
            constructorRegex.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
                guard let match else { return }
                let nameRange = match.range(at: 1)
                attributedString.addAttribute(.foregroundColor, value: getColor(for: .entity, fallback: NSColor.systemPurple), range: nameRange)
            }
        }
        
        // Highlight type names in variable declarations: "TypeName variableName"
        // This pattern looks for capitalized words followed by lowercase identifiers
        if let typeAnnotationRegex = try? NSRegularExpression(pattern: "\\b([A-Z][A-Za-z0-9_]*)\\s+([a-z_][A-Za-z0-9_]*)\\s*[;=,)]", options: []) {
            typeAnnotationRegex.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
                guard let match else { return }
                let typeRange = match.range(at: 1)
                let typeName = nsText.substring(with: typeRange)
                // Skip if it's a keyword or already a known type
                if !langDef.keywords.contains(typeName) && !(langDef.types?.contains(typeName) ?? false) {
                    attributedString.addAttribute(.foregroundColor, value: getColor(for: .entity, fallback: NSColor.systemPurple), range: typeRange)
                }
            }
        }
        
        // 9. Function and method calls
        // Highlight standalone function calls: name(...), skipping keywords
        if let funcRegex = try? NSRegularExpression(pattern: "(?<!\\.)\\b([A-Za-z_][A-Za-z0-9_]*)\\b(?=\\s*\\()", options: []) {
            funcRegex.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
                guard let match else { return }
                let nameRange = match.range(at: 1)
                let token = nsText.substring(with: nameRange)
                if langDef.keywords.contains(token) { return }
                attributedString.addAttribute(.foregroundColor, value: getColor(for: .function, fallback: NSColor.systemBlue), range: nameRange)
            }
        }
        // Highlight method calls after dot: .name(...)
        if let methodRegex = try? NSRegularExpression(pattern: "(?<=\\.)\\b([A-Za-z_][A-Za-z0-9_]*)\\b(?=\\s*\\()", options: []) {
            methodRegex.enumerateMatches(in: text, options: [], range: range) { match, _, _ in
                guard let match else { return }
                let nameRange = match.range(at: 1)
                attributedString.addAttribute(.foregroundColor, value: getColor(for: .function, fallback: NSColor.systemBlue), range: nameRange)
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
