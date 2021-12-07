//
//  GameViewController.swift
//  Flight
//
//  Created by Никита Ростовский on 09.11.2021.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {
    private var inputControl: UserInputControl!
    private var scnView: SCNView!
    private var scnScene: SCNScene!
    
    private var world: World!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        world = World()
        
        setupView()
        setupControls()
    }
    
    private func setupView() {
        scnView = SCNView(frame: view.bounds)
        scnView.scene = world
        scnView.showsStatistics = true
        scnView.backgroundColor = .black
        view.addSubview(scnView)
        
        world.view = scnView
    }
    
    private func setupControls() {
        self.inputControl = UserInputControl(frame: view.bounds)
        inputControl.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        inputControl.delegate = self
        view.addSubview(inputControl)
    }
}

extension GameViewController: UserInputControlDelegate {
    func inputControlDidPan(_ translation: CGPoint) {
        world.onPan(translation)
    }
    
    func inputControlDidTap(_ position: CGPoint) {
        world.onTap(position)
    }
    
    func inputControlDidZoom(_ scale: CGFloat) {
        world.onScale(Double(scale))
    }
}
