//
//  BaseScene.swift
//  GarudaGame
//
//  Created by Renaldi Antonio on 13/06/24.
//

import Foundation
import SpriteKit
import GameplayKit

class BaseScene: SKScene, SKPhysicsContactDelegate{
    var joystick = JoystickView()
    var dashButton = SKSpriteNode()
    var jumpButton = SKSpriteNode()
    var attackButton = SKSpriteNode()
    var cameraNode = SKCameraNode()
    var healthNodes: [SKShapeNode] = []
    
    var playerVelocity = CGVector.zero
    
    var activeTouches = [UITouch: SKNode]()
    
    var entityManager: EntityManager!
    var garuda: Player!
    var enemies = [Enemy]()
    var dashSystem = DashSystem()
    var bulletSystem = BulletSystem()
    var combatSystem: CombatSystem?
    
    var lastUpdateTime: TimeInterval = 0.0
    
    var joystickDisabled = false
    var attackCooldown = false
    let attackCooldownDuration: TimeInterval = 0.5
    
    var attackButtonStateMachine: GKStateMachine!
    var dashButtonStateMachine: GKStateMachine!
    var jumpButtonStateMachine: GKStateMachine!
    
    var isGarudaWalking = false
    var garudaAnimationStateMachine: GKStateMachine!
    
    var kecrekAnimationStateMachine: GKStateMachine!
    
