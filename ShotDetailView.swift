import SwiftUI

struct ShotDetailView: View {
    let shot: Shot
    let club: Club
    @Binding var clubs: [Club]
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 16) {
            Text(club.name)
                .font(.largeTitle)

            Text("📅 \(shot.date)")
            Text("📏 \(Int(shot.distance)) meters")
            Text("📍 Course: \(shot.course)")
            Text("🕳️ Hole: \(shot.hole)")
            Text("🎯 Shot #: \(shot.shotNumber)")

            Button(role: .destructive) {
                if let clubIndex = clubs.firstIndex(where: { $0.id == club.id }) {
                    clubs[clubIndex].shots.removeAll { $0 == shot }
                }
                dismiss()
            } label: {
                Text("Delete Shot")
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.red)
                    .cornerRadius(8)
            }
        }
        .padding()
        .navigationTitle("Shot Detail")
    }
}

