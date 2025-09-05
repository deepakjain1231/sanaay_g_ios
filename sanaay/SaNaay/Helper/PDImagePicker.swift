//
//  PDImagePicker.swift
//
//  Created by Paresh Dafda on 28/01/20.
//  Copyright © 2020 KCS. All rights reserved.
//

import UIKit
import AVKit

public protocol PDImagePickerDelegate: AnyObject {
    func imagePicker(_ imagePicker: PDImagePicker, didSelectImage image: UIImage?)
    func imagePicker(_ imagePicker: PDImagePicker, didSelectMovie url: URL?)
}

extension PDImagePickerDelegate {
    func imagePicker(_ imagePicker: PDImagePicker, didSelectMovie url: URL?) {}
}

open class PDImagePicker: NSObject {
    
    public enum MediaType: String {
        case image = "public.image"
        case movie = "public.movie"
    }

    private let pickerController: UIImagePickerController
    private weak var presentationController: UIViewController?
    private weak var delegate: PDImagePickerDelegate?
    private var mediaTypes: [MediaType]
    private var allowsEditing: Bool

    public init(presentingVC: UIViewController, delegate: PDImagePickerDelegate, mediaTypes: [MediaType] = [.image], allowsEditing: Bool = false, videoMaximumDuration: TimeInterval? = nil) {
        self.pickerController = UIImagePickerController()
        self.mediaTypes = mediaTypes
        self.allowsEditing = allowsEditing

        super.init()

        self.presentationController = presentingVC
        self.delegate = delegate

        self.pickerController.delegate = self
        self.pickerController.mediaTypes = mediaTypes.map{ $0.rawValue }   //["public.image", "public.movie"]
        self.pickerController.videoQuality = .typeMedium
        if let videoMaximumDuration = videoMaximumDuration {
            self.pickerController.videoMaximumDuration = videoMaximumDuration
        }
        self.pickerController.allowsEditing = allowsEditing
    }

    private func action(for type: UIImagePickerController.SourceType, title: String) -> UIAlertAction? {
        guard UIImagePickerController.isSourceTypeAvailable(type) else {
            return nil
        }

        return UIAlertAction(title: title, style: .default) { [unowned self] _ in
            self.pickerController.sourceType = type
            self.presentationController?.present(self.pickerController, animated: true)
        }
    }

    public func present(from sourceView: UIView? = nil, is_video: Bool = false) {

        let alertController = UIAlertController(title: "Choose image from", message: nil, preferredStyle: .actionSheet)

        if let action = self.action(for: .camera, title: "Camera") {
            alertController.addAction(action)
        }
        
        var sttr_Text = "Photo library"
        if is_video {
            sttr_Text = "Photo & Video library"
        }
        if let action = self.action(for: .photoLibrary, title: sttr_Text) {
            alertController.addAction(action)
        }

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        if UIDevice.current.userInterfaceIdiom == .pad {
            alertController.popoverPresentationController?.sourceView = sourceView
            alertController.popoverPresentationController?.sourceRect = sourceView?.bounds ?? .zero
            alertController.popoverPresentationController?.permittedArrowDirections = [.down, .up]
        }

        self.presentationController?.present(alertController, animated: true)
    }

    private func pickerController(_ controller: UIImagePickerController, didSelect image: UIImage?) {
        controller.dismiss(animated: true, completion: nil)

        self.delegate?.imagePicker(self, didSelectImage: image)
    }
    
    private func pickerController(_ controller: UIImagePickerController, didSelectMovie url: URL?) {
        controller.dismiss(animated: true, completion: nil)

        self.delegate?.imagePicker(self, didSelectMovie: url)
    }
}

extension PDImagePicker: UIImagePickerControllerDelegate {

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.pickerController(picker, didSelect: nil)
    }

    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[picker.allowsEditing ? .editedImage : .originalImage] as? UIImage {
            self.pickerController(picker, didSelect: image)
        } else if let videoURL = info[.mediaURL] as? URL {
            self.pickerController(picker, didSelectMovie: videoURL)
        } else {
            self.pickerController(picker, didSelect: nil)
        }
    }
}

extension PDImagePicker: UINavigationControllerDelegate {

}

//import SDWebImage
extension URL {
    func generateVideoThumbnailAsync(atTimeInSecond: Int = 1, completion: @escaping (_ image: UIImage?)->Void) {
        DispatchQueue.global(qos: .utility).async {
            let asset = AVAsset(url: self)
            let avAssetImageGenerator = AVAssetImageGenerator(asset: asset)
            avAssetImageGenerator.appliesPreferredTrackTransform = true
            let thumnailTime = CMTimeMake(value: 2, timescale: Int32(atTimeInSecond))
            do {
                let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil)
                let thumbNailImage = UIImage(cgImage: cgThumbImage)
                DispatchQueue.main.async {
                    completion(thumbNailImage)
                }
            } catch {
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    
    /*func generateCachebleVideoThumbnailAsync(size: CGSize = CGSize(width: 120, height: 120), completion: @escaping (_ image: UIImage?)->Void) {
        
        let manager = SDWebImageManager.shared
        if let key = manager.cacheKey(for: self) {
            manager.imageCache.queryImage(forKey: key, options: .fromCacheOnly, context: nil) {  (image, data, cacheType) in
                if let image = image {
                    //already cache image
                    completion(image)
                } else {
                    generateVideoThumbnailAsync { thumbnail in
                        manager.imageCache.store(thumbnail, imageData: nil, forKey: key, cacheType: .disk, completion: nil)
                        completion(thumbnail)
                    }
                }
            }
        }
    }*/
}
