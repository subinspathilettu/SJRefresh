//
//  LoadingBallView.swift
//  BezierPathAnimation
//
//  Created by Takuya Okamoto on 2015/08/11.
//  Upadated by Subins Jose on 05/10/16.
//  Copyright © 2016 Subins Jose. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software
//    and associated documentation files (the "Software"), to deal in the Software without
//	  restriction, including without limitation the rights to use, copy, modify, merge, publish,
//    distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom
//	  the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or
//    substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
//  BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE
//  AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//  CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import UIKit

private var timeFunc: CAMediaTimingFunction!

class BallView: UIView {
    
    var circleLayer: CircleLayer!
	let circleSize: CGFloat = 30.0
    
    override init(frame:CGRect) {

        super.init(frame:frame)

        let circleMoveView = UIView()
        circleMoveView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        circleMoveView.center = CGPoint(x: frame.width/2, y: frame.height + circleSize / 2)
        addSubview(circleMoveView)
        
        circleLayer = CircleLayer(
            size: circleSize,
            moveUpDist: 50,
            superViewFrame: circleMoveView.frame,
            color: UIColor.white

        )
        circleMoveView.layer.addSublayer(circleLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startAnimation() {
        circleLayer.startAnimation()
    }

    func endAnimation(_ complition:(()->())? = nil) {
        circleLayer.endAnimation(complition)
    }
}


class CircleLayer: CAShapeLayer {
    
    let moveUpDist: CGFloat!
    let spiner: SpinerLayer!
    var didEndAnimation: (()->())?
    
    init(size:CGFloat,
         moveUpDist:CGFloat,
         superViewFrame:CGRect,
         color:UIColor = UIColor.white) {

        self.moveUpDist = moveUpDist
		let selfFrame = CGRect(x: 0, y: 0,
		                       width: superViewFrame.size.width,
		                       height: superViewFrame.size.height)
        spiner = SpinerLayer(superLayerFrame: selfFrame,
                             ballSize: size,
                             color: color)
        super.init()
        
        addSublayer(spiner)
        
        let radius:CGFloat = size / 2
        frame = selfFrame
		let center = CGPoint(x: superViewFrame.size.width / 2,
		                     y: superViewFrame.size.height/2)
        let startAngle = 0 - M_PI_2
        let endAngle = M_PI * 2 - M_PI_2
        let clockwise: Bool = true
        path = UIBezierPath(arcCenter: center,
                            radius: radius,
                            startAngle: CGFloat(startAngle),
                            endAngle: CGFloat(endAngle),
                            clockwise: clockwise).cgPath
        fillColor = color.withAlphaComponent(1).cgColor
        strokeColor = self.fillColor
        lineWidth = 0
        strokeEnd = 1
    }
    
    required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
    }
    
    func startAnimation() {

        self.moveUp(moveUpDist)
		Timer.scheduledTimer(timeInterval: 0.2, target: self,
		                     selector: #selector(self.spinnerAnimation),
		                     userInfo: nil,
		                     repeats: false)
    }
	func spinnerAnimation() {

		spiner.animation()
	}

    func endAnimation(_ complition:(()->())? = nil) {

        spiner.stopAnimation()
        moveDown(moveUpDist)
        didEndAnimation = complition
    }
    
    func moveUp(_ distance: CGFloat) {

        let move = CABasicAnimation(keyPath: "position")
        
        move.fromValue = NSValue(cgPoint: position)
        move.toValue = NSValue(cgPoint: CGPoint(x: position.x, y: position.y - distance))
        move.duration = 0.2
        move.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        move.fillMode = kCAFillModeForwards
        move.isRemovedOnCompletion = false
        add(move, forKey: move.keyPath)
    }
    
    
    func moveDown(_ distance: CGFloat) {

        let move = CABasicAnimation(keyPath: "position")
        move.fromValue = NSValue(cgPoint: CGPoint(x: position.x, y: position.y - distance))
        move.toValue = NSValue(cgPoint: position)
		move.duration = 0.2
        move.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        move.fillMode = kCAFillModeForwards
        move.isRemovedOnCompletion = false
        move.delegate = self
        add(move, forKey: move.keyPath)
    }
}

extension CircleLayer: CAAnimationDelegate {

	func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
		didEndAnimation?()
	}
}


class SpinerLayer: CAShapeLayer {
    
    init(superLayerFrame:CGRect, ballSize:CGFloat, color:UIColor = UIColor.white) {

        super.init()
        let radius:CGFloat = (ballSize / 2) * 1.2//1.45
        self.frame = CGRect(x: 0, y: 0,
                            width: superLayerFrame.height,
                            height: superLayerFrame.height)
        let center = CGPoint(x: superLayerFrame.size.width / 2,
                             y: superLayerFrame.origin.y + superLayerFrame.size.height/2)
        let startAngle = 0 - M_PI_2
        let endAngle = (M_PI * 2 - M_PI_2) + M_PI / 8
        let clockwise: Bool = true
        path = UIBezierPath(arcCenter: center,
                            radius: radius,
                            startAngle: CGFloat(startAngle),
                            endAngle: CGFloat(endAngle),
                            clockwise: clockwise).cgPath
        
        fillColor = nil
        strokeColor = color.withAlphaComponent(1).cgColor
        lineWidth = 2
        lineCap = kCALineCapRound
        
        strokeStart = 0
        strokeEnd = 0
        isHidden = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func animation() {

        self.isHidden = false
        let rotate = CABasicAnimation(keyPath: "transform.rotation.z")
        rotate.fromValue = 0
        rotate.toValue = M_PI * 2
        rotate.duration = 1
        rotate.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        rotate.repeatCount = HUGE
        rotate.fillMode = kCAFillModeForwards
        rotate.isRemovedOnCompletion = false
        add(rotate, forKey: rotate.keyPath)

        strokeEndAnimation()
    }

    func strokeEndAnimation() {

        let endPoint = CABasicAnimation(keyPath: "strokeEnd")
        endPoint.fromValue = 0
        endPoint.toValue = 1.0
        endPoint.duration = 0.8
        endPoint.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        endPoint.repeatCount = 1
        endPoint.fillMode = kCAFillModeForwards
        endPoint.isRemovedOnCompletion = false
        endPoint.delegate = self
        add(endPoint, forKey: endPoint.keyPath)
    }
    
    func strokeStartAnimation() {

        let startPoint = CABasicAnimation(keyPath: "strokeStart")
        startPoint.fromValue = 0
        startPoint.toValue = 1.0
        startPoint.duration = 0.8
        startPoint.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        startPoint.repeatCount = 1

        startPoint.delegate = self
        add(startPoint, forKey: startPoint.keyPath)
    }

    func stopAnimation() {

        isHidden = true
        removeAllAnimations()
    }
}

extension SpinerLayer: CAAnimationDelegate {

	func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {

        if isHidden == false {
            let a:CABasicAnimation = anim as! CABasicAnimation
            if a.keyPath == "strokeStart" {
                strokeEndAnimation()
            }
            else if a.keyPath == "strokeEnd" {
                strokeStartAnimation()
            }
        }
	}
}
