//
//  ImagePicker.swift
//  Quote
//
//  Created by Daniel Madjar on 1/3/23.
//

import SwiftUI
import PhotosUI

@MainActor
class ImagePicker: ObservableObject {
    @Published var imageSelection: PhotosPickerItem? {
        didSet {
            Task {
                try await loadTransferable(from: imageSelection)
            }
        }
    }
    
    @Published var image: Image?
    @Published var uiImage: UIImage?
    
    func loadTransferable(from imageSelection: PhotosPickerItem?) async throws {
        do {
            if let data = try await imageSelection?.loadTransferable(type: Data.self) {
                if let uiImage = UIImage(data: data) {
                    self.uiImage = uiImage
                    self.image = Image(uiImage: uiImage)
                    print("Gets Here") //check
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
