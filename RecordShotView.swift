import SwiftUI
import CoreLocation

struct RecordShotView: View {
    @Binding var clubs: [Club]
    @Environment(\.dismiss) var dismiss

    @AppStorage("savedCourses") private var savedCoursesData = Data()
    @State private var savedCourses: [String] = []
    @State private var selectedCourse: String = ""
    @State private var newCourseName: String = ""

    @State private var isFrontNine = true
    @State private var holeNumber = 1
    @State private var shotNumber: Int = 1

    @State private var manualDistance: String = ""
    @State private var distanceInputMode: String? = nil
    @State private var internalSelectedClubIndex: Int = 0
    @StateObject private var locationManager = LocationManager()
    @State private var startPin: CLLocationCoordinate2D?
    @State private var endPin: CLLocationCoordinate2D?
    @State private var shotDistance: Double?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Distance input mode
                    HStack {
                        Button("Manual") {
                            distanceInputMode = "manual"
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(distanceInputMode == "manual" ? Color.blue : Color.gray.opacity(0.2))
                        .foregroundColor(.white)
                        .cornerRadius(8)

                        Button("GPS") {
                            distanceInputMode = "gps"
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(distanceInputMode == "gps" ? Color.blue : Color.gray.opacity(0.2))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }

                    if distanceInputMode == "manual" {
                        TextField("Enter Distance (yards)", text: $manualDistance)
                            .keyboardType(.numberPad)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }

                    if distanceInputMode == "gps" {
                        HStack {
                            Button(action: {
                                if let coord = locationManager.currentLocation {
                                    startPin = coord
                                }
                            }) {
                                Text(startPin != nil ? "Pinned" : "Drop Start Pin")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(startPin != nil ? Color.green : Color.gray.opacity(0.2))
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }

                            Button(action: {
                                if let coord = locationManager.currentLocation, let start = startPin {
                                    endPin = coord
                                    let distance = CLLocation(latitude: start.latitude, longitude: start.longitude)
                                        .distance(from: CLLocation(latitude: coord.latitude, longitude: coord.longitude))
                                    shotDistance = distance
                                }
                            }) {
                                Text(endPin != nil ? "Pinned" : "Drop End Pin")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(endPin != nil ? Color.red : Color.gray.opacity(0.2))
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                    }

                    if let distance = shotDistance {
                        Text("Shot Distance: \(Int(distance)) yards")
                            .font(.headline)
                    }

                    // Club Picker
                    Picker("Select Club", selection: $internalSelectedClubIndex) {
                        ForEach(0..<clubs.count, id: \.self) { index in
                            Text(clubs[index].name).tag(index)
                        }
                    }
                    .pickerStyle(.wheel)

                    Text("Recording for: \(clubs[internalSelectedClubIndex].name)")
                        .font(.headline)

                    // Golf course picker
                    Picker("Select Course", selection: $selectedCourse) {
                        ForEach(savedCourses, id: \.self) { course in
                            Text(course)
                        }
                    }
                    .pickerStyle(.menu)

                    HStack {
                        TextField("Add New Course", text: $newCourseName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                        Button("Add") {
                            guard !newCourseName.isEmpty else { return }
                            savedCourses.append(newCourseName)
                            selectedCourse = newCourseName
                            newCourseName = ""
                            saveCourses()
                        }
                    }

                    // Hole Picker
                    VStack {
                        Picker("Nine", selection: $isFrontNine) {
                            Text("Front 9").tag(true)
                            Text("Back 9").tag(false)
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)

                        let holes = isFrontNine ? Array(1...9) : Array(10...18)
                        let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(holes, id: \.self) { hole in
                                Button(action: {
                                    holeNumber = hole
                                }) {
                                    Text("\(hole)")
                                        .frame(maxWidth: .infinity, minHeight: 44)
                                        .background(holeNumber == hole ? Color.blue : Color.gray.opacity(0.2))
                                        .foregroundColor(holeNumber == hole ? .white : .black)
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    Stepper("Shot #\(shotNumber)", value: $shotNumber, in: 1...10)

                    HStack {
                        Button("Save") {
                            let distance = shotDistance ?? Double(manualDistance) ?? 0
                            if distance > 0 && !selectedCourse.isEmpty {
                                let shot = Shot(
                                    distance: distance,
                                    date: DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short),
                                    course: selectedCourse,
                                    hole: holeNumber,
                                    shotNumber: shotNumber,
                                    startLatitude: startPin?.latitude,
                                    startLongitude: startPin?.longitude
                                )
                                clubs[internalSelectedClubIndex].shots.append(shot)
                            }
                            dismiss()
                        }
                        Button("Cancel") {
                            dismiss()
                        }
                        .foregroundColor(.red)
                    }
                }
                .padding()
            }
            .navigationTitle("Record Shot")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .onAppear(perform: loadCourses)
        }
    }

    private func loadCourses() {
        if let decoded = try? JSONDecoder().decode([String].self, from: savedCoursesData) {
            savedCourses = decoded
        }
    }

    private func saveCourses() {
        if let encoded = try? JSONEncoder().encode(savedCourses) {
            savedCoursesData = encoded
        }
    }
}


