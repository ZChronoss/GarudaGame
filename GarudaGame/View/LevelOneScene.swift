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
    var kecreks = [Enemy]()
    var dashSystem = DashSystem()
    var combatSystem: CombatSystem?
    
    var rangedEnemy: RangedEnemy!
    var rangedEnemy2: RangedEnemy!
    
    var lastUpdateTime: TimeInterval = 0.0
    
    var joystickDisabled = false
    var jumpCooldown = false
    let jumpCooldownDuration: TimeInterval = 0.5
    var attackCooldown = false
    let attackCooldownDuration: TimeInterval = 0.5
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        super.didMove(to: view)
        entityManager = EntityManager(scene: self)
        garuda = Player(name: "Garuda", health: 1000)
        
        if let spriteComponent = garuda.component(ofType: SpriteComponent.self) {
            spriteComponent.node.position = CGPoint(x: frame.midX-250, y: frame.midY)
        }
        entityManager.addEntity(garuda)
        entityManager.startAnimation(garuda)
        entityManager.addPhysic(garuda)
        
        summonKecrek(at: CGPoint(x: frame.midX + 30, y: frame.midY))
        summonKecrek(at: CGPoint(x: frame.midX + 300, y: frame.midY+100))
        summonKecrek(at: CGPoint(x: frame.midX + 500, y: frame.midY+100))
        
        rangedEnemy = RangedEnemy(name: "Kecrek", health: 3, target: garuda)
        if let spriteComponent = rangedEnemy.component(ofType: SpriteComponent.self) {
            spriteComponent.node.position = CGPoint(x: frame.midX+250, y: frame.midY)
        }
        entityManager.addEntity(rangedEnemy)
        entityManager.startAnimation(rangedEnemy)
        entityManager.addPhysic(rangedEnemy)
        rangedEnemy.shootBullet(target: garuda)
        
        camera?.position = (garuda.component(ofType: SpriteComponent.self)?.node.position)!
        
        let platformNames = (1...7).map { "\($0)" }
        for name in platformNames {
            setupPlatform(name: name)
        }
        
        combatSystem = CombatSystem(scene: self)
        
        
    }
    
    //Taking damage
    func didBegin(_ contact: SKPhysicsContact) {
        let nodeA = contact.bodyA
        let nodeB = contact.bodyB
        
        let mask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        switch mask {
        case PhysicsCategory.player | PhysicsCategory.enemy:
            let player = nodeA.node as? SKSpriteNode
            let otherNode = nodeB.node as? SKSpriteNode
            
            garuda.health -= 1
            print(garuda.health)
            
            combatSystem?.knockback(nodeA: player, nodeB: otherNode)
            
            joystickDisabled = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                self?.joystickDisabled = false
            }
            
        case PhysicsCategory.enemy | PhysicsCategory.hitbox:
            combatSystem?.knockback(nodeA: nodeA.node as? SKSpriteNode, nodeB: garuda.component(ofType: SpriteComponent.self)?.node as? SKSpriteNode)
            for kecrek in kecreks{
                if kecrek.component(ofType: SpriteComponent.self)?.node == nodeA.node {
                    kecrek.component(ofType: CombatComponent.self)?.health -= 1
                }
                if kecrek.component(ofType: CombatComponent.self)?.health == 0 {
                    kecreks.remove(kecrek)
                    entityManager.removeEntity(kecrek)
                }
            }
            
        case PhysicsCategory.bullet | PhysicsCategory.player:
            let player: SKSpriteNode
            let bullet: SKSpriteNode
            if nodeA.categoryBitMask == PhysicsCategory.player {
                player = nodeA.node as! SKSpriteNode
                bullet = nodeB.node as! SKSpriteNode
            }else{
                player = nodeB.node as! SKSpriteNode
                bullet = nodeA.node as! SKSpriteNode
            }
            bullet.removeFromParent()
            combatSystem?.knockback(nodeA: player, nodeB: bullet)
            
        case PhysicsCategory.platform | PhysicsCategory.bullet:
            if let bullet = (nodeA.categoryBitMask == PhysicsCategory.bullet ? nodeA.node : nodeB.node) as? SKSpriteNode {
                bullet.removeAllActions()
                bullet.removeFromParent()
            }
        default:
            break
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
        
        kecreks.append(kecrek)
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
        platform.physicsBody?.categoryBitMask = PhysicsCategory.platform
        platform.physicsBody?.collisionBitMask = PhysicsCategory.player | PhysicsCategory.enemy | PhysicsCategory.bullet
        platform.physicsBody?.friction = 1
    }
    
    func lerp(a: CGFloat, b: CGFloat, t: CGFloat) -> CGFloat {
        return a + (b - a) * t
    }
    
    override func update(_ currentTime: TimeInterval) {
        garuda.targetEnemies = []
        super.update(currentTime)
        // Camera follows player with dampening effect
        let targetPosition = garuda.component(ofType: SpriteComponent.self)?.node.position
        let cameraPosition = cameraNode.position
        
        // Interpolate camera position towards player position
        let newX = lerp(a: cameraPosition.x, b: targetPosition!.x, t: 0.1) // Adjust t to control speed
        let newY = lerp(a: cameraPosition.y, b: targetPosition!.y, t: 0.1) // Adjust t to control speed
        cameraNode.position = CGPoint(x: newX, y: newY)
        
        garuda.component(ofType: MovementComponent.self)?.move(playerVelocity: playerVelocity, joystickDisabled: joystickDisabled)
        for kecrek in kecreks {
            kecrek.component(ofType: ChaseComponent.self)?.update(deltaTime: 0.1)
        }
        
        dashSystem.playerFacing(player: garuda, Velocity: playerVelocity)
        dashSystem.update(player: garuda, currentTime: currentTime, joystick: joystick)
        
        if garuda.health <= 0 {
            garuda.removeComponent(ofType: PhysicComponent.self)
            entityManager.removeEntity(garuda)
        }
        
        for kecrek in kecreks{
            if (combatSystem?.checkIfNodeInBetween(node1: garuda.component(ofType: SpriteComponent.self)!.node, node2: kecrek.component(ofType: SpriteComponent.self)!.node) == false){
                garuda.targetEnemies.append(kecrek.component(ofType: SpriteComponent.self)!.node.position)
            }
        }
        
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        rangedEnemy.timeSinceLastShot += deltaTime
        if rangedEnemy.timeSinceLastShot >= rangedEnemy.shootCooldown {
//            let playerPosition = garuda.component(ofType: PositionComponent.self)!.position
            rangedEnemy.shootBullet(target: garuda)
            rangedEnemy.timeSinceLastShot = 0.0
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
                if !garuda.dashCooldown && isOnGround(){
                    dashSystem.dash(player: garuda, dashSpeed: 800.0)
                }else if !garuda.dashCooldown && !isOnGround() && !garuda.isDashing{
                    dashSystem.longDash(player: garuda, dashSpeed: 400.0, joystick: joystick)
                }else if !isOnGround() && garuda.isDashing{
                    dashSystem.stopLongDash(player: garuda)
                }
            }
            else if attackButton.frame.contains(location) {
                if !attackCooldown && garuda.isDashing && !isOnGround() && !garuda.targetEnemies.isEmpty{
                    let target = CGRect.minimalRect(containing: garuda.targetEnemies)!
                    dashSystem.targettedDash(player: garuda, target: target)
                    Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { [self] _ in
                        combatSystem?.spawnHitbox(attacker: self.garuda.component(ofType: SpriteComponent.self)!.node, size: CGSize(width: 150, height: 60), position: CGPoint(x: 0, y: -20))
                        dashSystem.stopLongDash(player: garuda)
                    }
                    activateAttackCooldown()
                    
                }else if !attackCooldown{
                    combatSystem?.spawnHitbox(attacker: garuda.component(ofType: SpriteComponent.self)!.node, size: CGSize(width: 80, height: 60), position: CGPoint(x: garuda.playerFacing ? 50 : -50, y: 0))
                    activateAttackCooldown()
                }
//                buttonStateMachine.enter(ButtonPressedState.self)
            }
        }
    }
    
    func activateJumpCooldown() {
        jumpCooldown = true
        Timer.scheduledTimer(withTimeInterval: jumpCooldownDuration, repeats: false) { _ in
            self.jumpCooldown = false
        }
    }
    
    func activateAttackCooldown() {
        attackCooldown = true
        Timer.scheduledTimer(withTimeInterval: attackCooldownDuration, repeats: false) { _ in
            self.attackCooldown = false
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
