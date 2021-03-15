//
//  CGRectExtension.swift
//  PlurkGit
//
//  Created by Jiawei on 2017/12/5.
//  Copyright © 2017年 BrickGit. All rights reserved.
//

import Foundation
import UIKit

public extension CGPoint {
    static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint{
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint{
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    static func *(lhs: CGPoint, rhs: CGFloat) -> CGPoint{
        return CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
    }

    static func /(lhs: CGPoint, rhs: CGFloat) -> CGPoint{
        return CGPoint(x: lhs.x / rhs, y: lhs.y / rhs)
    }

    func distance(to point: CGPoint) -> CGFloat {
        let xDist = x - point.x
        let yDist = y - point.y
        return CGFloat(sqrt((xDist * xDist) + (yDist * yDist)))
    }
}

public extension CGSize {
    init(square: CGFloat) {
        self.init(width: square, height: square)
    }

    init(fitWidth: CGFloat) {
        self.init(width: fitWidth, height: .greatestFiniteMagnitude)
    }
    
    static func +(lhs: CGSize, rhs: CGSize) -> CGSize{
        return CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
    
    static func -(lhs: CGSize, rhs: CGSize) -> CGSize{
        return CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
    }
    
    static func *(lhs: CGSize, rhs: CGFloat) -> CGSize{
        return CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
    }
    
    static func /(lhs: CGSize, rhs: CGFloat) -> CGSize{
        return CGSize(width: lhs.width / rhs, height: lhs.height / rhs)
    }
    
    var integer: CGSize {
        return CGSize(width: ceil(width), height: ceil(height))
    }

    func aspectFit(with maxSize: CGSize) -> CGSize {
        if(width > maxSize.width || height > maxSize.height){
            let scaleRatio = min(maxSize.width / width, maxSize.height / height)
            return CGSize(width: width * scaleRatio, height: height * scaleRatio)
        }
        return self
    }

    func aspectFill(with maxSize: CGSize) -> CGSize {
        if(width > maxSize.width || height > maxSize.height){
            let scaleRatio = max(maxSize.width / width, maxSize.height / height)
            return CGSize(width: width * scaleRatio, height: height * scaleRatio)
        }
        return self
    }
}

public extension CGRect {
    static func +(lhs: CGRect, rhs: CGRect) -> CGRect{
        return CGRect(x: lhs.origin.x + rhs.origin.x, y: lhs.origin.y + rhs.origin.y, width: lhs.size.width + rhs.size.width, height: lhs.size.height + rhs.size.height)
    }

    static func -(lhs: CGRect, rhs: CGRect) -> CGRect{
        return CGRect(x: lhs.origin.x - rhs.origin.x, y: lhs.origin.y - rhs.origin.y, width: lhs.size.width - rhs.size.width, height: lhs.size.height - rhs.size.height)
    }
    
    static func *(lhs: CGRect, rhs: CGFloat) -> CGRect{
        return CGRect(origin: lhs.origin * rhs, size: lhs.size * rhs)
    }
    
    static func /(lhs: CGRect, rhs: CGFloat) -> CGRect{
        return CGRect(origin: lhs.origin / rhs, size: lhs.size / rhs)
    }

    var normalized: CGRect {
        return CGRect(x: floor(origin.x), y: floor(origin.y), width: ceil(width), height: ceil(height))
    }

    static func createOverlayFrames(overlay: CGRect, clip: CGRect) -> [CGRect] {
        return [
            CGRect(x: overlay.origin.x, y: overlay.origin.y, width: overlay.width, height: clip.minY),
            CGRect(x: overlay.origin.x + clip.maxX, y: overlay.origin.y + clip.minY, width: overlay.width - clip.maxX, height: clip.height),
            CGRect(x: overlay.origin.x, y: overlay.origin.y + clip.maxY, width: overlay.width, height: overlay.height - clip.maxY),
            CGRect(x: overlay.origin.x, y: overlay.origin.y + clip.minY, width: clip.minX, height: clip.height)
        ]
    }
}

public extension UIEdgeInsets {
    static func +(lhs: UIEdgeInsets, rhs: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsets(top: lhs.top + rhs.top, left: lhs.left + rhs.left, bottom: lhs.bottom + rhs.bottom, right: lhs.right + rhs.right)
    }

    static func -(lhs: UIEdgeInsets, rhs: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsets(top: lhs.top - rhs.top, left: lhs.left - rhs.left, bottom: lhs.bottom - rhs.bottom, right: lhs.right - rhs.right)
    }
}

public struct CGLine {
    public var start: CGPoint
    public var end: CGPoint

    public init(start: CGPoint, end: CGPoint) {
        self.start = start
        self.end = end
    }
    
    public func intersection(_ line2: CGLine) -> CGPoint? {
        let distance = (end.x - start.x) * (line2.end.y - line2.start.y) - (end.y - start.y) * (line2.end.x - line2.start.x)
        guard distance != 0 else { return nil }

        let u = ((line2.start.x - start.x) * (line2.end.y - line2.start.y) - (line2.start.y - start.y) * (line2.end.x - line2.start.x)) / distance
        let v = ((line2.start.x - start.x) * (end.y - start.y) - (line2.start.y - start.y) * (end.x - start.x)) / distance
        guard u > 0 && u < 1 && v > 0 && v < 1 else { return nil }
        
        return CGPoint(x: start.x + u * (end.x - start.x), y: start.y + u * (end.y - start.y))
    }
}

public extension Comparable {
    func clamped(min minValue: Self, max maxValue: Self) -> Self {
       return min(max(self, minValue), maxValue)
   }
}
