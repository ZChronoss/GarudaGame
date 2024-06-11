import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var player = SKSpriteNode()
    var platform = SKShapeNode()
    var jumpButton = SKShapeNode()
    
    var playerVelocity = CGVector.zero
    
    var joystick = JoystickView()
    
    override func didMove(to view: SKView) {
        // Setup player
        player = SKSpriteNode(color: .red, size: CGSize(width: 50, height: 50))
        player.position = CGPoint(x: 0, y: 0)
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.isDynamic = true
        player.physicsBody?.affectedByGravity = true
        player.physicsBody?.restitution = 0
        addChild(player)
        
        // Setup platform
        platform = setupSprite(name: "a")
        platform.physicsBody = SKPhysicsBody(rectangleOf: platform.frame.size)
        platform.physicsBody?.isDynamic = false
        platform.physicsBody?.affectedByGravity = false
        platform.physicsBody?.restitution = 0
        
        joystick.position = CGPoint(x: -size.width / 2 + 200, y: -size.height / 2 + 200)
        addChild(joystick)
        
        jumpButton = SKShapeNode(circleOfRadius: 40)
        jumpButton.fillColor = .blue
        jumpButton.position = CGPoint(x: size.width / 2 - 150, y: -size.height / 2 + 150)
        addChild(jumpButton)
    }
    
    func setupSprite(name: String) -> SKShapeNode{
        return self.childNode(withName: name) as! SKShapeNode
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            let localLocation = convert(location, to: joystick)
            joystick.joystickTouchesBegan(location: localLocation)
            if jumpButton.frame.contains(location) {
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
        joystick.joystickTouchesEnded()
        playerVelocity = .zero
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Check if player is on the ground or a platform
        let isOnGround = self.isOnGround()
                
        // Prevent upward movement
        if playerVelocity.dy > 0 {
            playerVelocity.dy = 0
        }
        
        // Prevent downward movement when in mid-air
        if !isOnGround && playerVelocity.dy < 0 {
            playerVelocity.dy = 0
        }
        
        player.position.x += playerVelocity.dx
    }
    
    func isOnGround() -> Bool {
        if let physicsBody = player.physicsBody {
            let groundContactMask: UInt32 = 0x1 << 1 // Ground category bit mask
            return physicsBody.allContactedBodies().contains { $0.categoryBitMask & groundContactMask != 0 }
        }
        return false
    }
}
