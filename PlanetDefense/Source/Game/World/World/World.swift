//
//  World.swift
//  PlanetDefense
//
//  Created by Никита Ростовский on 28.11.2021.
//

import SceneKit

final class World: SCNScene {
    var cameraMinOrbit: CGFloat { surface.radius * 3 }
    var cameraMaxOrbit: CGFloat { surface.radius * 4 }
    var cameraMinVerticalShift: CGFloat { surface.radius * 0.25 }
    var cameraMaxVerticalShift: CGFloat { -surface.radius * 0.25 }
    
    weak var view: SCNView? {
        didSet {
            if let view = view, inputAnchorPoint == nil {
                self.inputAnchorPoint = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
                updateSelection()
            }
        }
    }
    
    var surface: Surface
    var camera: Camera
    
    var inputAnchorPoint: CGPoint?
    
    private lazy var cameraTarget: SCNNode = {
        let node = SCNNode()
        node.isHidden = true
        return node
    }()
    
    override init() {
        let heightProvider = EarthHeightProvider()
        let surface = Surface(heightProvider: heightProvider)
        let camera = Camera()
        
        self.surface = surface
        self.camera = camera
        
        super.init()
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        rootNode.addChildNode(surface)
        rootNode.addChildNode(camera)
        rootNode.addChildNode(cameraTarget)
        
        setupLight()
        
        camera.look(at: cameraTarget)
        
        updateCameraScale()
    }
    
    /// Updates distance from camera to scene
    /// - Parameter scale: If 0 - closest to surface, if 1 - farthest position
    func updateCameraScale(_ scale: Double = 1) {
        camera.position.z = Float(cameraMinOrbit + (cameraMaxOrbit - cameraMinOrbit) * scale)
        cameraTarget.position.y = Float((cameraMaxVerticalShift - cameraMinVerticalShift) * scale + cameraMinVerticalShift)
        updateSelection()
    }
    
    func rotate(by translation: CGPoint) {
        let x = Float(translation.x)
        let y = Float(-translation.y)
        
        let anglePan = sqrt(pow(x, 2) + pow(y, 2)) * .pi / 180.0
        
        var rotationVector = SCNVector4()
        rotationVector.x = -y
        rotationVector.y = x
        rotationVector.z = 0
        rotationVector.w = anglePan
        
        surface.rotation = rotationVector
        
        let currentPivot = surface.pivot
        let changePivot = SCNMatrix4Invert(surface.transform)
        surface.pivot = SCNMatrix4Mult(changePivot, currentPivot)
        
        updateSelection()
    }
    
    func updateSelection() {
        let tile: SurfaceTile?
        if let inputAnchorPoint = inputAnchorPoint {
            tile = tileAt(inputAnchorPoint)
            surface.select(tile: tile)
        } else {
            tile = nil
            surface.deselect()
        }
    }
    
    func tileAt(_ position: CGPoint) -> SurfaceTile? {
        guard let view = view else { return nil }
        
        let results = view.hitTest(position, options: nil)
        let tiles = results.compactMap { $0.node as? SurfaceTile }
        return tiles.first
    }
    
    private func setupLight() {
        let lightNode1 = SCNNode()
        lightNode1.light = SCNLight()
        lightNode1.light?.type = .omni
        lightNode1.light?.intensity = 1500
//        camera.addChildNode(lightNode1)
        lightNode1.position = SCNVector3(0, 0, surface.radius * 3)
        rootNode.addChildNode(lightNode1)
    }
}
