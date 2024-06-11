//
//  JoystickView.swift
//  GarudaGame
//
//  Created by Renaldi Antonio on 11/06/24.
//

import Foundation
import SpriteKit
import GameplayKit

class JoystickView: SKNode {
    var joystickBase: SKShapeNode
    var joystickStick: SKShapeNode
    
    var joystickActive = false
    var joystickStartPoint = CGPoint.zero
    
    override init(){
        joystickBase = SKShapeNode(circleOfRadius: 100)
        joystickStick = SKShapeNode(circleOfRadius: 30)
        
        super.init()
        
        joystickBase.alpha = 0.5
        addChild(joystickBase)
        
        joystickStick.fillColor = .gray
        joystickStick.position = joystickBase.position
        addChild(joystickStick)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func joystickTouchesBegan(location: CGPoint) {
        if joystickBase.frame.contains(location) {
            joystickActive = true
            joystickStartPoint = location
            print("touched")
        }
    }
    
    func joystickTouchesMoved(location: CGPoint) -> CGVector? {
        guard joystickActive else {return nil}
        
        let offset = CGPoint(x: location.x - joystickStartPoint.x, y: location.y - joystickStartPoint.y)
        let direction = CGVector(dx: offset.x, dy: offset.y)
        let length = sqrt(direction.dx * direction.dx + direction.dy * direction.dy)
        
        // Limit the stick movement to the joystick base
        let maxDistance: CGFloat = 50
        let clampedDistance = min(length, maxDistance)
        let clampedDirection = CGVector(dx: direction.dx / length * clampedDistance, dy: direction.dy / length * clampedDistance)
        
        joystickStick.position = CGPoint(x: joystickBase.position.x + clampedDirection.dx, y: joystickBase.position.y + clampedDirection.dy)
        
        // Calculate player velocity
        let velocity = CGVector(dx: clampedDirection.dx * 0.1, dy: clampedDirection.dy * 0.2) // Adjust multiplier as needed
        
        return velocity
    }
    
    func joystickTouchesEnded() {
        if joystickActive {
            joystickActive = false
            joystickStick.position = joystickBase.position
        }
    }
}
