//
//  Array.swift
//  GarudaGame
//
//  Created by Dharmawan Ruslan on 20/06/24.
//

import Foundation

extension Array where Element: Equatable {
   mutating func remove(_ element: Element) {
      self = filter { $0 != element }
   }
}
