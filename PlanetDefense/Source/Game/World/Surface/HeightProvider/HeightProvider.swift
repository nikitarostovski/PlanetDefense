//
//  HeightProvider.swift
//  PlanetDefense
//
//  Created by Никита Ростовский on 28.11.2021.
//

import SceneKit

protocol HeightProvider {
    func getHeight(at vertex: SCNVector3, radius: Float) -> Float
}
