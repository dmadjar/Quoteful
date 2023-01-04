//
//  ContentView.swift
//  Quote
//
//  Created by Daniel Madjar on 1/1/23.
//

import SwiftUI
import PhotosUI
import UIKit

let width = UIScreen.main.bounds.width
let height = UIScreen.main.bounds.height
let backgroundColor = Color("BackgroundColor")

class ImageViewModel: ObservableObject {
    @Published var uiImage: UIImage
    var id: String?
    
    init(_ uiImage: UIImage) {
        self.uiImage = uiImage
    }
    
    init(_ myImage: BookEntity) {
        id = myImage.coverPhotoWrapped
        uiImage = UIImage(systemName: "photo")!
    }
}

struct MainBookView: View {
    @FetchRequest(sortDescriptors: []) var books: FetchedResults<BookEntity>
    @Environment(\.managedObjectContext) var moc
    
    @ObservedObject var viewModel: ImageViewModel
    
    @State var isPresented : Bool = false
    @State var bookName : String = ""
    @State var editMode : Bool = false
    @State var editText : String = "Edit"
    
    @State var wiggleAnimation : Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("BackgroundColor").ignoresSafeArea()
                    
                VStack {
                    HStack {
                        Text("My Books")
                            .bold()
                            .font(Font.custom("AmericanTypewriter", size: 25))
                        
                        Spacer()
                        
                        Button {
                            editMode.toggle()
                            
                            if editMode {
                                editText = "Done"
                                wiggleAnimation = true
                            } else {
                                editText = "Edit"
                                wiggleAnimation = false
                            }
                            
                        } label : {
                            Text(editText)
                                .foregroundColor(.blue)
                        }
                    }
                    .frame(width: width * 0.85, alignment: .leading)
                    
                    ScrollView {
                        ForEach(Array(books.enumerated()), id: \.offset) { index, book in
                            NavigationLink(destination: BookDetailView(quoteArray: book.quoteArray, viewModel: viewModel, name: book.wrappedBookName, book: book)) {
                                
                                ZStack {
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color.black)
                                        .frame(width: width * 0.80, height: height * 0.25)
                                        .offset(x: 25, y: 17.5)
                                    
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color("RoundedRectColor"))
                                        .frame(width: width * 0.85, height: height * 0.25)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 15)
                                                .stroke(Color.black, lineWidth: 3)
                                                .frame(width: width * 0.85, height: height * 0.25)
                                        )
                                    
                                    HStack {
                                        if isEven(number: index) {
                                            Text(book.wrappedBookName)
                                                .foregroundColor(.black)
                                                .font(Font.custom("AmericanTypewriter", size: 32))
                                            
                                            Spacer()
                                                .frame(width: width * 0.1)
                                            
                                            Image(uiImage: book.uiImage)
                                                .resizable()
                                                .cornerRadius(10)
                                                .frame(width: width * 0.3, height: height * 0.20)
                                                .padding([.top, .bottom], 10)
                                                
                                        } else {
                                            Image(uiImage: book.uiImage)
                                                .resizable()
                                                .cornerRadius(10)
                                                .frame(width: width * 0.3, height: height * 0.20)
                                                .padding([.top, .bottom], 10)
                                            
                                            Spacer()
                                            
                                            Text(book.wrappedBookName)
                                                .foregroundColor(.black)
                                                .font(.system(size: 30))
                                        }
                                       
                                    }
                                    .frame(width: width * 0.75, alignment: .leading)
                                }
                                .modifier(WiggleAnimation(shouldWiggle: $wiggleAnimation))
                                .overlay(
                                    DeleteButton(books: books, index: index, editMode: editMode)
                                )

                            }
                            .padding()
                        }
                    }
                    
                    
                    Button("Add Book") {
                        isPresented.toggle()
                        bookName = ""
                    }
                }
            }
        }
        .sheet(isPresented: $isPresented) {
            SheetDetailViewOutside(bookName: $bookName, isPresented: $isPresented, viewModel: viewModel)
                .presentationDetents([.medium])
        }
    }

    func isEven(number: Int) -> Bool {
        return number % 2 == 0
    }
    
    func removeBook(at offsets: IndexSet) {
        for index in offsets {
            let book = books[index]
            moc.delete(book)
        }
    }
}