    var currentScene = ""
    let gameOverNode = GameOverNode()
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        entityManager = EntityManager(scene: self)
        combatSystem = CombatSystem(scene: self)
        camera?.position = (garuda.component(ofType: SpriteComponent.self)?.node.position)!
        
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
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        gameOverNode.touchesBegan(touches, with: event)
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
                if !attackCooldown && garuda.isDashing && garuda.isOnGround == 0 && !garuda.targetEnemies.isEmpty{
                    let target = combatSystem?.closestPoint(from: garuda.targetEnemies, to: garuda.component(ofType: SpriteComponent.self)!.node.position)
                    dashSystem.targettedDash(player: garuda, target: target!)
                    Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { [self] _ in
                        if let player = garuda.component(ofType: SpriteComponent.self)?.node{
                            combatSystem?.spawnHitbox(attacker: player, size: CGSize(width: 150, height: 60), position: CGPoint(x: 0, y: -20))
                        }
                        dashSystem.stopLongDash(player: garuda)
                    }
                    activateAttackCooldown()
                    
                }else if !attackCooldown{
                    if let player = garuda.component(ofType: SpriteComponent.self)?.node{
                        combatSystem?.spawnHitbox(attacker: player, size: CGSize(width: 80, height: 60), position: CGPoint(x: garuda.playerFacing ? 50 : -50, y: 0))
                    }
                    activateAttackCooldown()
                }
            }else if dashButton.frame.contains(cameraLocation){
                dashButtonStateMachine.enter(pressedState)
                if !garuda.dashCooldown && garuda.isOnGround != 0{
                    dashSystem.dash(player: garuda, dashSpeed: 800.0)
                }else if !garuda.dashCooldown && garuda.isOnGround==0 && !garuda.isDashing{
                    dashSystem.longDash(player: garuda, dashSpeed: 400.0, joystick: joystick)
                }else if garuda.isOnGround==0 && garuda.isDashing{
                    dashSystem.stopLongDash(player: garuda)
                }
            }else if jumpButton.frame.contains(cameraLocation){
                jumpButtonStateMachine.enter(pressedState)
                if garuda.isOnGround != 0 {
                    garuda.component(ofType: MovementComponent.self)?.jump()
                }
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
            }else{
                attackButtonStateMachine.enter(normalState)
                dashButtonStateMachine.enter(normalState)
                jumpButtonStateMachine.enter(normalState)
            }
        }
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
        let newX = lerp(a: cameraPosition.x, b: (targetPosition?.x ?? 0), t: 0.1) // Adjust t to control speed
        let newY = lerp(a: cameraPosition.y, b: (targetPosition?.y ?? 0), t: 0.1) // Adjust t to control speed
        cameraNode.position = CGPoint(x: newX, y: newY)
        
        garuda.component(ofType: MovementComponent.self)?.move(playerVelocity: playerVelocity, joystickDisabled: joystickDisabled)
        for kecrek in enemies {
            kecrek.component(ofType: ChaseComponent.self)?.update(deltaTime: 0.1)
        }
        
        dashSystem.playerFacing(player: garuda, Velocity: playerVelocity)
        dashSystem.update(player: garuda, currentTime: currentTime, joystick: joystick)
        
        if garuda.component(ofType: CombatComponent.self)?.health ?? 0 <= 0 {
            garuda.removeComponent(ofType: PhysicComponent.self)
            entityManager.removeEntity(garuda)
            gameOver()
        }
        
        for kecrek in enemies{
            if (combatSystem?.checkIfNodeInBetween(node1: garuda.component(ofType: SpriteComponent.self)?.node, node2: kecrek.component(ofType: SpriteComponent.self)?.node) == false){
                garuda.targetEnemies.append(kecrek.component(ofType: SpriteComponent.self)!.node.position)
            }
            if let rangedKecrek = kecrek as? RangedEnemy {
                if kecrek.isActivated{
                    bulletSystem.update(player: garuda, enemy: rangedKecrek, currentTime: currentTime)
                }
            }
            (combatSystem?.distance(from: garuda.component(ofType: SpriteComponent.self)?.node.position ?? CGPointZero, to: kecrek.component(ofType: SpriteComponent.self)!.node.position))! < 200 ? kecrek.isActivated = true : nil
        }
        
        if abs(playerVelocity.dx) > 0 {
            if !isGarudaWalking {
                garudaAnimationStateMachine.enter(WalkState.self)
                isGarudaWalking = true
            }
            garuda.component(ofType: SpriteComponent.self)?.node.xScale = (garuda.playerFacing ? 1 : -1)
        }else {
            if isGarudaWalking {
                garuda.component(ofType: SpriteComponent.self)?.node.xScale = (garuda.playerFacing ? 1 : -1)
                garudaAnimationStateMachine.enter(IdleState.self)
                isGarudaWalking = false
            }
        }
    }
    
    func summonGaruda(at position: CGPoint) {
        garuda = Player(name: "Garuda", health: 3)
        if let spriteComponent = garuda.component(ofType: SpriteComponent.self) {
            spriteComponent.node.position = position
            
            let garudaIdleState = IdleState(node: spriteComponent.node, name: "Garuda")
            let garudaWalkState = WalkState(node: spriteComponent.node, name: "Garuda")
            
            garudaAnimationStateMachine = GKStateMachine(states: [garudaIdleState, garudaWalkState])
            garudaAnimationStateMachine.enter(IdleState.self)
        }
        
        entityManager.addEntity(garuda)
//        entityManager.startAnimation(garuda)
        entityManager.addPhysic(garuda)
    }
    
    func summonKecrek(at position: CGPoint, type: Int) {
        switch type{
        case 1:
            let kecrek = Enemy(name: "Kecrek", health: 3, target: garuda)
            if let spriteComponent = kecrek.component(ofType: SpriteComponent.self) {
                spriteComponent.node.position = position
            }
            
            entityManager.addEntity(kecrek)
            entityManager.startAnimation(kecrek)
            entityManager.addPhysic(kecrek)
            
            enemies.append(kecrek)
        case 2:
            let kecrek = RangedEnemy(name: "Kecrek", health: 2, target: garuda)
            if let spriteComponent = kecrek.component(ofType: SpriteComponent.self) {
                spriteComponent.node.position = position
            }
            
            entityManager.addEntity(kecrek)
            entityManager.startAnimation(kecrek)
            entityManager.addPhysic(kecrek)
            //            kecrek.shootBullet(target: garuda)
            
            enemies.append(kecrek)
        default:
            break
        }
    }
    
    func setupPlatform(name: String) {
        guard let platform = self.childNode(withName: name) as? SKSpriteNode else {
            fatalError("Node with name \(name) not found or not a SKShapeNode")
        }
        
        platform.physicsBody = SKPhysicsBody(rectangleOf: platform.frame.size)
        platform.physicsBody?.isDynamic = false
        platform.physicsBody?.affectedByGravity = false
        platform.physicsBody?.restitution = 0
        platform.physicsBody?.allowsRotation = false
        platform.physicsBody?.categoryBitMask = PhysicsCategory.platform
        platform.physicsBody?.collisionBitMask = PhysicsCategory.player | PhysicsCategory.enemy | PhysicsCategory.bullet
        platform.physicsBody?.collisionBitMask = PhysicsCategory.bullet | PhysicsCategory.groundChecker
        platform.physicsBody?.friction = 1
    }
    
    /// SETUP LEVEL USING TILE MAP NODE
    func giveTileMapPhysicsBody(map: SKTileMapNode) {
        let tileMap = map // the tile map that we want to give physics body
        let startLocation: CGPoint = tileMap.position // initial position of the tile map
        let tileSize = tileMap.tileSize // the size of each tile map
        let halfWidth = CGFloat(tileMap.numberOfColumns) / 2.0 * tileSize.width // half the width of the tile map
        let halfHeight = CGFloat(tileMap.numberOfRows) / 2.0 * tileSize.height // half height of the tile map
        
        for col in 0..<tileMap.numberOfColumns {
            for row in 0..<tileMap.numberOfRows {
                if let tileDefinition = tileMap.tileDefinition(atColumn: col, row: row) {
                    // initialize variables
                    let tileArray = tileDefinition.textures // stores an array of textures for a specific tile
                    let tileTextures = tileArray[0] // first texture of tileArray
                    let x = CGFloat(col) * tileSize.width - halfWidth + ( tileSize.width / 2 ) // X-coordinate for the current tile's position
                    let y = CGFloat(row) * tileSize.height - halfHeight + ( tileSize.height / 2 ) // Y-coordinate for the current tile's position
                       
                    // Make new sprite node for the tile map
                    let tileNode = SKSpriteNode(texture: tileTextures)
                    tileNode.position = CGPoint(x: x, y: y)
                    tileNode.size = CGSize(width: 64, height: 64)
                    
                    // Give the node some physics body
                    tileNode.physicsBody = SKPhysicsBody(texture: tileTextures, size: CGSize(width: 64, height: 64))
                    
                    // Give some details to the physics body
                    tileNode.physicsBody?.categoryBitMask = PhysicsCategory.platform
                    tileNode.physicsBody?.collisionBitMask = PhysicsCategory.player | PhysicsCategory.enemy | PhysicsCategory.bullet | PhysicsCategory.groundChecker
                    tileNode.physicsBody?.affectedByGravity = false
                    tileNode.physicsBody?.isDynamic = false
                    tileNode.physicsBody?.friction = 1
                    tileNode.physicsBody?.restitution = 0
//                    tileNode.zPosition = 5
                    
                    tileNode.position = CGPoint(x: tileNode.position.x + startLocation.x, y: tileNode.position.y + startLocation.y)
                    self.addChild(tileNode)
                }
            }
        }
    }
    
    //Taking damage
    func didBegin(_ contact: SKPhysicsContact) {
        let nodeA = contact.bodyA.node as? SKSpriteNode
        let nodeB = contact.bodyB.node as? SKSpriteNode
        
        let mask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        switch mask {
        case PhysicsCategory.player | PhysicsCategory.enemy, PhysicsCategory.player | PhysicsCategory.bullet:
            if !(garuda.isDashing || garuda.invincibility) {
                let player = nodeA
                let otherNode = nodeB
                
                garuda.health -= 1
                print(garuda.health)
                
                garuda.invincibility = true
                Timer.scheduledTimer(withTimeInterval: garuda.iFramesTime, repeats: false) { _ in
                    self.garuda.invincibility = false
                }
                
                combatSystem?.knockback(nodeA: player, nodeB: otherNode)
                
                joystickDisabled = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [self] in
                    joystickDisabled = false
                }
                
                if otherNode!.physicsBody?.categoryBitMask == PhysicsCategory.bullet{
                    otherNode!.removeFromParent()
                }
            }
            
        case PhysicsCategory.enemy | PhysicsCategory.hitbox:
            combatSystem?.knockback(nodeA: nodeA, nodeB: garuda.component(ofType: SpriteComponent.self)?.node as? SKSpriteNode)
            for kecrek in enemies{
                if kecrek.component(ofType: SpriteComponent.self)?.node == nodeA {
                    kecrek.component(ofType: CombatComponent.self)?.health -= 1
                }
                if kecrek.component(ofType: CombatComponent.self)?.health == 0 {
                    enemies.remove(kecrek)
                    entityManager.removeEntity(kecrek)
                }
            }
            
        case PhysicsCategory.platform | PhysicsCategory.bullet:
            let bullet = (contact.bodyA.categoryBitMask == PhysicsCategory.bullet ? nodeA : nodeB)
            bullet!.removeAllActions()
            bullet!.removeFromParent()
            
        case PhysicsCategory.groundChecker | PhysicsCategory.platform, PhysicsCategory.platform | PhysicsCategory.groundChecker:
            garuda.isOnGround += 1
            print(garuda.isOnGround)
        default:
            break
        }
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        let mask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        switch mask{
        case PhysicsCategory.platform | PhysicsCategory.groundChecker:
            garuda.isOnGround -= 1
            print(garuda.isOnGround)
        default:
            break
        }
    }
    
    func updateHealthBar() {
        for (index, healthNode) in healthNodes.enumerated() {
            if index < garuda.component(ofType: CombatComponent.self)?.health ?? 0 {
                healthNode.fillColor = .red
            } else {
                healthNode.fillColor = .clear
            }
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
    
    func gameOver(){
        gameOverNode.position = CGPoint(x: frame.midX, y: frame.midY)
        gameOverNode.zPosition = 100
        cameraNode.addChild(gameOverNode)
        
        joystick.isHidden = true
        jumpButton.isHidden = true
        attackButton.isHidden = true
        dashButton.isHidden = true
    }
    
    func restartLevel() {
        if let currentScene = scene {
            let newScene = SKScene(fileNamed: self.currentScene)
            newScene!.scaleMode = currentScene.scaleMode
            let transition = SKTransition.fade(withDuration: 1.0)
            scene?.view?.presentScene(newScene!, transition: transition)
        }
    }
    
    func returnToMainMenu(){
        if let currentScene = scene {
            let newScene = StartMenuScene(size: (view?.bounds.size)!)
            newScene.scaleMode = currentScene.scaleMode
            let transition = SKTransition.fade(withDuration: 1.0)
            scene?.view?.presentScene(newScene, transition: transition)
        }
    }
}
