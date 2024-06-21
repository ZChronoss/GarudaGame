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
        let texture = SKTexture(imageNamed: "redball")
        
        let spriteComponent = SpriteComponent(texture, size: CGSize(width: 10, height: 10), zPos: 4)
        addComponent(spriteComponent)
        addComponent(PositionComponent(position: position))
        addComponent(BulletComponent(direction: direction, node: spriteComponent.node))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
