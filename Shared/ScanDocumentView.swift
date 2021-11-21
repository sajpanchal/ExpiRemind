//
//  VisionKit.swift
//  NotifyExpiryDate
//
//  Created by saj panchal on 2021-10-23.
//

import SwiftUI
//framework that uses camera as a document scanner to scan texts from captured screenshots.
import VisionKit
import UIKit
//framework that detects the text from the captured image.
import Vision
// a struct that conforms to UIViewControllerRepresentable protocol to create handle UIKit's ViewController events in swiftui.
struct ScanDocumentView: UIViewControllerRepresentable {
    // env var to show/hide this view.
    @Environment(\.presentationMode) var presentationMode
    
    //var to hold the scanned text and it will be bound to the swiftUI view that is going to render this view.
    @Binding var recognizedText: String
    
    //this this the delegate object of ScanDocumentView. So it will be called whenever ScanDocumentView is being changed due to user interactions.
    //this class is conforming to VNDocumentCameraViweControllerDelegate. that is responsible to return the scanned results from camera.
    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        // captured text
        var recognizedText: Binding<String>
        
        //var that instantiate the parent view.
        var parent: ScanDocumentView
        
        //initialize the variables.
        init(recognizedText: Binding<String>, parent: ScanDocumentView) {
            self.recognizedText = recognizedText
            self.parent = parent
        }
        
        //this method is going to be executed on saving the scanned document.
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            //get the array of images from scanned document camera scan
            let extractedImages =  extractImages(from: scan)
            
            //from array of images, get the text
            let processedText = recognizeText(from: extractedImages)
            
            //assign the processed text to binding variable
            recognizedText.wrappedValue = processedText
            
            //close this view.
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        //extract images from scan.
        func extractImages(from scan: VNDocumentCameraScan) -> [CGImage] {
            //array of CGImages
            var extractedImages = [CGImage]()
            
            //for each scanned page
            for index in 0..<scan.pageCount {
                // extract the image
                let extractedImage = scan.imageOfPage(at: index)
                
                //convert the image to cgImage
                guard let cgImage = extractedImage.cgImage else {
                    continue
                }
                
                //append each to an array
                extractedImages.append(cgImage)
            }
            
            //return the array
            return extractedImages
        }
        
        //recognize text from array of images.
        func recognizeText(from images: [CGImage]) -> String {
            var entireRecognizedText = ""
            
            // a methdo that requests text recognition
            let recognizeTextRequest = VNRecognizeTextRequest { (request, error) in
                // if error is nil skip the else statement
                guard error == nil else {
                    return
                }
                // if the request is having the array of text observations skip the else statement
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    return
                }
                //set the number of candidates from observed texts.
                let maximumRecognitionCandidates = 1
                
                //iterate through each observation
                for observation in observations {
                    //get the first top candidate i.e. a character from the text observations
                    guard let candidate = observation.topCandidates(maximumRecognitionCandidates).first else {
                        continue
                    }
                    //merge the candidate string into a full text.
                    entireRecognizedText += "\(candidate.string)"
                }
            }
            //set the recognition of the text request to accurate.
            recognizeTextRequest.recognitionLevel = .accurate
            //iterate through the image array
            for image in images {
                //get the request handler instance for a given image
                let requestHandler = VNImageRequestHandler(cgImage: image, options: [:])
                
                //perform vision request to recognize text.
                try? requestHandler.perform([recognizeTextRequest])
            }
            // if text is not found set it as error
            if entireRecognizedText == "" {
                entireRecognizedText = "error"
            }
            // return the recognized text
            return entireRecognizedText
        }
    }
    // method called by internal APIs to instantiate Coordinator.
    func makeCoordinator() -> Coordinator {
        Coordinator(recognizedText: $recognizedText, parent: self)
    }
    
    //method called when this view is rendered by SwiftUI Views to create a camera scanner view controller.
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let documentViewController = VNDocumentCameraViewController()
        documentViewController.delegate = context.coordinator
        return documentViewController
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {
        //
    }
    
    typealias UIViewControllerType = VNDocumentCameraViewController
    
    
    
}
