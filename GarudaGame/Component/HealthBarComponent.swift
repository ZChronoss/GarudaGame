//
//  HealthBarComponent.swift
//  GarudaGame
//
//  Created by Leonardo Marhan on 24/06/24.
//

import Foundation
import SpriteKit
import GameplayKit

class HealthBarComponent: GKComponent {
    let healthBar: SKShapeNode
    var maxHealth: Int
    var currentHealth: Int
    let barWidth: CGFloat
    
    init(size: CGSize, maxHealth: Int, currentHealth: Int) {
        self.maxHealth = maxHealth
        self.currentHealth = currentHealth
        self.barWidth = size.width
        
        healthBar = SKShapeNode(rectOf: size, cornerRadius: 2)
        healthBar.strokeColor = .black
        healthBar.lineWidth = 1
        healthBar.zPosition = 5
        
        super.init()
        
        updateHealthBar()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateHealthBar() {
        let healthPercentage = CGFloat(currentHealth) / CGFloat(maxHealth)
        let newWidth = healthBar.frame.width * healthPercentage
        healthBar.path = CGPath(rect: CGRect(x: -barWidth / 2, y: -healthBar.frame.height / 2, width: newWidth, height: healthBar.frame.height), transform: nil)
        healthBar.fillColor = healthPercentage >= 0.7 ? .green : (healthPercentage >= 0.4 ? .yellow : .red)
    }
    
    func takeDamage(_ damage: Int) {
        currentHealth = max(currentHealth - damage, 0)
        updateHealthBar()
    }
}

