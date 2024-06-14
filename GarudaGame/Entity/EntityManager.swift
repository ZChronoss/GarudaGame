//
//  EntityManager.swift
//  GarudaGame
//
//  Created by Renaldi Antonio on 13/06/24.
//

import Foundation
import GameplayKit

/*
 Entity manager ini hold semua kebutuhan buat entity
 kek di sini buat add entity ke scene gw masukin sini dsb
 
 */
class EntityManager {
    var entities = Set<GKEntity>()
    let scene: SKScene
    
    init(scene: SKScene){
        self.scene = scene
    }
    
    func addEntity(_ entity: GKEntity){
        entities.insert(entity)
        
        if let spriteNode = entity.component(ofType: SpriteComponent.self)?.node {
            scene.addChild(spriteNode)
        }
    }
    
    func removeEntity(_ entity: GKEntity){
        if let spriteNode = entity.component(ofType: SpriteComponent.self)?.node {
            spriteNode.removeFromParent()
        }
        
        entities.remove(entity)
    }
    
    func addPhysic(_ entity: GKEntity){
        if let spriteNode = entity.component(ofType: SpriteComponent.self)?.node, let physicBody = entity.component(ofType: PhysicComponent.self)?.physicBody{
            spriteNode.physicsBody = physicBody
        }
    }
    
    func startAnimation(_ entity: GKEntity){
        if let spriteNode = entity.component(ofType: SpriteComponent.self)?.node, let frames = entity.component(ofType: AnimationComponent.self)?.frames {
            let animation = SKAction.animate(with: frames,
                                             timePerFrame: TimeInterval(0.5))
            spriteNode.run(SKAction.repeatForever(animation))
        }
    }
}
