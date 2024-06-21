//
//  RangedEnemy.swift
//  GarudaGame
//
//  Created by Renaldi Antonio on 20/06/24.
//

import Foundation
import GameplayKit

class RangedEnemy: Enemy {
    var shootCooldown: TimeInterval = 2.0
    var shootCooldownisActive: Bool = false
    let target: GKEntity!
    
    override init(name: String, health: Int, target: GKEntity) {
        self.target = target
        super.init(name: name, health: health, target: target)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func shootBullet(target: GKEntity){
        if let node = self.component(ofType: SpriteComponent.self)?.node {
            if let targetPos = target.component(ofType: SpriteComponent.self)?.node{
                let directionX = targetPos.position.x - node.position.x
                let directionY = targetPos.position.y - node.position.y
                let direction = CGVector(dx: directionX, dy: directionY)
                
                let bullet = Bullet(position: CGPoint(x: node.position.x, y: node.position.y), direction: direction)
                if let bulletNode = bullet.component(ofType: SpriteComponent.self)?.node{
                    node.addChild(bulletNode)
                    let moveBullet = SKAction.move(by: direction, duration: 1)
                    let removeBullet = SKAction.removeFromParent()
                    let bulletAction = SKAction.sequence([moveBullet, removeBullet])
                    bulletNode.run(bulletAction)
                }
            }
        }
    }
}
