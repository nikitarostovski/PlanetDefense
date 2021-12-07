//
//  UserInputControl.swift
//  Flight
//
//  Created by Никита Ростовский on 15.11.2021.
//

import UIKit
import SceneKit

protocol UserInputControlDelegate {
    func inputControlDidPan(_ translation: CGPoint)
    func inputControlDidTap(_ position: CGPoint)
    func inputControlDidZoom(_ scale: CGFloat)
}

final class UserInputControl: UIView {
    private let maxScale: CGFloat = 1
    private let minScale: CGFloat = 0
    private let scalePivots: [CGFloat] = [0, 1]
    
    var delegate: UserInputControlDelegate?
    
    var currentScale: CGFloat = 0
    
    private var previousLoc: CGPoint = .zero
    private var touchCount: Int = 0
    
    private var pivotStep = 1
    
    private var panScale: CGFloat = 0.5
    
    private lazy var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
    private lazy var doubletapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
    private lazy var panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
    private lazy var zoomGestureRecognizer = ZoomGestureRecognizer(target: self, action: #selector(handleZoom))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
        backgroundColor = UIColor.clear
        doubletapGestureRecognizer.numberOfTapsRequired = 2
        [
            tapGestureRecognizer,
            doubletapGestureRecognizer,
            panGestureRecognizer,
            zoomGestureRecognizer
        ].forEach {
            $0.delegate = self
            addGestureRecognizer($0)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    func handleZoom(recognizer: ZoomGestureRecognizer) {
        let position = CGFloat(recognizer.position)
        guard currentScale != position else { return }
        
        guard position >= minScale, position <= maxScale else {
            recognizer.position = Float(max(minScale, min(maxScale, position)))
            return
        }
        
        delegate?.inputControlDidZoom(position)
        currentScale = position
    }
    
    @objc
    func handleTap(recognizer: UITapGestureRecognizer) {
        guard recognizer.state == .ended else { return }
        let loc = recognizer.location(in: self)
        delegate?.inputControlDidTap(loc)
    }
    
    @objc
    func handleDoubleTap(recognizer: UITapGestureRecognizer) {
        guard recognizer.state == .ended else { return }
        let closest = scalePivots.min(by: { abs($0 - currentScale) < abs($1 - currentScale)} )!
        
        let index = scalePivots.firstIndex(of: closest)!
        
        
        let step = index + pivotStep
        let bound = pivotStep < 0 ? 0 : scalePivots.count - 1
        let violated = (pivotStep < 0) ? (index <= bound) : (index >= bound)
        
        if violated {
            pivotStep *= -1
        }
        let nextIndex = violated ? bound + pivotStep : step
        
        currentScale = scalePivots[nextIndex]
        zoomGestureRecognizer.position = Float(currentScale)
        
        delegate?.inputControlDidZoom(currentScale)
    }

    @objc
    func handlePan(recognizer: UIPanGestureRecognizer) {
        let loc = recognizer.location(in: self)
        var delta = recognizer.translation(in: self)
        
        if recognizer.state == .began {
            previousLoc = loc
            touchCount = recognizer.numberOfTouches
        }
        else if recognizer.state == .changed {
            delta = CGPoint.init(x: 2 * (loc.x - previousLoc.x) * panScale, y: 2 * (loc.y - previousLoc.y) * panScale)
            previousLoc = loc
            if touchCount != recognizer.numberOfTouches {
                return
            }
            delegate?.inputControlDidPan(delta)
        }
    }
}

extension UserInputControl: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer === zoomGestureRecognizer, otherGestureRecognizer === tapGestureRecognizer {
            return true
        }
        return false
    }
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer === tapGestureRecognizer {
            let restrictedStates: [UIGestureRecognizer.State] = [
                .possible,
                .cancelled,
                .ended,
                .failed
            ]
            let panIgnored = restrictedStates.contains(panGestureRecognizer.state)
            let zoomIgnored = restrictedStates.contains(zoomGestureRecognizer.state)
            return panIgnored || zoomIgnored
        }
        
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer === panGestureRecognizer {
            return false
        }
        
        if gestureRecognizer === zoomGestureRecognizer {
            return false
        }
        
        return true
    }
}
