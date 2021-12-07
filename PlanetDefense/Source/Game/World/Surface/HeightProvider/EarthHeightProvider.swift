//
//  EarthHeightProvider.swift
//  PlanetDefense
//
//  Created by Никита Ростовский on 28.11.2021.
//

import Foundation
import SceneKit

final class EarthHeightProvider: HeightProvider {
    private let heightScale: Float = 0.15
    private let imageName = "earth_heightmap"
    
    private let imageData: UnsafePointer<UInt8>
    private let imageSize: CGSize

    let image: UIImage
    let pixelData: CFData?
    
    init() {
        let image = UIImage(named: imageName)!
        let pixelData = image.cgImage!.dataProvider!.data
        self.imageSize = image.size
        self.imageData = CFDataGetBytePtr(pixelData)
        
        self.image = image
        self.pixelData = pixelData
    }
    
    func getHeight(at vertex: SCNVector3, radius: Float) -> Float {
        let coord = vertex.pointOnSphereToUV()
        let height = height(at: coord) * 2 - 1
        let k = 1 + height * heightScale

        return k
    }
    
    private func height(at point: CGPoint) -> Float {
        let imageData: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)

        let pos = CGPoint(x: point.x * imageSize.width, y: point.y * imageSize.height)
        let pixelInfo: Int = ((Int(imageSize.width) * Int(pos.y)) + Int(pos.x)) * 4

        let r = Float(imageData[pixelInfo]) / Float(255.0)
        let g = Float(imageData[pixelInfo+1]) / Float(255.0)
        let b = Float(imageData[pixelInfo+2]) / Float(255.0)

        return (r + g + b) / 3
    }
}
