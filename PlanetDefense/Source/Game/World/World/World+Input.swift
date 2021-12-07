//
//  World+Input.swift
//  PlanetDefense
//
//  Created by Никита Ростовский on 28.11.2021.
//

import UIKit
import SceneKit

protocol UserInputTarget {
    func onScale(_ scale: Double)
    func onPan(_ translation: CGPoint)
    func onTap(_ position: CGPoint)
}

extension World: UserInputTarget {
    func onScale(_ scale: Double) {
        print("Scale")
        inputAnchorPoint = nil
        updateCameraScale(scale)
    }
    
    func onPan(_ translation: CGPoint) {
        print("Pan")
        inputAnchorPoint = nil
        rotate(by: translation)
    }
    
    func onTap(_ position: CGPoint) {
        print("Tap")
        if let tile = tileAt(position), tile === surface.selectedTile {
            inputAnchorPoint = nil
        } else {
            inputAnchorPoint = position
        }
        
        updateSelection()
    }
}
