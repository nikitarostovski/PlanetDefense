//
//  Surface.swift
//  PlanetDefense
//
//  Created by Никита Ростовский on 28.11.2021.
//

import SceneKit

final class Surface: SCNNode {
    let radius: Double = 1000
    
    private var heightProvider: HeightProvider?
    private let hexasphere: Hexasphere
    
    private var tiles: [SurfaceTile] = []
    private var selectedIndex: Int?
    
    var selectedTile: SurfaceTile? {
        get {
            if let selectedIndex = selectedIndex {
                return tiles[selectedIndex]
            }
            return nil
        }
        set {
            if let newValue = newValue {
                selectedIndex = tiles.firstIndex(of: newValue)
            } else {
                selectedIndex = nil
            }
        }
    }
    
    init(heightProvider: HeightProvider? = nil) {
        self.heightProvider = heightProvider
        self.hexasphere = try! Hexasphere(radius: radius, numDivisions: 4, hexSize: 1)
        super.init()
        
        setupTiles()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func select(tile: SurfaceTile?) {
        let lastSelection = selectedTile
        selectedTile = tile
        selectionDidUpdate(last: lastSelection)
    }
    
    func deselect() {
        let lastSelection = selectedTile
        selectedTile = nil
        selectionDidUpdate(last: lastSelection)
    }
    
    private func setupTiles() {
        tiles.forEach { $0.removeFromParentNode() }
        tiles.removeAll()
        
        let radius = Float(hexasphere.radius)
        
        hexasphere.tiles.forEach { tile in
            let model = SurfaceTile.Model(tile: tile, radius: radius)
            let tileNode = SurfaceTile(with: model, heightProvider: heightProvider)
            tiles.append(tileNode)
            addChildNode(tileNode)
        }
    }
    
    private func selectionDidUpdate(last: SurfaceTile?) {
        last?.state = .idle
        selectedTile?.state = .selected
    }
}
