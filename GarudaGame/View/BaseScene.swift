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
    var attackButton = SKShapeNode()
    var cameraNode = SKCameraNode()
    var healthNodes: [SKShapeNode] = []
    
    var playerVelocity = CGVector.zero
    
    var activeTouches = [UITouch: SKNode]()
    
    
    
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
        dashButton.fillColor = .green
        dashButton.position = CGPoint(x: self.frame.maxX-200, y: self.frame.minY+150)
        cameraNode.addChild(dashButton)
        
        // Setup attack button
        attackButton = SKShapeNode(circleOfRadius: 40)
        attackButton.fillColor = .red
        attackButton.position = CGPoint(x: self.frame.maxX-300, y: self.frame.minY+250)
        cameraNode.addChild(attackButton)
        
        for i in 0..<3 {
            let health = SKShapeNode(circleOfRadius: 20)
            health.fillColor = .red
            health.position = CGPoint(x: self.frame.minX + 100 + CGFloat(i) * 50, y: self.frame.maxY - 100)
            health.zPosition = CGFloat(99)
            healthNodes.append(health)
            cameraNode.addChild(health)
        }
        
        joystick.zPosition = CGFloat(99)
        jumpButton.zPosition = CGFloat(99)
        dashButton.zPosition = CGFloat(99)
        attackButton.zPosition = CGFloat(99)
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
}
