//
//  SpriteComponent.swift
//  GarudaGame
//
//  Created by Renaldi Antonio on 13/06/24.
//

import Foundation
import SpriteKit
import GameplayKit
import Metal

class SpriteComponent: GKComponent {
    var node = SKSpriteNode()
    
    init(_ texture: SKTexture, size: CGSize, zPos: CGFloat) {
        super.init()
        self.node = SKSpriteNode(texture: texture)
        self.node.size = size
        self.node.zPosition = zPos
        
        //Liquid Shader
//        let negativeShader = SKShader(source: "void main() { float speed = u_time * 0.35; float frequency = 14.0; float intensity = 0.006; vec2 coord = v_tex_coord; coord.x += cos((coord.x + speed) * frequency) * intensity; coord.y += sin((coord.y + speed) * frequency) * intensity; vec4 targetPixelColor = texture2D(u_texture, coord); gl_FragColor = targetPixelColor; }")
//        
//        // Apply the shader to the sprite
//        self.node.shader = negativeShader
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
