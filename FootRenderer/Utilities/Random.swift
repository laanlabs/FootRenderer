//
//  Random.swift
//  FootRenderer
//
//  Created by William Perkins on 3/4/19.
//  Copyright © 2019 Laan Labs. All rights reserved.
//

import Foundation

extension Float {
    static func random() -> Float {
        return Float(arc4random()%10000) / 10000.0
    }

    static func random(_ min : Float, _ max : Float) -> Float {
        return min + (max - min) * Float.random()
    }

}
