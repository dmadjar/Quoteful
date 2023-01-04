//
//  BookDetailView.swift
//  Quote
//
//  Created by Daniel Madjar on 1/4/23.
//

import SwiftUI
import PhotosUI

struct BookDetailView: View {
    @Environment(\.managedObjectContext) var moc
    
    @StateObject private var imagePicker = ImagePicker()
    
    @State var quote : String = ""
    @State var isPresented : Bool = false
    
    var quoteArray: [QuoteEntity]
    var viewModel : ImageViewModel
   
    let name: String
    let book: BookEntity
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                    .frame(width: width * 0.10)
                
                PhotosPicker(selection: $imagePicker.imageSelection, matching: .images, photoLibrary: .shared()) {
                    Image(uiImage: book.uiImage)
                        .resizable()
                        .cornerRadius(10)
                        .frame(width: width * 0.3, height: height * 0.20)
                        .padding([.top, .bottom], 10)
                }
                .onChange(of: imagePicker.uiImage) { _ in
                    FileManager().deleteImage(with: book.coverPhotoWrapped)
                    
                    book.coverPhoto = UUID().uuidString
                
                    viewModel.uiImage = imagePicker.uiImage ?? UIImage(systemName: "photo")!
                
                    try? moc.save()
                    
                    FileManager().saveImage(with: book.coverPhotoWrapped, image: viewModel.uiImage)
                }
                
                Spacer()
                    .frame(width: width * 0.10)
                
                VStack {
                    Text(name)
                        .foregroundColor(Color.red)
                    
                    //ADD rating
                }
                
                Spacer()
            }

            Spacer()
                .frame(height: height * 0.05)
            
            Text("Quotes")
                .frame(width: width * 0.9, alignment: .leading)
            
            Spacer()
                .frame(height: height * 0.05)
            
            ForEach(quoteArray, id: \.self) { quote in
                Text(quote.wrappedString)
                    .foregroundColor(Color.black)
                    .frame(width: width * 0.9, height: height * 0.025, alignment: .leading)
                
                Spacer()
                    .frame(width: width * 0.9, height: height * 0.025)
            }

            Spacer()
            
            Button("Add Quote") {
                isPresented.toggle()
            }
        }
        .sheet(isPresented: $isPresented) {
            SheetDetailViewInside(quote: $quote, isPresented: $isPresented, book: book)
                        .presentationDetents([.medium])
        }
    }
}

