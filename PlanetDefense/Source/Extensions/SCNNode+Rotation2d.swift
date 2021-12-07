//
//  SCNNode+Rotation2d.swift
//  Flight
//
//  Created by Никита Ростовский on 17.11.2021.
//

import SceneKit

extension SCNNode {
    func rotate(by delta: CGPoint, at view: SCNView) {
        var rotMatrix: SCNMatrix4!
        let rotX = SCNMatrix4Rotate(SCNMatrix4Identity, Float((1.0 / 100) * delta.y), 1, 0, 0)
        let rotY = SCNMatrix4Rotate(SCNMatrix4Identity, Float((1.0 / 100) * delta.x), 0, 1, 0)
        rotMatrix = SCNMatrix4Mult(rotX, rotY)
        
        let transMatrix = SCNMatrix4MakeTranslation(self.position.x, self.position.y, self.position.z)
        self.transform = SCNMatrix4Mult(self.transform, SCNMatrix4Invert(transMatrix))
        let parentNoderanslationMatrix = SCNMatrix4MakeTranslation((self.parent?.worldPosition.x)!, (self.parent?.worldPosition.y)!, (self.parent?.worldPosition.z)!)
        let parentNodeMatWOTrans = SCNMatrix4Mult((self.parent?.worldTransform)!, SCNMatrix4Invert(parentNoderanslationMatrix))
        self.transform = SCNMatrix4Mult(self.transform, parentNodeMatWOTrans)
        let camorbitNodeTransMat = SCNMatrix4MakeTranslation((view.pointOfView?.worldPosition.x)!, (view.pointOfView?.worldPosition.y)!, (view.pointOfView?.worldPosition.z)!)
        let camorbitNodeMatWOTrans = SCNMatrix4Mult((view.pointOfView?.worldTransform)!, SCNMatrix4Invert(camorbitNodeTransMat))
        self.transform = SCNMatrix4Mult(self.transform, SCNMatrix4Invert(camorbitNodeMatWOTrans))
        self.transform = SCNMatrix4Mult(self.transform, rotMatrix)
        self.transform = SCNMatrix4Mult(self.transform, camorbitNodeMatWOTrans)
        self.transform = SCNMatrix4Mult(self.transform, SCNMatrix4Invert(parentNodeMatWOTrans))
        self.transform = SCNMatrix4Mult(self.transform, transMatrix)
    }
}
