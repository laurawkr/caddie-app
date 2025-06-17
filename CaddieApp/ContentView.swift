import SwiftUI
import CoreLocation

struct Shot: Codable, Hashable {
    let distance: Double
    let date: String
    let course: String
    let hole: Int
    let shotNumber: Int
    let startLatitude: Double?
    let startLongitude: Double?
}

struct Club: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var shots: [Shot] = []

    var averageYardage: Int {
        guard !shots.isEmpty else { return 0 }
        let total = shots.reduce(0) { $0 + $1.distance }
        return Int(total / Double(shots.count))
    }
}

enum ActiveSheet: Identifiable {
    case addClub, recordShot, shotList(Club), shotDetail(Shot, Club)

    var id: String {
        switch self {
        case .addClub: return "addClub"
        case .recordShot: return "recordShot"
        case .shotList(let club): return "shotList-\(club.id)"
        case .shotDetail(let shot, let club): return "shotDetail-\(shot.date)-\(club.id)"
        }
    }
}

struct ContentView: View {
    @AppStorage("savedClubs") private var savedClubsData = Data()
    @AppStorage("savedCourses") private var savedCoursesData = Data()
    @State private var clubs: [Club] = []
    @State private var savedCourses: [String] = []
    @State private var activeSheet: ActiveSheet?

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.05, green: 0.25, blue: 0.1)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 30) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("My Insights")
                                .font(.largeTitle.bold())
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            Text("(Coming Soon)")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.6))
                                .padding(.horizontal)
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("My Bag")
                                    .font(.title2.bold())
                                    .foregroundColor(.white)
                                Spacer()
                                Button(action: { activeSheet = .addClub }) {
                                    Image(systemName: "plus")
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(.horizontal)

                            ForEach(clubs) { club in
                                Button {
                                    activeSheet = .shotList(club)
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(club.name)
                                                .font(.headline)
                                                .foregroundColor(.white)
                                            Text("\(club.averageYardage) yards avg")
                                                .font(.subheadline)
                                                .foregroundColor(.white.opacity(0.8))
                                        }
                                        Spacer()
                                        Text("\(club.shots.count) shots")
                                            .foregroundColor(.white.opacity(0.6))
                                            .font(.caption)
                                    }
                                    .padding()
                                    .background(Color(red: 0.15, green: 0.4, blue: 0.2))
                                    .cornerRadius(8)
                                    .padding(.horizontal)
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Saved Courses")
                                .font(.title2.bold())
                                .foregroundColor(.white)
                                .padding(.horizontal)

                            ForEach(savedCourses, id: \.self) { course in
                                Text(course)
                                    .padding(.horizontal)
                                    .padding(.vertical, 4)
                                    .foregroundColor(.white)
                            }
                        }

                        Button("Record a Shot") {
                            activeSheet = .recordShot
                        }
                        .font(.headline)
                        .foregroundColor(.green)
                        .padding()
                        .frame(maxWidth: .infinity)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("")
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .addClub:
                    AddClubView(clubs: $clubs)
                case .recordShot:
                    RecordShotView(clubs: $clubs)
                case .shotList(let club):
                    ShotListView(club: club, clubs: $clubs, showDetail: { shot in
                        activeSheet = .shotDetail(shot, club)
                    })
                case .shotDetail(let shot, let club):
                    ShotDetailView(shot: shot, club: club, clubs: $clubs)
                }
            }
            .onAppear {
                loadClubs()
                loadCourses()
            }
            .onChange(of: clubs) { _ in
                saveClubs()
            }
        }
    }

    func loadClubs() {
        if let decoded = try? JSONDecoder().decode([Club].self, from: savedClubsData) {
            clubs = decoded
        }
    }

    func saveClubs() {
        if let encoded = try? JSONEncoder().encode(clubs) {
            savedClubsData = encoded
        }
    }

    func loadCourses() {
        if let decoded = try? JSONDecoder().decode([String].self, from: savedCoursesData) {
            savedCourses = decoded
        }
    }
}




