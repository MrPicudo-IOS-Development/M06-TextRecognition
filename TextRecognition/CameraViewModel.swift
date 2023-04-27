/* CameraViewModel.swift --> TextRecognition. Created bt Miguel Torres on 24/04/23. */

import SwiftUI
import UIKit
import AVFoundation
import Vision

class CameraViewModel: NSObject, ObservableObject {
    
    // @EnvironmentObject var speechManager: SpeechManager
    
    /// Variables que se pueden utilizar en varias vistas gracias a que la clase es de tipo ObservableObject
    @Published var image: UIImage?
    @Published var isPresentingImagePicker = false
    @Published var recognizedText: String?
    @Published var matchStatus = false
    
    // Cadena de comparación de texto.
    private let referenceText = "Valclan"
    
    /*
    func speak(_ text: String) {
        speechManager.speak(text)
    }
    
    func processRecognizedText(_ text: String) {
        recognizedText = text
        // Llamar a la función que se encarga de leer en voz alta el texto
        speak(text)
    }
    */
    
    func captureImage() {
        isPresentingImagePicker = true
    }

    func imagePickerCompletionHandler(image: UIImage?) {
        self.image = image
        isPresentingImagePicker = false
        
        if let image = image {
            recognizeTextInImage(image)
        }
    }

    private func recognizeTextInImage(_ image: UIImage) {
        guard let cgImage = image.cgImage else {
            print("Failed to convert UIImage to CGImage.")
            return
        }

        let request = VNRecognizeTextRequest { (request, error) in
            if let error = error {
                print("Error recognizing text: \(error)")
                return
            }

            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            let recognizedText = observations.compactMap { $0.topCandidates(1).first?.string }.joined(separator: " ")

            DispatchQueue.main.async {
                self.recognizedText = recognizedText
                self.matchStatus = recognizedText == self.referenceText
            }
        }

        request.recognitionLevel = .accurate
        let requests = [request]

        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try? handler.perform(requests)
        }
    }
}


