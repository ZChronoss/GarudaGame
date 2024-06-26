//
//  Objective.swift
//  GarudaGame
//
//  Created by Dharmawan Ruslan on 26/06/24.
//

import Foundation
import GameplayKit

class Objective: GKEntity {
    var name = ""
    var texture = SKTexture()
    let nodeSize = CGSize(width: 80, height: 80)
    var isDone = false
    
    init(name: String) {
        self.name = name
        super.init()
        
        self.texture = SKTexture(imageNamed: name + "Node")
        
//        Sprite
        let spriteComponent = SpriteComponent(texture, size: nodeSize, zPos: 4)
        addComponent(spriteComponent)
        
//        Physics
        let physicComponent = PhysicComponent(SKPhysicsBody(rectangleOf: nodeSize), bitmask: PhysicsCategory.objective, collision: PhysicsCategory.none, contact: PhysicsCategory.player)
        physicComponent.physicBody.affectedByGravity = false
        addComponent(physicComponent)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
