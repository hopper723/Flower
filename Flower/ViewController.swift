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
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    
    let imagePicker = UIImagePickerController()
    let wikipediaURl = "https://en.wikipedia.org/w/api.php"
    
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
                self.requestInfo(flowerName: classification.identifier)
                
            } else {
                print("Unable to classify image.")
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        } catch {
            print("Unable to perform request.")
        }
    }
    
    func requestInfo(flowerName: String) {
        let parameters : [String:String] = [
            "format" : "json",
            "action" : "query",
            "prop" : "extracts",
            "exintro" : "",
            "explaintext" : "",
            "titles" : flowerName,
            "indexpageids" : "",
            "redirects" : "1",
        ]
        
        Alamofire.request(wikipediaURl, method: .get, parameters: parameters).validate().responseJSON {
            (response) in
            if response.result.isSuccess {
                let result = JSON(response.result.value!)
                let pageId = result["query"]["pageids"][0].stringValue
                let description = result["query"]["pages"][pageId]["extract"].stringValue
                
                self.descriptionLabel.text = description
            }
        }
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true, completion: nil)
    }
}

