//
//  BaseScene.swift
//  GarudaGame
//
//  Created by Renaldi Antonio on 13/06/24.
//

import Foundation
import SpriteKit
import GameplayKit

class BaseScene: SKScene{
    var joystick = JoystickView()
    var dashButton = SKShapeNode()
    var jumpButton = SKShapeNode()
    var cameraNode = SKCameraNode()
    
    var playerVelocity = CGVector.zero
    var playerFacing = false
    
    var activeTouches = [UITouch: SKNode]()
    
    // Dash properties
    var isDashing = false
    var dashVelocity = CGVector.zero
    let dashSpeed: CGFloat = 800.0
    let dashDuration: CGFloat = 0.2
    var dashTimeElapsed: CGFloat = 0.0
    
    // Cooldown properties
    var dashCooldown = false
    let dashCooldownDuration: CGFloat = 1.0
    var dashCooldownTimeElapsed: CGFloat = 0.0
    
    override func didMove(to view: SKView) {
        
        cameraNode = SKCameraNode()
        camera = cameraNode
        addChild(cameraNode)
        
        // Setup joystick
        joystick.position = CGPoint(x: -size.width / 2 + 200, y: -size.height / 2 + 200)
        cameraNode.addChild(joystick)
        
        // Setup jump button
        jumpButton = SKShapeNode(circleOfRadius: 40)
        jumpButton.fillColor = .blue
        jumpButton.position = CGPoint(x: self.frame.maxX-100 , y: self.frame.minY+250)
        cameraNode.addChild(jumpButton)
        
        // Setup dash button
        dashButton = SKShapeNode(circleOfRadius: 40)
        dashButton.fillColor = .red
        dashButton.position = CGPoint(x: self.frame.maxX-200, y: self.frame.minY+150)
        cameraNode.addChild(dashButton)
        
        joystick.zPosition = CGFloat(99)
        jumpButton.zPosition = CGFloat(99)
        dashButton.zPosition = CGFloat(99)
    }
    
    override func update(_ currentTime: TimeInterval) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let localLocation = convert(location, to: joystick)
            joystick.joystickTouchesBegan(location: localLocation)
            
            if joystick.joystickBase.frame.contains(localLocation){
                activeTouches[touch] = joystick
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if activeTouches[touch] == joystick {
                let location = touch.location(in: self)
                let localLocation = convert(location, to: joystick)
                if let velocity = joystick.joystickTouchesMoved(location: localLocation){
                    playerVelocity = velocity
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if activeTouches[touch] == joystick  {
                playerVelocity = joystick.joystickTouchesEnded()
                activeTouches.removeValue(forKey: touch)
            }
        }
    }
    
    private var lastUpdateTime: TimeInterval?
    
    func startDash() {
        isDashing = true
        dashTimeElapsed = 0.0
        dashVelocity = playerFacing ? CGVector(dx: dashSpeed, dy: 0) : CGVector(dx: -dashSpeed, dy: 0)
    }
}
