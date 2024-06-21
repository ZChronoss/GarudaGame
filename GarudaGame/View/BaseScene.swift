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
    var dashButton = SKSpriteNode()
    var jumpButton = SKSpriteNode()
    var attackButton = SKSpriteNode()
    var cameraNode = SKCameraNode()
    
    var playerVelocity = CGVector.zero
    
    var activeTouches = [UITouch: SKNode]()
    
    var attackButtonStateMachine: GKStateMachine!
    var dashButtonStateMachine: GKStateMachine!
    var jumpButtonStateMachine: GKStateMachine!
    
    override func didMove(to view: SKView) {
        cameraNode = SKCameraNode()
        camera = cameraNode
        addChild(cameraNode)
        
        // Setup joystick
        joystick.position = CGPoint(x: -size.width / 2 + 200, y: -size.height / 2 + 200)
        cameraNode.addChild(joystick)
        
        // Setup jump button
        jumpButton = SKSpriteNode()
        jumpButton.size = CGSize(width: 70, height: 70)
        jumpButton.position = CGPoint(x: self.frame.maxX-100 , y: self.frame.minY+250)
        cameraNode.addChild(jumpButton)
        
        // Setup dash button
        dashButton = SKSpriteNode()
        dashButton.size = CGSize(width: 70, height: 70)
        dashButton.position = CGPoint(x: self.frame.maxX-200, y: self.frame.minY+150)
        cameraNode.addChild(dashButton)
        
        // Setup attack button
        attackButton = SKSpriteNode()
        attackButton.size = CGSize(width: 100, height: 100)
        attackButton.position = CGPoint(x: self.frame.maxX-300, y: self.frame.minY+250)
        cameraNode.addChild(attackButton)
        
        joystick.zPosition = CGFloat(99)
        jumpButton.zPosition = CGFloat(99)
        dashButton.zPosition = CGFloat(99)
        attackButton.zPosition = CGFloat(99)
        
        // Attack Button State
        let attackDesc = "AttackButton"
        let atkBtnNormal = ButtonNormalState(button: attackButton, action: attackDesc)
        let atkBtnPressed = ButtonPressedState(button: attackButton, action: attackDesc)
        attackButtonStateMachine = GKStateMachine(states: [atkBtnNormal, atkBtnPressed])
        attackButtonStateMachine.enter(ButtonNormalState.self)
        
        // Dash Button State
        let dashDesc = "DashButton"
        let dashBtnNormal = ButtonNormalState(button: dashButton, action: dashDesc)
        let dashBtnPressed = ButtonPressedState(button: dashButton, action: dashDesc)
        dashButtonStateMachine = GKStateMachine(states: [dashBtnNormal, dashBtnPressed])
        dashButtonStateMachine.enter(ButtonNormalState.self)
        
        // Jump Button State
        let jumpDesc = "JumpButton"
        let jumpBtnNormal = ButtonNormalState(button: jumpButton, action: jumpDesc)
        let jumpBtnPressed = ButtonPressedState(button: jumpButton, action: jumpDesc)
        jumpButtonStateMachine = GKStateMachine(states: [jumpBtnNormal, jumpBtnPressed])
        jumpButtonStateMachine.enter(ButtonNormalState.self)
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
            
            let cameraLocation = touch.location(in: cameraNode)
            let pressedState = ButtonPressedState.self
            if attackButton.frame.contains(cameraLocation){
                attackButtonStateMachine.enter(pressedState)
            }else if dashButton.frame.contains(cameraLocation){
                dashButtonStateMachine.enter(pressedState)
            }else if jumpButton.frame.contains(cameraLocation){
                jumpButtonStateMachine.enter(pressedState)
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
            
            let location = touch.location(in: cameraNode)
            let normalState = ButtonNormalState.self
            if attackButton.frame.contains(location){
                attackButtonStateMachine.enter(normalState)
            }else if dashButton.frame.contains(location){
                dashButtonStateMachine.enter(normalState)
            }else if jumpButton.frame.contains(location){
                jumpButtonStateMachine.enter(normalState)
            }
        }
    }
}
