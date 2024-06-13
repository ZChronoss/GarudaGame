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
        // Setup joystick
        joystick.position = CGPoint(x: self.frame.minX + 120, y: self.frame.minY + 100)
        addChild(joystick)
        
        // Setup jump button
        jumpButton = SKShapeNode(circleOfRadius: 25)
        jumpButton.fillColor = .blue
        jumpButton.position = CGPoint(x: self.frame.maxX - 80, y: self.frame.minY + 150)
        addChild(jumpButton)
        
        // Setup dash button
        dashButton = SKShapeNode(circleOfRadius: 25)
        dashButton.fillColor = .red
        dashButton.position = CGPoint(x: self.frame.maxX - 150, y: self.frame.minY + 50)
        addChild(dashButton)
        
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
            
            if joystick.frame.contains(location){
                activeTouches[touch] = joystick
            }
            else if dashButton.frame.contains(location) {
                activeTouches[touch] = dashButton
                if !dashCooldown {
                    startDash()
                }
                
                print("Dash")
            } else if jumpButton.frame.contains(location) {
                // Handle jump button press
//                if isOnGround() {
//                    player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 80))
//                }
                print("Jump")
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            let localLocation = convert(location, to: joystick)
            if let velocity = joystick.joystickTouchesMoved(location: localLocation){
                playerVelocity = velocity
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        playerVelocity = joystick.joystickTouchesEnded()
        for touch in touches {
            if let node = activeTouches[touch] {
                if node == joystick {
                    playerVelocity = joystick.joystickTouchesEnded()
                }
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
    
//    func isOnGround() -> Bool {
//        if let physicsBody = player.physicsBody {
//            let groundContactMask: UInt32 = 0x1 << 1 // Ground category bit mask
//            return physicsBody.allContactedBodies().contains { $0.categoryBitMask & groundContactMask != 0 }
//        }
//        return false
//    }
}
