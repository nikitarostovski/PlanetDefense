//
//  SCNVector3+Utils.swift
//  Flight
//
//  Created by Никита Ростовский on 27.11.2021.
//

import SceneKit

extension SCNVector3 {
    var length: Float {
        sqrt(x * x + y * y + z * z)
    }
    
    var normalized: SCNVector3 {
        SCNVector3(x / length, y / length, z / length)
    }
    
    func multiplied(by n: Float) -> SCNVector3 {
        SCNVector3(x * n, y * n, z * n)
    }
    
    func pointOnSphereToUV() -> CGPoint {
        var p = self.normalized
        if p.x.isNaN || p.y.isNaN || p.z.isNaN {
            p = self
        }
        let lon = atan2(p.x, -p.z)
        let lat = asin(p.y)
        let u = (lon / .pi + 1) / 2
        let v = lat / .pi + 0.5
        return CGPoint(x: CGFloat(u), y: CGFloat(v))
    }
    
    func pointOnCubeToPointOnSphere() -> SCNVector3 {
        let p = self.normalized

        let x2 = p.x * p.x
        let y2 = p.y * p.y
        let z2 = p.z * p.z
        let x = self.x * sqrt(1 - (y2 + z2) / 2 + (y2 * z2) / 3)
        let y = self.y * sqrt(1 - (z2 + x2) / 2 + (z2 * x2) / 3)
        let z = self.z * sqrt(1 - (x2 + y2) / 2 + (x2 * y2) / 3)
        return SCNVector3(x, y, z)
    }
}
