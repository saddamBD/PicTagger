//
//  ViewController.swift
//  PicTaggerImagga
//
//  Created by General on 4/25/18.
//  Copyright © 2018 General. All rights reserved.
//

import UIKit
import Alamofire
import SVProgressHUD
class ViewController: UIViewController {
    
    @IBOutlet var imgButton: UIButton!
    @IBOutlet var imageView: UIImageView!
    
    fileprivate var tags: [String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard !UIImagePickerController.isSourceTypeAvailable(.camera) else { return }
        
        imgButton.setTitle("Select Photo", for: .normal)
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        imageView.image = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ShowResults" {
            let controller = segue.destination as! TagVC
            controller.tags = tags
        }
    }
    
    @IBAction func takePicture(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        } else {
            picker.sourceType = .photoLibrary
            picker.modalPresentationStyle = .fullScreen
        }
        
        present(picker, animated: true)
    }
}

extension ViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            print("Info did not have the required UIImage for the Original Image")
            dismiss(animated: true)
            return
        }
        
        imageView.image = image
        imgButton.isHidden = true
        SVProgressHUD.show(withStatus: "photo is uploading")
        
        upload(
            image: image,
            progressCompletion: { _ in ()
            },
            completion: { [unowned self] tags in
                self.imgButton.isHidden = false
                self.tags = tags
                SVProgressHUD.dismiss()
                self.performSegue(withIdentifier: "ShowResults", sender: self)
        })
        
        dismiss(animated: true)
    }
}

// MARK: - UINavigationControllerDelegate
extension ViewController: UINavigationControllerDelegate {
}

// MARK: - Networking calls
extension ViewController {
    
    func upload(image: UIImage,
                progressCompletion: @escaping (_ percent: Float) -> Void,
                completion: @escaping (_ tags: [String]) -> Void) {
        guard let imageData = UIImageJPEGRepresentation(image, 0.5) else {
            print("JPEG Format not found ")
            return
        }
        
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(imageData,
                                         withName: "imagefile",
                                         fileName: "image.jpg",
                                         mimeType: "image/jpeg")
        },
            with: ImaggaRouter.content,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.uploadProgress { progress in
                        progressCompletion(Float(progress.fractionCompleted))
                    }
                    upload.validate()
                    upload.responseJSON { response in
                        guard response.result.isSuccess else {
                            print("Error while uploading file")
                            completion([String]())
                            return
                        }
                        
                        guard let responseJSON = response.result.value as? [String: Any],
                            let uploadedFiles = responseJSON["uploaded"] as? [Any],
                            let firstFile = uploadedFiles.first as? [String: Any],
                            let firstFileID = firstFile["id"] as? String else {
                                print("Invalid information received from service")
                                completion([String]())
                                return
                        }
                        
                        print("Content uploaded with ID: \(firstFileID)")
                        
                        self.downloadTags(contentID: firstFileID) { tags in
                            completion(tags)
                            
                        }
                    }
                case .failure(let encodingError):
                    print(encodingError)
                }
        }
        )
    }
    
    func downloadTags(contentID: String, completion: @escaping ([String]) -> Void) {
        Alamofire.request(ImaggaRouter.tags(contentID))
            .responseJSON { response in
                
                guard response.result.isSuccess else {
                    print("Error while fetching tags")
                    completion([String]())
                    return
                }
                
                guard let responseJSON = response.result.value as? [String: Any],
                    let results = responseJSON["results"] as? [[String: Any]],
                    let firstObject = results.first,
                    let tagsAndConfidences = firstObject["tags"] as? [[String: Any]] else {
                        print("Invalid tag information received from the service")
                        completion([String]())
                        return
                }
                
                let tags = tagsAndConfidences.flatMap({ dict in
                    return dict["tag"] as? String
                })
                
                completion(tags)
        }
    }
    
}

