//
//  QuoteApp.swift
//  Quote
//
//  Created by Daniel Madjar on 1/1/23.
//

import SwiftUI

@main
struct QuoteApp: App {
    @StateObject private var dataController = DataController()
    
    var body: some Scene {
        WindowGroup {
            MainBookView(viewModel: ImageViewModel(UIImage(systemName: "photo")!))
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .onAppear {
                                    print(URL.documentsDirectory.path)
                                }
        }
    }
}
