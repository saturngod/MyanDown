//
//  MyanDownApp.swift
//  MyanDown
//
//  Created by Bonjoy on 8/27/25.
//

import SwiftUI

@main
struct MyanDownApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: MarkdownFileDocument()) { file in
            ContentViewDocument(text: file.$document.text)
        }
    }
}
