import SwiftUI
import CoreLocation

struct Shot: Codable, Hashable {
    let distance: Double
    let date: String
}

struct Club: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var yardage: Int
    var shots: [Shot] = []
}

struct ContentView: View {
    @AppStorage("savedClubs") private var savedClubsData = Data()
    @State private var clubs: [Club] = []
    @State private var showingAddClub = false
    @State private var showingRecordShot = false
    @State private var showingShotList = false
    @State private var selectedClubIndex: Int?

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(clubs.indices, id: \.self) { index in
                        Button {
                            selectedClubIndex = index
                            showingShotList = true
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(clubs[index].name)
                                        .font(.headline)
                                    Text("\(clubs[index].yardage) yards")
                                        .font(.subheadline)
                                }
                                Spacer()
                                Text("\(clubs[index].shots.count) shots")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                        }
                    }
                }

                Button("Record a Shot") {
                    selectedClubIndex = 0
                    showingRecordShot = true
                }
                .padding()
            }
            .navigationTitle("My Bag")
            .navigationBarItems(trailing:
                Button(action: { showingAddClub = true }) {
                    Image(systemName: "plus")
                }
            )
            .sheet(isPresented: $showingAddClub) {
                AddClubView(clubs: $clubs)
            }
            .sheet(isPresented: $showingRecordShot) {
                if let index = selectedClubIndex {
                    RecordShotView(clubs: $clubs, selectedClubIndex: index)
                }
            }
            .sheet(isPresented: $showingShotList) {
                if let index = selectedClubIndex {
                    ShotListView(club: clubs[index])
                }
            }
        }
        .onAppear(perform: loadClubs)
        .onChange(of: clubs) {
            saveClubs()
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
}

