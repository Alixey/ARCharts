//
//  ARChartHighlighter.swift
//  ARCharts
//
//  Created by Christopher Chute on 7/25/17.
//  Copyright © 2017 Boris Emorine. All rights reserved.
//

import SceneKit
import Foundation

public class ARChartHighlighter {
    
    public enum AnimationStyle {
        case dropAway
        case fadeOut
    }
    
    public let animationStyle: AnimationStyle
    public let animationDuration: TimeInterval
    public var highlightedSeries: Int?
    public var highlightedIndex: Int?
    
    public init(animationStyle: AnimationStyle, animationDuration: TimeInterval) {
        self.animationStyle = animationStyle
        self.animationDuration = animationDuration
        self.highlightedIndex = nil
        self.highlightedSeries = nil
    }
    
    /**
     * Add highlighting animations on all bars except the one that is being highlighted.
     * - parameter barChart: The `ARBarChart` to which to add highlighting animations.
     * - parameter index: The index of the bar to highlight.
     * - parameter series: The series of the bar to highlight.
     */
    public func highlightBar(in barChart: ARBarChart, atIndex index: Int, forSeries series: Int) {
        addAnimations(to: barChart, highlightIndex: index, forSeries: series, isHighlighting: true)
        
        self.highlightedIndex = index
        self.highlightedSeries = series
    }
    
    /**
     * Reverse highlighting animations on all bars except the one that was highlighted.
     * - parameter barChart: The `ARBarChart` from which to remove highlighting.
     */
    public func unhighlightBar(in barChart: ARBarChart) {
        guard let index = self.highlightedIndex, let series = self.highlightedSeries else {
            return
        }
        
        addAnimations(to: barChart, highlightIndex: index, forSeries: series, isHighlighting: false)
    }
    
    private func addAnimations(to barChart: ARBarChart, highlightIndex index: Int, forSeries series: Int, isHighlighting: Bool) {
        for node in barChart.childNodes {
            if let barNode = node as? ARBar, let barBox = barNode.geometry as? SCNBox {
                if barNode.series != series || barNode.index != index {
                    let animationsAndAttributeKeys = getAnimations(for: barNode, isHighlighting: isHighlighting)
                    for (animation, animatedAttributeKey) in animationsAndAttributeKeys {
                        if animatedAttributeKey == "height" {
                            barBox.addAnimation(animation, forKey: animatedAttributeKey)
                        } else {
                            barNode.addAnimation(animation, forKey: animatedAttributeKey)
                        }
                    }
                }
            }
        }
    }
    
    private func getAnimations(for barNode: ARBar, isHighlighting: Bool) -> Zip2Sequence<[CABasicAnimation], [String]> {
        var animations: [CABasicAnimation]
        var animatedAttributeKeys: [String]
        
        switch animationStyle {
        case .dropAway:
            let startingHeight = isHighlighting ? barNode.finalHeight : 0.0
            let finalHeight = isHighlighting ? 0.0 : barNode.finalHeight
            animations = [
                CABasicAnimation.heightAnimation(from: startingHeight, to: finalHeight, duration: animationDuration, delay: nil),
                CABasicAnimation.yPositionAnimation(from: 0.5 * startingHeight, to: 0.5 * finalHeight, duration: animationDuration, delay: nil)
            ]
            animatedAttributeKeys = ["height", "position.y"]
        case .fadeOut:
            let startingOpacity: Float = isHighlighting ? 1.0 : 0.2
            let finalOpacity: Float = isHighlighting ? 0.2 : 1.0
            animations = [CABasicAnimation.opacityAnimation(from: startingOpacity, to: finalOpacity, duration: animationDuration, delay: nil)]
            animatedAttributeKeys = ["opacity"]
        }
        
        return zip(animations, animatedAttributeKeys)
    }
    
}
