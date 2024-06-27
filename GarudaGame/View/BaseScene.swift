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
    var backgroundPic = SKSpriteNode()
    var slamIndicator = SKShapeNode()
    var slamIndicator2 = SKShapeNode()
    var longDashIndicator = SKShapeNode()
    var longDashIndicator2 = SKShapeNode()
    var cameraNode = SKCameraNode()
    var healthNodes: [SKSpriteNode] = []
    
    var playerVelocity = CGVector.zero
    
    var activeTouches = [UITouch: SKNode]()
    
    var entityManager: EntityManager!
    var garuda: Player!
    var enemies = [Enemy]()
    var tirtaAmerta: Objective!
    var dashSystem: DashSystem?
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
    
    var kecrekAnimationStateMachine: [GKStateMachine]!
    
    var currentScene = ""
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        entityManager = EntityManager(scene: self)
        combatSystem = CombatSystem(scene: self)
        dashSystem = DashSystem(scene: self)
        camera?.position = (garuda.component(ofType: SpriteComponent.self)?.node.position)!
        
        cameraNode = SKCameraNode()
        camera = cameraNode
        addChild(cameraNode)
        
        // Setup joystick
        joystick.position = CGPoint(x: -size.width / 2 + 225, y: -size.height / 2 + 225)
        cameraNode.addChild(joystick)
        
        // Setup jump button
        jumpButton = SKSpriteNode()
        jumpButton.size = CGSize(width: 100, height: 100)
        jumpButton.position = CGPoint(x: self.frame.maxX-130 , y: self.frame.minY+250)
        cameraNode.addChild(jumpButton)
        
        // Setup dash button
        dashButton = SKSpriteNode()
        dashButton.size = CGSize(width: 100, height: 100)
        dashButton.position = CGPoint(x: self.frame.maxX-230, y: self.frame.minY+150)
        cameraNode.addChild(dashButton)
        
        // Setup attack button
        attackButton = SKSpriteNode()
        attackButton.size = CGSize(width: 140, height: 140)
        attackButton.position = CGPoint(x: self.frame.maxX-300, y: self.frame.minY+280)
        cameraNode.addChild(attackButton)
        
        backgroundPic = SKSpriteNode()
        backgroundPic.texture = SKTexture(imageNamed: "BackgroundNode")
        backgroundPic.size = CGSize(width: self.size.width, height: self.size.height)
        backgroundPic.zPosition = -5
        cameraNode.addChild(backgroundPic)
        
        slamIndicator = createIndicator(circleRadius: 60, initialDelay: 0, repeatInterval: 1, parentNode: attackButton)
        slamIndicator2 = createIndicator(circleRadius: 60, initialDelay: 0.5, repeatInterval: 1, parentNode: attackButton)
        longDashIndicator = createIndicator(circleRadius: 36, initialDelay: 0, repeatInterval: 1, parentNode: dashButton)
        longDashIndicator2 = createIndicator(circleRadius: 36, initialDelay: 0.3, repeatInterval: 1, parentNode: dashButton)
        
        for i in 0..<5 {
            let health = SKSpriteNode(imageNamed: "Heart_Full")
            health.size = CGSize(width: 50, height: 50)
            health.position = CGPoint(x: self.frame.minX + 100 + CGFloat(i) * 50, y: self.frame.maxY - 150)
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
                if !attackCooldown && garuda.isLongDashing && !garuda.targetEnemies.isEmpty{
                    let target = combatSystem?.closestPoint(from: garuda.targetEnemies, to: garuda.component(ofType: SpriteComponent.self)!.node.position)
                    if (combatSystem?.distance(from: garuda.component(ofType: SpriteComponent.self)!.node.position, to: target!))!<600{
                        dashSystem?.targettedDash(player: garuda, target: target!)
                        garuda.invincibility = true
                        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { [self] _ in
                            if let player = garuda.component(ofType: SpriteComponent.self)?.node{
                                combatSystem?.spawnHitbox(attacker: player, size: CGSize(width: 150, height: 60), position: CGPoint(x: 0, y: 0))
                            }
                        }
                        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [self] _ in
                            garuda.invincibility = false
                        }
                        dashSystem?.stopLongDash(player: garuda)
                        activateAttackCooldown()
                    }else{
                        if let player = garuda.component(ofType: SpriteComponent.self)?.node{
                            combatSystem?.spawnHitbox(attacker: player, size: CGSize(width: 80, height: 60), position: CGPoint(x: garuda.playerFacing ? 50 : -50, y: 0))
                        }
                        activateAttackCooldown()
                    }
                }else if !attackCooldown{
                    if let player = garuda.component(ofType: SpriteComponent.self)?.node{
                        combatSystem?.spawnHitbox(attacker: player, size: CGSize(width: 80, height: 60), position: CGPoint(x: garuda.playerFacing ? 50 : -50, y: 0))
                    }
                    garudaAnimationStateMachine.enter(AttackState.self)
                    activateAttackCooldown()
                }
            }else if dashButton.frame.contains(cameraLocation){
                dashButtonStateMachine.enter(pressedState)
                if !garuda.dashCooldown && (garuda.isOnGround != 0 || garuda.isOnPlatform != 0){
                    dashSystem?.dash(player: garuda, dashSpeed: 800.0)
                    garudaAnimationStateMachine.enter(DashState.self)
                }else if !garuda.dashCooldown && (garuda.isOnGround == 0 && garuda.isOnPlatform == 0) && !garuda.isDashing{
                    dashSystem?.longDash(player: garuda, dashSpeed: 400.0, joystick: joystick)
                }else if garuda.isLongDashing{
                    dashSystem?.stopLongDash(player: garuda)
                }
            }else if jumpButton.frame.contains(cameraLocation){
                jumpButtonStateMachine.enter(pressedState)
                if garuda.isOnGround != 0 || garuda.isOnPlatform != 0{
                    garuda.component(ofType: MovementComponent.self)?.jump()
                    garudaAnimationStateMachine.enter(JumpState.self)
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
        
        dashSystem?.playerFacing(player: garuda, Velocity: playerVelocity)
        dashSystem?.update(player: garuda, currentTime: currentTime, joystick: joystick)
        
        if garuda.component(ofType: CombatComponent.self)?.health ?? 0 <= 0 {
            garuda.removeComponent(ofType: PhysicComponent.self)
            entityManager.removeEntity(garuda)
            let nextScene = GameOverScene(size: self.view!.bounds.size)
            nextScene.scaleMode = .aspectFill
            let transition = SKTransition.fade(withDuration: 1.0)
            self.view?.presentScene(nextScene, transition: transition)
        }
        
        if garuda.component(ofType: SpriteComponent.self) != nil {
            if garuda.isOnGround == 0 && garuda.isOnPlatform == 0 {
                longDashIndicator.isHidden = false
                longDashIndicator2.isHidden = false
            } else {
                longDashIndicator.isHidden = true
                longDashIndicator2.isHidden = true
            }
            for kecrek in enemies{
                if (combatSystem?.checkIfNodeInBetween(node1: garuda.component(ofType: SpriteComponent.self)?.node, node2: kecrek.component(ofType: SpriteComponent.self)?.node) == false){
                    let pos = kecrek.component(ofType: SpriteComponent.self)!.node.position
                    garuda.targetEnemies.append(pos)
                    if (combatSystem?.distance(from: garuda.component(ofType: SpriteComponent.self)!.node.position, to: pos))!<600 && garuda.isLongDashing{
                        slamIndicator.isHidden = false
                        slamIndicator2.isHidden = false
                    }else{
                        slamIndicator.isHidden = true
                        slamIndicator2.isHidden = true
                    }
                }
                if let rangedKecrek = kecrek as? RangedEnemy {
                    if rangedKecrek.isActivated{
                        bulletSystem.update(player: garuda, enemy: rangedKecrek, currentTime: currentTime)
                    }
                }
                (combatSystem?.distance(from: garuda.component(ofType: SpriteComponent.self)?.node.position ?? CGPointZero, to: kecrek.component(ofType: SpriteComponent.self)!.node.position))! < 200 ? kecrek.isActivated = true : nil
            }
        }
        
        if abs(playerVelocity.dx) > 0 {
            if !isGarudaWalking {
                garudaAnimationStateMachine.enter(WalkState.self)
                isGarudaWalking = true
            }
            let newGaruda = garuda.component(ofType: SpriteComponent.self)?.node.childNode(withName: "Garuda")
            newGaruda?.xScale = (garuda.playerFacing ? 1 : -1)
        }else {
            if isGarudaWalking {
                if let newGaruda = garuda.component(ofType: SpriteComponent.self)?.node.childNode(withName: "Garuda") {
                    newGaruda.xScale = (garuda.playerFacing ? 1 : -1)
                }
                
                garudaAnimationStateMachine.enter(IdleState.self)
                isGarudaWalking = false
            }
        }
    }
    
    func makeNewNode(oldNode: SKSpriteNode) -> SKSpriteNode{
        let newNode = SKSpriteNode(texture: oldNode.texture)
        newNode.size = oldNode.size
        newNode.name = oldNode.name
        
        oldNode.texture = nil
        oldNode.addChild(newNode)
        
        return newNode
    }
    
    
    func createIndicator(circleRadius: CGFloat, initialDelay: TimeInterval, repeatInterval: TimeInterval, parentNode: SKNode) -> SKShapeNode {
        let indicator = SKShapeNode(circleOfRadius: circleRadius)
        indicator.isHidden = true
        parentNode.addChild(indicator)
        
        Timer.scheduledTimer(withTimeInterval: initialDelay, repeats: false) { _ in
            Timer.scheduledTimer(withTimeInterval: repeatInterval, repeats: true) { _ in
                indicator.setScale(1)
                indicator.alpha = 1
                indicator.run(SKAction.scale(by: 2, duration: repeatInterval))
                indicator.run(SKAction.fadeAlpha(by: -1, duration: repeatInterval))
            }
        }
        
        return indicator
    }
    
    func summonGaruda(at position: CGPoint) {
        garuda = Player(name: "Garuda", health: 5)
        if let spriteComponent = garuda.component(ofType: SpriteComponent.self) {
            spriteComponent.node.name = "Garuda"
            let newNode = makeNewNode(oldNode: spriteComponent.node)
            spriteComponent.node.position = position
            
            /// GARUDA STATES
            let garudaIdleState     = IdleState(node: newNode, name: "Garuda")
            let garudaWalkState     = WalkState(node: newNode, name: "Garuda")
            let garudaJumpState     = JumpState(node: newNode, name: "Garuda")
            let garudaAttackState   = AttackState(node: newNode, name: "Garuda")
            let garudaDashState     = DashState(node: newNode, name: "Garuda")
            
            garudaAnimationStateMachine = GKStateMachine(states: [garudaIdleState, garudaWalkState, garudaJumpState, garudaAttackState, garudaDashState])
            garudaAnimationStateMachine.enter(IdleState.self)
        }
        
        entityManager.addEntity(garuda)
        //        entityManager.startAnimation(garuda)
        entityManager.addPhysic(garuda)
    }
    
    func summonObjective(at position: CGPoint) {
        tirtaAmerta = Objective(name: "TirtaAmerta")
        if let spriteComponent = tirtaAmerta.component(ofType: SpriteComponent.self) {
            spriteComponent.node.position = position
        }
        
        entityManager.addEntity(tirtaAmerta)
        //        entityManager.startAnimation(garuda)
        entityManager.addPhysic(tirtaAmerta)
    }
    
    func summonKecrek(at position: CGPoint, type: Int) {
        switch type{
        case 1:
            let kecrek = Enemy(name: "Kecrek", health: 3, target: garuda)
            if let spriteComponent = kecrek.component(ofType: SpriteComponent.self)?.node {
                //                spriteComponent.name = "Kecrek"
                //                let newNode = makeNewNode(oldNode: spriteComponent)
                spriteComponent.position = position
            }
            entityManager.addEntity(kecrek)
            //            entityManager.startAnimation(kecrek)
            entityManager.addPhysic(kecrek)
            
            enemies.append(kecrek)
        case 2:
            let kecrek = RangedEnemy(name: "Kecrek", health: 2, target: garuda)
            if let spriteComponent = kecrek.component(ofType: SpriteComponent.self)?.node{
                spriteComponent.position = position
            }
            
            entityManager.addEntity(kecrek)
            //            entityManager.startAnimation(kecrek)
            entityManager.addPhysic(kecrek)
            //            kecrek.shootBullet(target: garuda)
            
            enemies.append(kecrek)
        default:
            break
        }
    }
    
    /// SETUP LEVEL USING TILE MAP NODE
    func giveTileMapPhysicsBody(map: SKTileMapNode) {
        let tileMap = map
        let tileSize = tileMap.tileSize
        let halfWidth = CGFloat(tileMap.numberOfColumns) / 2.0 * tileSize.width
        let halfHeight = CGFloat(tileMap.numberOfRows) / 2.0 * tileSize.height

        for col in 0..<tileMap.numberOfColumns {
            for row in 0..<tileMap.numberOfRows {
                if let tileDefinition = tileMap.tileDefinition(atColumn: col, row: row) {
                    // Determine the tile's position
                    let x = CGFloat(col) * tileSize.width - halfWidth + (tileSize.width / 2)
                    let y = CGFloat(row) * tileSize.height - halfHeight + (tileSize.height / 2)
                    let tilePosition = CGPoint(x: x, y: y)

                    // Initialize variables
                    let tileArray = tileDefinition.textures
                    let tileTexture = tileArray[0]

                    // Create a physics body directly
                    let physicsBody: SKPhysicsBody
                    let platDesc = tileTexture.description

                    if platDesc.contains("Dirt_Top") || platDesc.contains("Dirt_Deep") {
                        physicsBody = SKPhysicsBody(rectangleOf: tileSize)
                        physicsBody.categoryBitMask = PhysicsCategory.platform
                        physicsBody.collisionBitMask = PhysicsCategory.enemy | PhysicsCategory.bullet
                        physicsBody.contactTestBitMask = PhysicsCategory.bullet | PhysicsCategory.groundChecker
                    } else if platDesc.contains("Spike") {
                        physicsBody = SKPhysicsBody(rectangleOf: tileSize)
                        physicsBody.categoryBitMask = PhysicsCategory.spike
                        physicsBody.collisionBitMask = PhysicsCategory.player | PhysicsCategory.enemy | PhysicsCategory.bullet
                        physicsBody.contactTestBitMask = PhysicsCategory.player
                    } else if platDesc.contains("Platform") {
                        let platformSize = CGSize(width: tileSize.width, height: 24)
                        physicsBody = SKPhysicsBody(rectangleOf: platformSize)
                        physicsBody.categoryBitMask = PhysicsCategory.softPlatform
                        physicsBody.contactTestBitMask = PhysicsCategory.platformChecker
                    } else {
                        // Skip tiles that don't match the criteria
                        continue
                    }

                    physicsBody.usesPreciseCollisionDetection = true
                    physicsBody.affectedByGravity = false
                    physicsBody.isDynamic = false
                    physicsBody.friction = 1
                    physicsBody.restitution = 0

                    let tileNode = SKSpriteNode(texture: tileTexture)
                    tileNode.position = CGPoint(x: tilePosition.x + tileMap.position.x, y: tilePosition.y + tileMap.position.y)
                    tileNode.physicsBody = physicsBody
                    tileNode.size = tileSize

                    self.addChild(tileNode)
                }
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let nodeA = contact.bodyA.node as? SKSpriteNode
        let nodeB = contact.bodyB.node as? SKSpriteNode
        
        let mask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        switch mask {
        case PhysicsCategory.player | PhysicsCategory.enemy, PhysicsCategory.player | PhysicsCategory.bullet:
            if !(garuda.isDashing || garuda.invincibility) {
                let otherNode = contact.bodyA.categoryBitMask != PhysicsCategory.player ? nodeA : nodeB
                
                garuda.component(ofType: CombatComponent.self)?.health -= 1
                updateHealthBar()
                
                garuda.invincibility = true
                Timer.scheduledTimer(withTimeInterval: garuda.iFramesTime, repeats: false) { _ in
                    self.garuda.invincibility = false
                }
                
                combatSystem?.knockback(nodeA: garuda.component(ofType: SpriteComponent.self)?.node, knockup: 1, knockback: garuda.playerFacing ? -1 : 1)
                
                joystickDisabled = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [self] in
                    joystickDisabled = false
                }
                
                if otherNode?.physicsBody?.categoryBitMask == PhysicsCategory.bullet{
                    otherNode?.removeFromParent()
                }
            }
            
        case PhysicsCategory.enemy | PhysicsCategory.hitbox, PhysicsCategory.hitbox | PhysicsCategory.enemy:
            for kecrek in enemies{
                if kecrek.component(ofType: SpriteComponent.self)?.node == nodeA {
                    if garuda.isLongDashing{
                        combatSystem?.knockback(nodeA: kecrek.component(ofType: SpriteComponent.self)?.node, knockup: 2, knockback: garuda.playerFacing ? 2 : -2)
                    }else{
                        combatSystem?.knockback(nodeA: kecrek.component(ofType: SpriteComponent.self)?.node, knockup: 1, knockback: garuda.playerFacing ? 1 : -1)
                    }
                    kecrek.component(ofType: CombatComponent.self)?.health -= 1
                    kecrek.component(ofType: HealthBarComponent.self)?.takeDamage(1)
                }
                if kecrek.component(ofType: CombatComponent.self)?.health == 0 {
                    enemies.remove(kecrek)
                    entityManager.removeEntity(kecrek)
                }
            }
            
        case PhysicsCategory.platform | PhysicsCategory.bullet:
            let bullet = (contact.bodyA.categoryBitMask == PhysicsCategory.bullet ? nodeA : nodeB)
            bullet?.removeAllActions()
            bullet?.removeFromParent()
            
        case PhysicsCategory.groundChecker | PhysicsCategory.platform, PhysicsCategory.platform | PhysicsCategory.groundChecker, PhysicsCategory.groundChecker | PhysicsCategory.spike:
            if garuda.isOnGround<2{
                garuda.isOnGround += 1
            }
            //            print("Garuda ground: ", garuda.isOnGround)
        case PhysicsCategory.player | PhysicsCategory.spike:
            if !garuda.invincibility {
                garuda.component(ofType: CombatComponent.self)?.health -= 1
                updateHealthBar()
                garuda.invincibility = true
                combatSystem?.knockback(nodeA: garuda.component(ofType: SpriteComponent.self)?.node, knockup: 1, knockback: garuda.playerFacing ? -1 : 1)
                Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
                    self.garuda.invincibility = false
                }
            }
        case PhysicsCategory.platformChecker | PhysicsCategory.softPlatform:
            garuda.isOnPlatform += 1
            //            print("Garuda platform: ", garuda.isOnPlatform)
            if garuda.isOnPlatform != 0{
                garuda.component(ofType: PhysicComponent.self)?.physicBody.collisionBitMask = PhysicsCategory.platform | PhysicsCategory.softPlatform
            }
        case PhysicsCategory.platform | PhysicsCategory.enemyGroundChecker, PhysicsCategory.softPlatform | PhysicsCategory.enemyGroundChecker:
            let enemyGroundHitbox = (contact.bodyA.categoryBitMask == PhysicsCategory.enemyGroundChecker ? nodeA : nodeB)
            let enemy = enemyGroundHitbox?.parent
            //            enemy.component(ofType: ChaseComponent.self)?.wanderingCooldown = true
            for kecrek in enemies{
                if kecrek.component(ofType: SpriteComponent.self)?.node == enemy{
                    kecrek.isOnEdge+=1
                    break
                }
            }
        case PhysicsCategory.objective | PhysicsCategory.player:
            tirtaAmerta.isDone = true
            tirtaAmerta.component(ofType: SpriteComponent.self)?.node.isHidden = true
            let nextScene = GameEndScene(size: self.view!.bounds.size)
            nextScene.scaleMode = .aspectFill
            let transition = SKTransition.fade(withDuration: 1.0)
            self.view?.presentScene(nextScene, transition: transition)
        default:
            break
        }
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        let nodeA = contact.bodyA.node as? SKSpriteNode
        let nodeB = contact.bodyB.node as? SKSpriteNode
        
        let mask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        switch mask{
        case PhysicsCategory.platform | PhysicsCategory.groundChecker, PhysicsCategory.groundChecker | PhysicsCategory.platform, PhysicsCategory.spike | PhysicsCategory.groundChecker, PhysicsCategory.groundChecker | PhysicsCategory.spike:
            if garuda.isOnGround>0{
                garuda.isOnGround -= 1
            }
            print("Garuda ground: ", garuda.isOnGround)
        case PhysicsCategory.platformChecker | PhysicsCategory.softPlatform, PhysicsCategory.softPlatform | PhysicsCategory.platformChecker:
            garuda.isOnPlatform -= 1
            print("Garuda platform: ", garuda.isOnPlatform)
            if (garuda.isOnPlatform == 0){
                garuda.component(ofType: PhysicComponent.self)?.physicBody.collisionBitMask = PhysicsCategory.platform
            }
        case PhysicsCategory.platform | PhysicsCategory.enemyGroundChecker, PhysicsCategory.softPlatform | PhysicsCategory.enemyGroundChecker:
            let enemyGroundHitbox = (contact.bodyA.categoryBitMask == PhysicsCategory.enemyGroundChecker ? nodeA : nodeB)
            let enemy = enemyGroundHitbox?.parent
            //            enemy.component(ofType: ChaseComponent.self)?.wanderingCooldown = true
            for kecrek in enemies{
                if kecrek.component(ofType: SpriteComponent.self)?.node == enemy{
                    kecrek.isOnEdge-=1
                    if kecrek.isOnEdge==1{
                        kecrek.component(ofType: ChaseComponent.self)?.wanderingCooldown = true
                    }
                    break
                }
            }
        default:
            break
        }
    }
    
    func updateHealthBar() {
        let health = garuda.component(ofType: CombatComponent.self)?.health ?? 0
        for (index, healthNode) in healthNodes.enumerated() {
            let textureName = index < health ? "Heart_Full" : "Heart_Empty"
            healthNode.texture = SKTexture(imageNamed: textureName)
        }
    }
    
    func activateAttackCooldown() {
        attackCooldown = true
        Timer.scheduledTimer(withTimeInterval: attackCooldownDuration, repeats: false) { _ in
            self.attackCooldown = false
        }
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
