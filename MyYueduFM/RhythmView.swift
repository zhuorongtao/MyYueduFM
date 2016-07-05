//
//  RhythmView.swift
//  MyYueduFM
//
//  Created by apple on 16/5/26.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit

let kRhythmBarCount = 4
let kRhythmBarWidth: CGFloat = 2

class RhythmView: UIView {
    
    var barArray: [UIView]?
    var animating = false
    
    override func awakeFromNib() {
        self.setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    
    // MARK: - 本类共有方法
    func startAnimating() {
        self.stopAnimating()
        self.animating = true
        
        for bar in barArray! {
            self.setupAnimationForView(bar)
            bar.hidden = false
        }
    }
    
    func stopAnimating() {
        self.animating = false
        
        for bar in barArray! {
            bar.layer.removeAllAnimations()
            bar.hidden = true
        }
    }
    
    func isAnimating() -> Bool {
        return self.animating
    }
    
    // MARK: - 本类私有方法
    private func setup() {
        self.backgroundColor = UIColor.clearColor()
        self.clipsToBounds = true
        
        barArray = []
        
        let w = self.width / 5
        let x = kRhythmBarWidth / 2
        barArray?.append(self.barWithPointX(1 * w - x, height: self.height * 0.4))
        barArray?.append(self.barWithPointX(2 * w - x, height: self.height * 0.6))
        barArray?.append(self.barWithPointX(3 * w - x, height: self.height * 0.3))
        barArray?.append(self.barWithPointX(4 * w - x, height: self.height * 0.2))
    }
    
    private func barWithPointX(x: CGFloat, height: CGFloat) -> UIView {
        let view = UIView(frame: CGRectMake(x, self.height - height / 2, kRhythmBarWidth, height))
        
        view.backgroundColor = UIColor.whiteColor()
        view.hidden = true
        view.layer.cornerRadius = kRhythmBarWidth / 2
        self.addSubview(view)
        return view
    }
    
    private func setupAnimationForView(view: UIView) {
        let animation = CABasicAnimation(keyPath: "bounds")
        
        animation.duration     = CFTimeInterval((self.height - view.height) / self.height)
        animation.repeatCount  = Float.infinity
        animation.autoreverses = true
        animation.fromValue    = NSValue(CGRect: CGRectMake(0, 0, kRhythmBarWidth, view.height))
        animation.toValue      = NSValue(CGRect: CGRectMake(0, 0, kRhythmBarWidth, self.height * 2))
        animation.byValue      = NSValue(CGRect: view.bounds)
        animation.delegate     = self
        view.layer.addAnimation(animation, forKey: "animation")
    }
    
}
