import SwiftUI

struct ShotListView: View {
    let club: Club
    @Binding var clubs: [Club]
    var showDetail: (Shot) -> Void

    var body: some View {
        NavigationView {
            List(club.shots, id: \.self) { shot in
                Button(action: {
                    showDetail(shot)
                }) {
                    VStack(alignment: .leading) {
                        Text("📏 \(Int(shot.distance)) meters")
                            .font(.headline)
                        Text("📅 \(shot.date)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle(club.name + " Shots")
        }
    }
}