struct WiggleAnimation: ViewModifier {
    @Binding var shouldWiggle: Bool
    
    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(shouldWiggle ? 2.5 : 0))
            .animation(shouldWiggle ? Animation.easeInOut(duration: 0.15).repeatForever(autoreverses: true) : Animation.default, value: shouldWiggle)
    }
}


struct SheetDetailViewOutside: View {
    @Environment(\.managedObjectContext) var moc
    @Binding var bookName: String
    @Binding var isPresented: Bool
    
    var viewModel : ImageViewModel
    @StateObject private var imagePicker = ImagePicker()
    
    @State private var pages = 0
    @State var showImagePicker : Bool = false
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack {
                HStack {
                    Spacer()
                    
                    Text("\(bookName.count) / 50")
                        .foregroundColor(bookName.count == 0 ? .red : .black)
                        .font(.system(size: 15))
                }
                .frame(width: width * 0.9)
                
                TextField("Name", text: $bookName)
                    .textFieldStyle(OutlinedTextFieldStyle(icon: Image(systemName: "books.vertical")))
                    .frame(width: width * 0.9)
                
                Spacer()
                    .frame(height: height * 0.05)
                
                HStack {
                    Image(systemName: "book")
                        .renderingMode(.template)
                        .foregroundColor(.black)
                    
                    Text("Pages:")
                        .bold()
                        .foregroundColor(.black)
                    
                    Spacer()
                        .frame(width: width * 0.10)
                    
                    TextField("", value: $pages, format: .number)
                        .textFieldStyle(OutlinedTextFieldStyle(icon: Image(systemName: "")))
                        .frame(width: width * 0.15, height: height * 0.05)
                        .keyboardType(.decimalPad)
                    
                    Spacer()
                        .frame(width: width * 0.10)
                    
                    PhotosPicker("Add Cover", selection: $imagePicker.imageSelection, matching: .images, photoLibrary: .shared())
                }
                .frame(width: width * 0.9, alignment: .leading)
            }
            
            Spacer()
            
            Spacer()
            
            Button {
                let bookEntity = BookEntity(context: moc)
                bookEntity.coverPhoto = UUID().uuidString // for coverPhoto
                bookEntity.bookName = bookName
                
                viewModel.uiImage = imagePicker.uiImage ?? UIImage(systemName: "photo")!
                
                withAnimation {
                    try? moc.save()
                }
                
                FileManager().saveImage(with: bookEntity.coverPhotoWrapped, image: viewModel.uiImage)
                
                isPresented.toggle()
            } label : {
                HStack {
                    Text("Done")
                        .foregroundColor(.white)
                    
                    Image(systemName: "pencil")
                        .renderingMode(.template)
                        .foregroundColor(.white)
                }
                .padding()
                .background(Color(.black))
                .cornerRadius(15)
            }
            
            Spacer()
        }
    }
}

struct SheetDetailViewInside: View {
    @Environment(\.managedObjectContext) var moc
    @Binding var quote: String
    @Binding var isPresented: Bool
    
    let book: BookEntity
    
    var body: some View {
        VStack {
            TextField("Quote", text: $quote)

            Button("Done") {
                let q = QuoteEntity(context: moc)
                q.string = quote
                book.addToQuotes(q)

                try? moc.save()
                
                isPresented.toggle()
            }
        }
    }
}

struct DeleteButton: View {
    @Environment(\.managedObjectContext) var moc
   
    let books: FetchedResults<BookEntity>
    let index : Int
    let editMode : Bool
    
    var body: some View {
        if editMode {
            Circle()
                .fill(.red)
                .frame(width: 30, height: 30)
                .onTapGesture {
                    removeBook(index: index)
                }
        }
    }
    
    func removeBook(index: Int) {
        withAnimation {
            let book = books[index]
            moc.delete(book)
            
            FileManager().deleteImage(with: book.coverPhotoWrapped)
            
            try? moc.save()
        }
    }
}

struct OutlinedTextFieldStyle: TextFieldStyle {
    
    @State var icon: Image?
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        HStack {
            if icon != nil {
                icon
                    .foregroundColor(.black)
            }
            configuration
        }
        .padding()
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(.black, lineWidth: 2)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainBookView(viewModel: ImageViewModel(UIImage(systemName: "photo")!))
    }
}
