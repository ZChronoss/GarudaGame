//
//  BulletSystem.swift
//  GarudaGame
//
//  Created by Renaldi Antonio on 20/06/24.
//

import Foundation
import GameplayKit

class BulletSystem: GKComponentSystem<BulletComponent> {
    func update(player: Player, enemy: RangedEnemy, currentTime: TimeInterval) {
        
        if !enemy.shootCooldownisActive {
            enemy.shootBullet(target: player)
            enemy.shootCooldownisActive = true
            Timer.scheduledTimer(withTimeInterval: enemy.shootCooldown, repeats: false) { _ in
                enemy.shootCooldownisActive = false
            }
        }
    }
}
