//
//  Camera.swift
//  PlanetDefense
//
//  Created by Никита Ростовский on 28.11.2021.
//

import SceneKit

final class Camera: SCNNode {
    private lazy var cameraNode: SCNNode = {
        let node = SCNNode()
        node.camera = _camera
        return node
    }()
    
    private lazy var _camera: SCNCamera = {
        let camera = SCNCamera()
        camera.automaticallyAdjustsZRange = true
        
        camera.wantsHDR = true
//        camera.bloomThreshold = 0.8
//        camera.bloomIntensity = 2
//        camera.bloomBlurRadius = 16.0
        camera.wantsExposureAdaptation = false
        
        return camera
    }()
    
    private lazy var orbit: SCNNode = {
        let node = SCNNode()
        return node
    }()
    
    override init() {
        super.init()
//        addChildNode(orbit)
//        orbit.addChildNode(cameraNode)
        addChildNode(cameraNode)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func look(at target: SCNNode) {
        let constraint = SCNLookAtConstraint(target: target)
        constraint.isGimbalLockEnabled = true
        cameraNode.constraints = [constraint]
    }
}
