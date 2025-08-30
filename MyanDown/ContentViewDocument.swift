import SwiftUI

struct ContentViewDocument: View {
    @Binding var text: String
    
    var body: some View {
        MyanDownTextEditor(text: $text, configuration: .standard)
    }
}


#Preview {
    @Previewable @State var demo = "#Title"
    ContentViewDocument(text: $demo)
}



