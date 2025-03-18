//
//  Extensions.swift
//  VerticalScrollContainer
//
//  Created by Asaf Sergen Gönenç on 13.03.2025.
//

import CoreGraphics

internal extension CGSize {
    static func +(lhs: Self, rhs: Self) -> CGSize{
        CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
    
    static func += (lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }
}

internal extension Comparable {
    func clamped(_ f: Self, _ t: Self)  ->  Self {
        let min = min(f,t)
        let max = max(f, t)
        
        if self < min { return f }
        if self > max { return t }
        
        return self
    }
}
