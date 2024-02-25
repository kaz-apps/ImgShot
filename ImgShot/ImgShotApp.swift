//
//  ImgShotApp.swift
//  ImgShot
//
//  Created by yabushita on 2024/02/26.
//

import SwiftUI

@main
struct ImgShotApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
