//
//  ZoomGestureRecognizer.swift
//  PlanetDefense
//
//  Created by Никита Ростовский on 01.12.2021.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

enum ZoomGestureRecognizerZoomMode {
    case Google
    case UpOutDownIn(centeredOnTap:Bool)
    case UpInDownOut(centeredOnTap:Bool)
    
    func translateScaleFactor(factor:Double) -> Double {
        switch self {
        case .Google, .UpOutDownIn:
            return -factor
        case .UpInDownOut:
            return factor
        }
    }
}

class ZoomGestureRecognizer: UIGestureRecognizer {
    var scalePower: Double = 2
    
    var zoomMode: ZoomGestureRecognizerZoomMode = .UpOutDownIn(centeredOnTap: true)
    
    var position: Float = 1
    
    private var anchorPoint:CGPoint?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        
        guard touches.count == 1 else {
            // Single finger only
            self.state = .cancelled
            return
        }
        
        if let tap = touches.first {
            guard tap.tapCount <= 2 else {
                // Second tap becomes the drag, so no more than 2 taps allowed
                self.state = .cancelled
                return
            }
            
            if tap.tapCount == 2 {
                // We're doing the drag, so remember where we tapped
                self.anchorPoint = self.location(in: self.view)
                self.state = .began
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        
        guard let view = view else {
            self.state = .cancelled
            return
        }
        guard self.state != .failed else {
            // Apple recommend you check this.
            return
        }
        
        guard [.began, .changed].contains(self.state) else {
            // Only continue if we've determined the gesture is happening, continue.
            return
        }
        
        guard touches.count == 1 else {
            // Only 1 finger
            self.state = .cancelled
            return
        }
        
        if let touch = touches.first {
            let prevLoc = touch.previousLocation(in: view)
            let thisLoc = touch.location(in: view)
            
            if __CGPointEqualToPoint(prevLoc, thisLoc) {
                return
            }
            
            let diff = Double(thisLoc.y - prevLoc.y)
            
            // Scale ratio is determined by taking a proportion of the screen height we've dragged, and raising by a power.
            
            let ratio = zoomMode.translateScaleFactor(factor: diff)  / Double(view.frame.height * 0.25)
            let scaleRatio = pow(1 + ratio, self.scalePower)
            
            let newPosition = position * Float(scaleRatio)
            position = newPosition
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        state = .ended
    }
    
    
    override func reset() {
        self.anchorPoint = nil
    }
}
