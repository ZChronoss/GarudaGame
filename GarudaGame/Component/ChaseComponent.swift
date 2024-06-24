//
//  ChaseComponent.swift
//  GarudaGame
//
//  Created by Leonardo Marhan on 19/06/24.
//

import Foundation
import GameplayKit

class ChaseComponent: GKComponent {
    var target: GKEntity
    
    init(target: GKEntity) {
        self.target = target
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        if let enemy = entity as? Enemy{
            if enemy.isActivated{
                guard let targetNode = target.component(ofType: SpriteComponent.self)?.node,
                      let enemyNode = entity?.component(ofType: SpriteComponent.self)?.node else {
                    return
                }
                
                let targetPosition = targetNode.position
                let enemyPosition = enemyNode.position
                
                //Untuk ground enemy
                let velocity: CGFloat = 10.0 // Adjust the speed as needed
                let moveX: CGFloat
                
                if targetPosition.x > enemyPosition.x {
                    moveX = velocity * CGFloat(seconds)
                } else {
                    moveX = -velocity * CGFloat(seconds)
                }
                
                enemyNode.position.x += moveX
            }
        }

        //Untuk flying enemy
//        let dx = targetPosition.x - enemyPosition.x
//        let dy = targetPosition.y - enemyPosition.y
//        let angle = atan2(dy, dx)
//
//        let velocity: CGFloat = 10.0 // Adjust the speed as needed
//        let moveX = cos(angle) * velocity * CGFloat(seconds)
//        let moveY = sin(angle) * velocity * CGFloat(seconds)
//
//        enemyNode.position = CGPoint(x: enemyPosition.x + moveX, y: enemyPosition.y + moveY)
    }
}

