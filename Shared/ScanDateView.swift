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
    @Environment(\.presentationMode) var presentationMode
    @Binding var recognizedText: Date
    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        var recognizedText: Binding<Date>
        var parent: ScanDateView
        
        init(recognizedText: Binding<Date>, parent: ScanDateView) {
            self.recognizedText = recognizedText
            self.parent = parent
        }
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            let extractedImages =  extractImages(from: scan)
            let processedText = recognizeText(from: extractedImages)
            recognizedText.wrappedValue = processedText
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func extractImages(from scan: VNDocumentCameraScan) -> [CGImage] {
            var extractedImages = [CGImage]()
            for index in 0..<scan.pageCount {
                let extractedImage = scan.imageOfPage(at: index)
                guard let cgImage = extractedImage.cgImage else {
                    continue
                }
                extractedImages.append(cgImage)
            }
            return extractedImages
        }
        func recognizeText(from images: [CGImage]) -> Date {
            var entireRecognizedText = ""
            let recognizeTextRequest = VNRecognizeTextRequest { (request, error) in
                guard error == nil else {
                    return
                }
                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    return
                }
                let maximumRecognitionCandidates = 1
                for observation in observations {
                    guard let candidate = observation.topCandidates(maximumRecognitionCandidates).first else {
                        continue
                    }
                    entireRecognizedText += "\(candidate.string)"
                }
            }
            recognizeTextRequest.recognitionLevel = .accurate
            for image in images {
                let requestHandler = VNImageRequestHandler(cgImage: image, options: [:])
                try? requestHandler.perform([recognizeTextRequest])
            }
            let formattedDate = getFormattedDate(subString: entireRecognizedText)
            print("Scanned date is: \(formattedDate)")
            return formattedDate
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(recognizedText: $recognizedText, parent: self)
    }
    
    
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
