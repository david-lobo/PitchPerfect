//
//  UIViewExtension.swift
//  Pitch Perfect
//
//  Created by david lobo on 03/03/2016.
//  Copyright © 2016 David Lobo. All rights reserved.
//  Used tutorial as basis for methods: https://www.andrewcbancroft.com/2014/07/27/fade-in-out-animations-as-class-extensions-with-swift/

import Foundation
import UIKit

extension UIView {
    func fadeIn(duration: NSTimeInterval = 1.0, delay: NSTimeInterval = 0.0, completion: ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animateWithDuration(duration, delay: delay, options: [.CurveEaseIn, .AllowUserInteraction], animations: {
            self.alpha = 1.0
            }, completion: completion)
    }
    
    func fadeOut(duration: NSTimeInterval = 1.0, delay: NSTimeInterval = 0.0, completion: ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animateWithDuration(duration, delay: delay, options: [.CurveEaseIn, .AllowUserInteraction], animations: {
            self.alpha = 0.2
            }, completion: completion)
    }
    
    func fadeInAndOut(duration: NSTimeInterval = 1.0, delay: NSTimeInterval = 0.0, finished: () -> Bool, completion: ((Bool) -> Void)) {
        
        print("FadeInOut\(finished)")
        
        fadeOut(1.0, delay: 0.0, completion: { _ in
            self.fadeIn(1.0, delay: 0.0, completion: {
                _ in
                
                if finished() {
                    print("Calling FadeInOut\(finished())")
                    self.fadeInAndOut(1.0, delay: 0.0, finished: finished, completion: completion)
                } else {
                    print("Not calling FadeInOut\(finished())")
                }
            })
        })
    }
}
