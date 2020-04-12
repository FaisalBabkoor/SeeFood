//
//  ViewController.swift
//  SeeFood
//
//  Created by Faisal Babkoor on 3/30/20.
//  Copyright © 2020 Faisal Babkoor. All rights reserved.
//

import UIKit
import CoreML
import Vision

typealias UIImagePickerMethods = UIImagePickerControllerDelegate & UINavigationControllerDelegate

class ViewController: UIViewController, UIImagePickerMethods {
    
    //MARK: IBOutlet
    @IBOutlet private var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
    }
    
    @IBAction private func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickedImage = info[.originalImage] as? UIImage {
            imageView.image = userPickedImage
            guard let ciimage = CIImage(image: userPickedImage) else { fatalError("Could not conver image to CIImage")}
            detect(image: ciimage)
        }
        
        
        
        imagePicker.dismiss(animated: true)
    }
    
    func detect(image: CIImage) {
        do {
            let model = try VNCoreMLModel(for: Inceptionv3().model)
            let request = VNCoreMLRequest(model: model) { request, error in
                guard let results = request.results as? [VNClassificationObservation] else { fatalError("Could not conver image to CIImage")}
                if let firstResult = results.first {
                    if firstResult.identifier.contains("hotdog") {
                        self.navigationItem.title = "Hotdog!"
                    } else {
                        self.navigationItem.title = "Not Hotdog!"
                    }
                }
            }
            let handler = VNImageRequestHandler(ciImage: image)
            do {
                try handler.perform([request])
            } catch {
                debugPrint(error.localizedDescription)
            }
        } catch {
            fatalError("Loading CoreML Faild")
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
}

