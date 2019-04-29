//
//  ViewController.swift
//  Flower
//
//  Created by Hiu Man Yeung on 4/29/19.
//  Copyright © 2019 Hiu Man Yeung. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var photoView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            photoView.image = pickedImage
            
            guard let ciImage = CIImage(image: pickedImage) else {
                fatalError("Unable to convert to CIImage.")
            }
            detect(image: ciImage)
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func detect(image: CIImage) {
        
        guard let model = try? VNCoreMLModel(for: FlowerClassifier().model) else {
            fatalError("Unable to import model.")
        }
        
        let request = VNCoreMLRequest(model: model) { (request, error) in
            if let classification = request.results?.first as? VNClassificationObservation {
                self.navigationItem.title = classification.identifier.capitalized
            } else {
                print("Unable to process image.")
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        } catch {
            print("Unable to perform request.")
        }
        
//        guard let pixelBuffer = image.pixelBuffer else {
//            fatalError("No pixel buffer.")
//        }
//        do {
//            let prediction = try FlowerClassifier().prediction(data: pixelBuffer)
//            navigationItem.title = prediction.classLabel
//        } catch {
//            print("Unable to process image.")
//        }
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
}

