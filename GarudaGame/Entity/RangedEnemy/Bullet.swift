//
//  Bullet.swift
//  GarudaGame
//
//  Created by Renaldi Antonio on 20/06/24.
//

import Foundation
import GameplayKit

class Bullet: GKEntity {
    init(position: CGPoint, direction: CGVector) {
        super.init()
        let texture = SKTexture(imageNamed: "BulletNode")
        
        let spriteComponent = SpriteComponent(texture, size: CGSize(width: 30, height: 30), zPos: 4)
        addComponent(spriteComponent)
        let animationComponent = AnimationComponent(name: "Bullet")
        addComponent(animationComponent)
        addComponent(PositionComponent(position: position))
        addComponent(BulletComponent(direction: direction, node: spriteComponent.node))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
