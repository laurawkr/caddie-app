import SwiftUI

struct ShotDetailView: View {
    let club: Club

    var body: some View {
        List(club.shots, id: \.date) { shot in
            VStack(alignment: .leading) {
                Text("📅 \(shot.date)")
                Text("📏 \(Int(shot.distance)) meters")
            }
        }
        .navigationTitle(club.name)
    }
}
