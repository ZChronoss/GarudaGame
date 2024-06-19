//
//  LevelOneScene.swift
//  GarudaGame
//
//  Created by Renaldi Antonio on 13/06/24.
//

import Foundation
import GameplayKit
import SpriteKit

class LevelOneScene: BaseScene, SKPhysicsContactDelegate{
    var entityManager: EntityManager!
    var garuda: Player!
    var enemies = [Enemy]()
    var dashSystem = DashSystem()
    
    var joystickDisabled = false
    var jumpCooldown = false
    let jumpCooldownDuration: TimeInterval = 0.5
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        super.didMove(to: view)
        entityManager = EntityManager(scene: self)
        garuda = Player(name: "Garuda", health: 3)
        
        if let spriteComponent = garuda.component(ofType: SpriteComponent.self) {
            spriteComponent.node.position = CGPoint(x: frame.midX-250, y: frame.midY)
        }
        entityManager.addEntity(garuda)
        entityManager.startAnimation(garuda)
        entityManager.addPhysic(garuda)
        
        summonKecrek(at: CGPoint(x: frame.midX + 30, y: frame.midY))
        summonKecrek(at: CGPoint(x: frame.midX + 300, y: frame.midY+100))
        
        camera?.position = (garuda.component(ofType: SpriteComponent.self)?.node.position)!
        
        let platformNames = (1...7).map { "\($0)" }
        for name in platformNames {
            setupPlatform(name: name)
        }
    }
    
    //Taking damage
    func didBegin(_ contact: SKPhysicsContact) {
        let nodeA = contact.bodyA
        let nodeB = contact.bodyB
        
        if (nodeA.contactTestBitMask == 0x1 << 2 && nodeB.contactTestBitMask == 0x1 << 1) || (nodeA.contactTestBitMask == 0x1 << 1 && nodeB.contactTestBitMask == 0x1 << 2)
        {
            let player = nodeA.node as! SKSpriteNode
            let otherNode = nodeB.node as! SKSpriteNode
            
            garuda.health -= 1
            
            // Calculate the direction of the knockback
            let knockbackVector = CGVector(dx: player.position.x - otherNode.position.x, dy: player.position.y - otherNode.position.y)
            
            // Normalize the knockback vector
            let length = sqrt(knockbackVector.dx * knockbackVector.dx + knockbackVector.dy * knockbackVector.dy)
            let normalizedVector = CGVector(dx: knockbackVector.dx / length, dy: knockbackVector.dy / length)
            
            // Apply the impulse to the garuda
            let knockbackStrength: CGFloat = 80.0 // Adjust this value as needed
            let impulse = CGVector(dx: normalizedVector.dx * knockbackStrength, dy: normalizedVector.dy * knockbackStrength)
            player.physicsBody?.applyImpulse(impulse)
            
            joystickDisabled = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                self?.joystickDisabled = false
            }
        }
    }
    
    func summonKecrek(at position: CGPoint) {
        let kecrek = Enemy(name: "Kecrek", health: 3, target: garuda)

        if let spriteComponent = kecrek.component(ofType: SpriteComponent.self) {
            spriteComponent.node.position = position
        }

        entityManager.addEntity(kecrek)
        entityManager.startAnimation(kecrek)
        entityManager.addPhysic(kecrek)
        
        enemies.append(kecrek)
    }
    
    func setupPlatform(name: String) {
        guard let platform = self.childNode(withName: name) as? SKShapeNode else {
            fatalError("Node with name \(name) not found or not a SKShapeNode")
        }
        
        platform.physicsBody = SKPhysicsBody(rectangleOf: platform.frame.size)
        platform.physicsBody?.isDynamic = false
        platform.physicsBody?.affectedByGravity = false
        platform.physicsBody?.restitution = 0
        platform.physicsBody?.allowsRotation = false
        platform.physicsBody?.categoryBitMask = 0x1 << 3
        platform.physicsBody?.collisionBitMask = 0x1 << 1 | 0x1 << 2
    }
    
    func lerp(a: CGFloat, b: CGFloat, t: CGFloat) -> CGFloat {
        return a + (b - a) * t
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        // Camera follows player with dampening effect
        let targetPosition = garuda.component(ofType: SpriteComponent.self)?.node.position
        let cameraPosition = cameraNode.position
        
        // Interpolate camera position towards player position
        let newX = lerp(a: cameraPosition.x, b: targetPosition!.x, t: 0.1) // Adjust t to control speed
        let newY = lerp(a: cameraPosition.y, b: targetPosition!.y, t: 0.1) // Adjust t to control speed
        cameraNode.position = CGPoint(x: newX, y: newY)
        
        garuda.component(ofType: MovementComponent.self)?.move(playerVelocity: playerVelocity, joystickDisabled: joystickDisabled)
        for enemy in enemies {
            enemy.component(ofType: ChaseComponent.self)?.update(deltaTime: 0.1)
        }
        
        dashSystem.playerFacing(player: garuda, Velocity: playerVelocity)
        dashSystem.update(player: garuda, currentTime: currentTime, joystick: joystick)
        
        // Optionally, remove node3 if health is zero or less
        if garuda.health <= 0 {
            garuda.component(ofType: SpriteComponent.self)?.node.removeFromParent()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        for touch in touches {
            let location = touch.location(in: cameraNode)
            
            if jumpButton.frame.contains(location) {
                if isOnGround() && !jumpCooldown {
                    garuda.component(ofType: MovementComponent.self)?.jump()
                    activateJumpCooldown()
                }
            }else if dashButton.frame.contains(location) {
                if !dashCooldown && isOnGround(){
                    dashSystem.dash(player: garuda, dashSpeed: 800.0)
                }else if !dashCooldown && !isOnGround() && !isDashing{
                    dashSystem.longDash(player: garuda, dashSpeed: 400.0, joystick: joystick)
                }else if !isOnGround() && isDashing{
                    dashSystem.stopLongDash(player: garuda)
                }
            }
        }
    }
    
    func activateJumpCooldown() {
        jumpCooldown = true
        Timer.scheduledTimer(withTimeInterval: jumpCooldownDuration, repeats: false) { _ in
            self.jumpCooldown = false
        }
    }
    
    func isOnGround() -> Bool {
        for platform in self.children {
            if let platformNode = platform as? SKShapeNode, platformNode.name != nil {
                if garuda.component(ofType: PhysicComponent.self)?.physicBody.allContactedBodies().contains(platformNode.physicsBody!) ?? false {
                    return true
                }
            }
        }
        return false
    }
    
}
