//
//  ImagePickerButton.swift
//  Socialcademy
//
//  Created by John Royal on 1/9/22.
//

import SwiftUI

// MARK: - ImagePickerButton

struct ImagePickerButton<Label: View>: View {
    @Binding var imageURL: URL?
    @ViewBuilder let label: () -> Label
    
    @State private var showImageSourceDialog = false
    @State private var sourceType: UIImagePickerController.SourceType?
    
    var body: some View {
        Button(action: {
            showImageSourceDialog = true
        }) {
            label()
        }
        .confirmationDialog("Choose Image", isPresented: $showImageSourceDialog) {
            Button("Choose from Library", action: {
                sourceType = .photoLibrary
            })
            Button("Take Photo", action: {
                sourceType = .camera
            })
            if imageURL != nil {
                Button("Remove Photo", role: .destructive, action: {
                    imageURL = nil
                })
            }
        }
        .fullScreenCover(item: $sourceType) { sourceType in
            ImagePickerView(sourceType: sourceType) {
                imageURL = $0
            }
            .ignoresSafeArea()
        }
    }
}

extension UIImagePickerController.SourceType: Identifiable {
    public var id: String { "\(self)" }
}

// MARK: - ImagePickerView

private extension ImagePickerButton {
    struct ImagePickerView: UIViewControllerRepresentable {
        let sourceType: UIImagePickerController.SourceType
        let onSelect: (URL) -> Void
        
        @Environment(\.dismiss) var dismiss
        
        func makeCoordinator() -> ImagePickerCoordinator {
            return ImagePickerCoordinator(view: self)
        }
        
        func makeUIViewController(context: Context) -> UIImagePickerController {
            let imagePicker = UIImagePickerController()
            imagePicker.allowsEditing = true
            imagePicker.delegate = context.coordinator
            imagePicker.sourceType = sourceType
            return imagePicker
        }
        
        func updateUIViewController(_ imagePicker: UIImagePickerController, context: Context) {}
    }
}

// MARK: - ImagePickerCoordinator

private extension ImagePickerButton {
    class ImagePickerCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let view: ImagePickerView
        
        init(view: ImagePickerView) {
            self.view = view
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            var selectedImage: UIImage!
            var imageURL: URL!

            if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                selectedImage = image
            } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                selectedImage = image
            }
             // when image comes from camera
            if picker.sourceType == UIImagePickerController.SourceType.camera {
                let imgName = "\(UUID().uuidString).jpeg" // name the pic from camera
                let documentDirectory = NSTemporaryDirectory() // Temp dir where the pic will be saved
                let localPath = documentDirectory.appending(imgName)
                let data = selectedImage.jpegData(compressionQuality: 0.3)! as NSData
                data.write(toFile: localPath, atomically: true) // save the pic
                imageURL = URL.init(fileURLWithPath: localPath) // get the pic URL
                
                // When image is choosen from library
            } else if let selectedImageURL = info[UIImagePickerController.InfoKey.imageURL] as? URL {
                imageURL = selectedImageURL
            }
            view.onSelect(imageURL)
            view.dismiss()
        }
    }
}

// MARK: - Preview

struct ImagePickerButton_Previews: PreviewProvider {
    static var previews: some View {
        ImagePickerButton(imageURL: .constant(nil)) {
            Label("Choose Image", systemImage: "photo.fill")
        }
    }
}
