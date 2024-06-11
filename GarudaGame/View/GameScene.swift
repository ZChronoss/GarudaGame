import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var player = SKSpriteNode()
    var platform = SKShapeNode()
    var jumpButton = SKShapeNode()
    
    var joystickBase = SKShapeNode()
    var joystickStick = SKShapeNode()
    var dashButton = SKShapeNode()
    
    var joystickActive = false
    var joystickStartPoint = CGPoint.zero
    var joystickTouch: UITouch?
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
    
    var joystick = JoystickView()
    
    override func didMove(to view: SKView) {
        // Setup player
        player = SKSpriteNode(color: .red, size: CGSize(width: 50, height: 50))
        player.position = CGPoint(x: 0, y: 0)
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.isDynamic = true
        player.physicsBody?.affectedByGravity = true
        player.physicsBody?.restitution = 0
        player.physicsBody?.allowsRotation = false
        addChild(player)
        
        // Setup platform
        platform = setupSprite(name: "a")
        platform.physicsBody = SKPhysicsBody(rectangleOf: platform.frame.size)
        platform.physicsBody?.isDynamic = false
        platform.physicsBody?.affectedByGravity = false
        platform.physicsBody?.restitution = 0
        
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
    
    func setupSprite(name: String) -> SKShapeNode {
        return self.childNode(withName: name) as! SKShapeNode
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
            } else if jumpButton.frame.contains(location) {
                // Handle jump button press
                if isOnGround() {
                    player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 80))
                }
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
    
    override func update(_ currentTime: TimeInterval) {
        // Check if player is on the ground or a platform
        let isOnGround = self.isOnGround()
        
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
    
    func isOnGround() -> Bool {
        if let physicsBody = player.physicsBody {
            let groundContactMask: UInt32 = 0x1 << 1 // Ground category bit mask
            return physicsBody.allContactedBodies().contains { $0.categoryBitMask & groundContactMask != 0 }
        }
        return false
    }
}