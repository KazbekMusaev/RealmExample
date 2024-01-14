//
//  StorageManager.swift
//  RealmExample
//
//  Created by apple on 14.01.2024.
//

import Foundation

class StorageManager {
    
    func urlPuth() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    func saveImage(imageData: Data, namePhoto: String) {
        var path = urlPuth()
        
        path.append(path: namePhoto + ".jpg")
        
        do {
            try imageData.write(to: path)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func loadImage(fileName: String) -> Data {
        var path = urlPuth()
        path.append(path: fileName)
        
        if let imageData = try? Data(contentsOf: path) {
            return imageData
        } else {
            print("Не смогли найти фотографию по данному пути")
            return Data()
        }
        
        
    }
    
}
