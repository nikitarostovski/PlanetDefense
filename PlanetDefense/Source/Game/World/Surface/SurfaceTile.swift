//
//  SurfaceTile.swift
//  PlanetDefense
//
//  Created by Никита Ростовский on 29.11.2021.
//

import SceneKit

final class SurfaceTile: SCNNode {
    enum State {
        case idle
        case selected
    }
    
    var state: State = .idle {
        didSet {
            if state != oldValue {
                updateStyle()
            }
        }
    }
    
    var color: UIColor { model.type.color }
    
    var model: Model
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(with model: Model, heightProvider: HeightProvider?) {
        self.model = model
        super.init()
        
        setup(with: heightProvider)
        updateStyle()
    }
    
    private func updateStyle() {
        let material = SCNMaterial()
        material.diffuse.contents = color
        
        if state == .selected {
            material.diffuse.contents = UIColor.white
        }
        
        material.isDoubleSided = true
        material.locksAmbientWithDiffuse = true
        geometry?.materials = [material]
    }
    
    private func setup(with heightProvider: HeightProvider?) {
        self.geometry = makeGeometry(for: model.tile, radius: model.radius, heightProvider: heightProvider)
        let center = model.tile.centre.scnVectorValue
        
        let type: Model.TileType
        let height = heightProvider?.getHeight(at: center, radius: model.radius) ?? 1
        
        switch height {
        case 0..<1:
            type = .water
        default:
            type = .ground
        }
        
        self.model.type = type
    }
    
    private func makeGeometry(for tile: Tile, radius: Float, heightProvider: HeightProvider?) -> SCNGeometry {
        var indices = [UInt32]()
        var normals = [SCNVector3]()
        var vertices = [SCNVector3]()
        var textureCoordinates = [CGPoint]()
        
        let center = tile.centre.scnVectorValue
        let textureCoord = center.pointOnSphereToUV()
        
        // Add hexagon cap
        var heightModifier: Float = 1
        if let heightProvider = heightProvider {
            heightModifier = heightProvider.getHeight(at: center, radius: radius)
        }
        
        let vectors = tile.boundaries.map { $0.scnVectorValue }
        
        var capVertices = [SCNVector3]()
        for vector in vectors {
            let vertex = vector.normalized.multiplied(by: radius * heightModifier)
            capVertices.append(vertex)
            textureCoordinates.append(textureCoord)
        }
        let capIndices = makeIndices(for: capVertices.count).map { $0 + UInt32(vertices.count) }
        
        vertices.append(contentsOf: capVertices)
        indices.append(contentsOf: capIndices)
        
        // Add hexagon walls
        for vector in vectors {
            vertices.append(vector)
            textureCoordinates.append(textureCoord)
        }
        
        let zero = SCNVector3(0, 0, 0)
        let zeroNormal = normal_(vectors[0], zero, vectors[1])
        vertices.append(zero)
        normals.append(zeroNormal)
        textureCoordinates.append(textureCoord)
        
        for index in 0..<vectors.count {
            let lastShift = index == 0 ? (vectors.count - 1) : (index - 1)
            
            let curVertex = index
            let lastVertex = lastShift
            
            let planeIndices = [curVertex, lastVertex, vertices.count - 1]
            
            indices.append(contentsOf: planeIndices.map { UInt32($0) })
        }
        
        let sources = [
            SCNGeometrySource(vertices: vertices),
            SCNGeometrySource(textureCoordinates: textureCoordinates)
        ]
        
        let elements = [
            SCNGeometryElement(indices: indices, primitiveType: .triangles)
        ]
        
        return SCNGeometry(sources: sources, elements: elements)
    }
    
    private func makeIndices(for vertexCount: Int) -> [UInt32] {
        let indicesNeeded = (vertexCount - 2) * 3
        
        var result = [UInt32]()
        for i in [0, 1, 2,
                  0, 2, 3,
                  0, 3, 4,
                  0, 4, 5][0..<indicesNeeded] {
            result.append(UInt32(i))
        }
        
        return result
    }
}
