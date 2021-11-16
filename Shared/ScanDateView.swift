//
//  VisionKit.swift
//  NotifyExpiryDate
//
//  Created by saj panchal on 2021-10-23.
//

import SwiftUI
import VisionKit
import UIKit
import Vision

struct ScanDateView: UIViewControllerRepresentable {
    //var to hide/show this VC
    @Environment(\.presentationMode) var presentationMode
    
    //variables to be bound to rendering swiftUI view.
    @Binding var recognizedText: Date
    @Binding var isDateNotFound: Bool
    
    //VC coordinator
    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        //to hold recognized text
        var recognizedText: Binding<Date>
        
        //to instantiate parent instance.
        var parent: ScanDateView
        
        //initializer of properties.
        init(recognizedText: Binding<Date>, parent: ScanDateView) {
            self.recognizedText = recognizedText
            self.parent = parent
        }
        
        //method is called when the scanned document is saved.
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            //extract the images from a scanned document.
            let extractedImages =  extractImages(from: scan)
            
            //recognize text from extracted images.
            let processedText = recognizeText(from: extractedImages).0
            
            //assign the full text to binding var.
            recognizedText.wrappedValue = processedText
            
            //dissmiss the vc.
            parent.presentationMode.wrappedValue.dismiss()
        }
        //extract array of images from scanned document
        func extractImages(from scan: VNDocumentCameraScan) -> [CGImage] {
            //array instance
            var extractedImages = [CGImage]()
            
            //iterate through document pages
            for index in 0..<scan.pageCount {
                // get the image
                let extractedImage = scan.imageOfPage(at: index)
                
                //convert it to cgImage
                guard let cgImage = extractedImage.cgImage else {
                    continue
                }
                //append image to an array
                extractedImages.append(cgImage)
            }
            
            //return array of cgImages
            return extractedImages
        }
        
        //from array of images get the text and convert it to Date and a scan result
        func recognizeText(from images: [CGImage]) -> (Date,Bool) {
            //var to hold text
            var entireRecognizedText = ""
            
            //request to recognize text from document
            let recognizeTextRequest = VNRecognizeTextRequest { (request, error) in
                //if error is not found skip else
                guard error == nil else {
                    return
                }
                //get the results from the request if it is found skip else statement
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    return
                }
                //get one top candiate from each obseravtions
                let maximumRecognitionCandidates = 1
                
                //iterate through each text recognition observations
                for observation in observations {
                    //get the best candidate that will be having a text in string format.
                    guard let candidate = observation.topCandidates(maximumRecognitionCandidates).first else {
                        continue
                    }
                    // make a full text.
                    entireRecognizedText += "\(candidate.string)"
                }
            }
            // make the recognization level to accurate.
            recognizeTextRequest.recognitionLevel = .accurate
            // iterate through all images
            for image in images {
                //image recognition request
                let requestHandler = VNImageRequestHandler(cgImage: image, options: [:])
                //perform text request
                try? requestHandler.perform([recognizeTextRequest])
            }
            // get the date from a string
            let formattedDate = getFormattedDate(scannedText: entireRecognizedText).0
            
            //get the scanned result
            parent.isDateNotFound = getFormattedDate(scannedText: entireRecognizedText).1
            
            print("Scanned date is: \(formattedDate)")
            print("date not found?:\(parent.isDateNotFound)")
            
            //return the tuple
            return (formattedDate,parent.isDateNotFound)
        }
    }
    
    //method will be called by internal API to create coordinator instance.
    func makeCoordinator() -> Coordinator {
        Coordinator(recognizedText: $recognizedText, parent: self)
    }
    
    //method will be called when this VC is rendered by the swiftui views.
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
