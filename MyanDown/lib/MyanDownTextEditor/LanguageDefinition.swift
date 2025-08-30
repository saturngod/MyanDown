//
//  LanguageDefinition.swift
//  MyanDown
//
//  Created by Bonjoy on 8/29/25.
//

import Foundation

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