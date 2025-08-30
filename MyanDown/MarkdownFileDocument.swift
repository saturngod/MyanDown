import SwiftUI
import UniformTypeIdentifiers

struct MarkdownFileDocument: FileDocument {
    static var readableContentTypes: [UTType] { [mdType] }
    static var writableContentTypes: [UTType] { [mdType] }

    static var mdType: UTType {
        if let ext = UTType(filenameExtension: "md") {
            return ext
        }
        if let id = UTType("net.daringfireball.markdown") {
            return id
        }
        return .plainText
    }

    var text: String

    init(text: String = "") {
        self.text = text
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let string = String(data: data, encoding: .utf8) else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.text = string
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = text.data(using: .utf8) ?? Data()
        return .init(regularFileWithContents: data)
    }
}


