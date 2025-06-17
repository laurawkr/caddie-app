import SwiftUI

struct AddClubView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var clubs: [Club]

    @State private var name = ""

    var body: some View {
        NavigationView {
            Form {
                TextField("Club Name", text: $name)
            }
            .navigationTitle("Add Club")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if !name.isEmpty {
                            let newClub = Club(name: name)
                            clubs.append(newClub)
                            dismiss()
                        }
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

