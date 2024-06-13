import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var player = SKSpriteNode()
    var platform = SKShapeNode()
    
    var jumpButton = SKShapeNode()
    var dashButton = SKShapeNode()
    var longDashButton = SKShapeNode()
    
    var playerVelocity = CGVector.zero
    var playerFacing = false
    
    var activeTouches = [UITouch: SKNode]()
    
    // Dash properties
    var isDashing = false
    var dashVelocity = CGVector.zero
    let dashSpeed: CGFloat = 800.0
    let longDashSpeed: CGFloat = 400.0
    let dashDuration: CGFloat = 0.2
    var dashTimeElapsed: CGFloat = 0.0
    
    // Cooldown properties
    var dashCooldown = false
    let dashCooldownDuration: CGFloat = 1.0
    var dashCooldownTimeElapsed: CGFloat = 0.0
    
    var joystick = JoystickView()
    
    
    let kecrek = Enemy(name: "Kecrek")
    
    var entityManager: EntityManager!
    
    override func didMove(to view: SKView) {
//        load entity manager
        entityManager = EntityManager(scene: self)
        
//        Load entity enemy bernama "Kecrek"
        let kecrek = Enemy(name: "Kecrek")
        if let spriteComponent = kecrek.component(ofType: SpriteComponent.self) {
            spriteComponent.node.position = CGPoint(x: frame.midX, y: frame.midY)
//            spriteComponent.node.size = CGSize(width: 80, height: 80)
        }
        entityManager.addEntity(kecrek)
        entityManager.addPhysic(kecrek)
        entityManager.startAnimation(kecrek)
        
//        kecrek.addComponent(AnimationComponent())
//        addChild(kecrek.texture)
        // Setup player
        player = SKSpriteNode(color: .red, size: CGSize(width: 50, height: 50))
        player.position = CGPoint(x: 0, y: 0)
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.isDynamic = true
        player.physicsBody?.affectedByGravity = true
        player.physicsBody?.restitution = 0
        player.physicsBody?.allowsRotation = false
        addChild(player)

        let platformNames = ["a", "aa", "aaa", "aaaa"]
        for name in platformNames {
            setupPlatform(name: name)
        }
        
        joystick.position = CGPoint(x: -size.width / 2 + 200, y: -size.height / 2 + 200)
        addChild(joystick)
        
        // Setup jump button
        jumpButton = SKShapeNode(circleOfRadius: 40)
        jumpButton.fillColor = .blue
        jumpButton.position = CGPoint(x: self.frame.maxX - 100, y: self.frame.minY + 250)
        addChild(jumpButton)
        
        // Setup dash button
        dashButton = SKShapeNode(circleOfRadius: 40)
        dashButton.fillColor = .red
        dashButton.position = CGPoint(x: self.frame.maxX - 200, y: self.frame.minY + 150)
        addChild(dashButton)
    }
    
    func setupPlatform(name: String) {
        guard let platform = self.childNode(withName: name) as? SKShapeNode else {
            fatalError("Node with name \(name) not found or not a SKShapeNode")
        }
        
        platform.physicsBody = SKPhysicsBody(rectangleOf: platform.frame.size)
        platform.physicsBody?.isDynamic = false
        platform.physicsBody?.affectedByGravity = false
        platform.physicsBody?.restitution = 0
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let localLocation = convert(location, to: joystick)
            
            if joystick.joystickBase.frame.contains(localLocation){
                joystick.joystickTouchesBegan(location: localLocation)
                activeTouches[touch] = joystick
            }
            else if dashButton.frame.contains(location) {
                    if !dashCooldown && isOnGround(){
                        startDash()
                    }else if !dashCooldown && !isOnGround() && !isDashing{
                        startLongDash()
                    }else if !isOnGround() && isDashing{
                        stopLongDash()
                    }
            } else if jumpButton.frame.contains(location) {
                if isOnGround() {
                    player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 80))
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
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Update dash movement
        if isDashing {
            dashCooldown = true
            dashCooldownTimeElapsed = 0.0
            dashTimeElapsed += CGFloat(currentTime - (lastUpdateTime ?? currentTime))
            if dashTimeElapsed < dashDuration {
                player.position.x += dashVelocity.dx * CGFloat(currentTime - (lastUpdateTime ?? currentTime))
            } else {
                isDashing = false
                dashVelocity = CGVector.zero
                player.physicsBody?.affectedByGravity = true
                joystick.allowYControl = 0.0
            }
        }
        
        // Update dash cooldown
        if dashCooldown {
            dashCooldownTimeElapsed += CGFloat(currentTime - (lastUpdateTime ?? currentTime))
            if dashCooldownTimeElapsed >= dashCooldownDuration {
                dashCooldown = false
            }
        }
        
        // Update player position
        player.position.x += playerVelocity.dx
        player.position.y += playerVelocity.dy
        if playerVelocity.dx > 0 {
            playerFacing = true
        } else if playerVelocity.dx < 0 {
            playerFacing = false
        }
        
        lastUpdateTime = currentTime
    }
    
    private var lastUpdateTime: TimeInterval?
    
    func startDash() {
        isDashing = true
        dashTimeElapsed = 0.0
        dashVelocity = playerFacing ? CGVector(dx: dashSpeed, dy: 0) : CGVector(dx: -dashSpeed, dy: 0)
    }
    
    func startLongDash() {
        player.physicsBody?.affectedByGravity = false
        joystick.allowYControl = 0.1
        isDashing = true
        dashTimeElapsed = -0.5
        dashVelocity = playerFacing ? CGVector(dx: longDashSpeed, dy: 0) : CGVector(dx: -longDashSpeed, dy: 0)
    }
    
    func stopLongDash() {
        dashTimeElapsed = 0.2
    }
    
    func isOnGround() -> Bool {
        if let physicsBody = player.physicsBody {
            let groundContactMask: UInt32 = 0x1 << 1 // Ground category bit mask
            return physicsBody.allContactedBodies().contains { $0.categoryBitMask & groundContactMask != 0 }
        }
        return false
    }
    
    
}
