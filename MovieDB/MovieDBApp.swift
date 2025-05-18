//  Created by Aji Prakosa on 18/5/25.

import SwiftUI

@main
struct MovieDBApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MovieListView()
        }
    }
}
