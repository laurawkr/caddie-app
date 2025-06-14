import SwiftUI

struct AddClubView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var clubs: [Club]

    @State private var name = ""
    @State private var yardage = ""

    var body: some View {
        NavigationView {
            Form {
                TextField("Club Name", text: $name)
                TextField("Yardage", text: $yardage)
                    .keyboardType(.numberPad)
            }
            .navigationTitle("Add Club")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let yd = Int(yardage), !name.isEmpty {
                            let newClub = Club(name: name, yardage: yd)
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

