import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var player = SKSpriteNode()
    var platform = SKShapeNode()
    var leftButton = SKSpriteNode()
    var rightButton = SKSpriteNode()
    
    var joystickBase = SKShapeNode()
    var joystickStick = SKShapeNode()
    
    var joystickActive = false
    var joystickStartPoint = CGPoint.zero
    var playerVelocity = CGVector.zero
    
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
        
        // Setup joystick base
        joystickBase = SKShapeNode(circleOfRadius: 100)
        joystickBase.position = CGPoint(x: -size.width / 2 + 200, y: -size.height / 2 + 200)
        joystickBase.alpha = 0.5
        addChild(joystickBase)
        
        // Setup joystick stick
        joystickStick = SKShapeNode(circleOfRadius: 30)
        joystickStick.fillColor = .gray
        joystickStick.position = joystickBase.position
        addChild(joystickStick)
    }
    
    func setupSprite(name: String) -> SKShapeNode{
        return self.childNode(withName: name) as! SKShapeNode
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            if joystickBase.frame.contains(location) {
                joystickActive = true
                joystickStartPoint = location
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if joystickActive, let touch = touches.first {
            let location = touch.location(in: self)
            let offset = CGPoint(x: location.x - joystickStartPoint.x, y: location.y - joystickStartPoint.y)
            let direction = CGVector(dx: offset.x, dy: offset.y)
            let length = sqrt(direction.dx * direction.dx + direction.dy * direction.dy)
            
            // Limit the stick movement to the joystick base
            let maxDistance: CGFloat = 50
            let clampedDistance = min(length, maxDistance)
            let clampedDirection = CGVector(dx: direction.dx / length * clampedDistance, dy: direction.dy / length * clampedDistance)
            
            joystickStick.position = CGPoint(x: joystickBase.position.x + clampedDirection.dx, y: joystickBase.position.y + clampedDirection.dy)
            
            // Calculate player velocity
            playerVelocity = CGVector(dx: clampedDirection.dx * 0.1, dy: clampedDirection.dy * 0.2) // Adjust multiplier as needed
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if joystickActive {
            joystickActive = false
            joystickStick.position = joystickBase.position
            playerVelocity = CGVector.zero
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        player.position.x += playerVelocity.dx
        player.position.y += playerVelocity.dy
    }
}
