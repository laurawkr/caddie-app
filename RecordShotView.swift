import SwiftUI
import CoreLocation

struct RecordShotView: View {
    @Binding var clubs: [Club]
    var selectedClubIndex: Int

    @Environment(\.dismiss) var dismiss
    @State private var manualDistance: String = ""
    @StateObject private var locationManager = LocationManager()
    @State private var startPin: CLLocationCoordinate2D?
    @State private var endPin: CLLocationCoordinate2D?
    @State private var shotDistance: Double?

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Recording for: \(clubs[selectedClubIndex].name)")
                    .font(.headline)

                TextField("Manual Distance (meters)", text: $manualDistance)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)

                Button("Drop Start Pin") {
                    if let coord = locationManager.currentLocation {
                        startPin = coord
                        print("Start Pin: \(coord.latitude), \(coord.longitude)")
                    } else {
                        print("Location not available yet.")
                    }
                }

                Button("Drop End Pin") {
                    if let coord = locationManager.currentLocation, let start = startPin {
                        endPin = coord
                        let distance = CLLocation(latitude: start.latitude, longitude: start.longitude)
                            .distance(from: CLLocation(latitude: coord.latitude, longitude: coord.longitude))
                        shotDistance = distance
                        print("End Pin: \(coord.latitude), \(coord.longitude)")
                        print("Distance: \(distance)")
                    }
                }

                HStack {
                    Button("Save") {
                        var updatedClub = clubs[selectedClubIndex]
                        let distance = shotDistance ?? Double(manualDistance) ?? 0
                        if distance > 0 {
                            let shot = Shot(
                                distance: distance,
                                date: DateFormatter.localizedString(
                                    from: Date(),
                                    dateStyle: .short,
                                    timeStyle: .short
                                )
                            )
                            updatedClub.shots.append(shot)
                            clubs[selectedClubIndex] = updatedClub
                        }
                        dismiss()
                    }

                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.red)
                }

                if let distance = shotDistance {
                    Text("Shot Distance: \(Int(distance)) meters")
                        .font(.headline)
                }
            }
            .padding()
            .navigationTitle("Record Shot")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}

