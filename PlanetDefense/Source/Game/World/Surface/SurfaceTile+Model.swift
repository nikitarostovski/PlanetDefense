//
//  SurfaceTile+Model.swift
//  PlanetDefense
//
//  Created by Никита Ростовский on 01.12.2021.
//

import UIKit

extension SurfaceTile {
    struct Model {
        enum TileType {
            case ground
            case water
            
            var color: UIColor {
                switch self {
                case .ground:
                    return .green
                case .water:
                    return .blue
                }
            }
        }
        
        var tile: Tile
        var radius: Float
        var type: TileType = .ground
        
        init(tile: Tile, radius: Float) {
            self.tile = tile
            self.radius = radius
        }
    }
}
