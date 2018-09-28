//
//  Searchable.swift
//  Continuum
//
//  Created by Levi Linchenko on 25/09/2018.
//  Copyright © 2018 Levi Linchenko. All rights reserved.
//

import Foundation
import CloudKit


protocol SearchableRecord {
    func matchesSearchTerm(searchTerm: String)-> Bool
}
protocol CKPhotoSavable {
    var tempURL: URL? {get set}
    var imageData: Data? {get set}
    
    
}

extension CKPhotoSavable {
    
    var imageAsset: CKAsset? {
        mutating get {
            let tempDirectory = NSTemporaryDirectory()
            let tempDirecotryURL = URL(fileURLWithPath: tempDirectory)
            let fileURL = tempDirecotryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
            self.tempURL = fileURL
            do {
                try imageData?.write(to: fileURL)
            } catch let error {
                print("Error writing to temp url \(error) \(error.localizedDescription)")
            }
            return CKAsset(fileURL: fileURL)
        }
    }
    func deinitURL() {
    
        if let url = tempURL {
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                print ("💩💩 error in function \(#file), \(#function), \(error.localizedDescription)💩💩")
            }
        }
    }
    
    
    
    
}







