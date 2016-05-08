//
//  WaterWaveView.swift
//  WaterWaveView
//
//  Created by 권혁 on 2016. 4. 4..
//  Copyright © 2016년 권혁. All rights reserved.
//

import UIKit

@IBDesignable class WaterWaveView: UIView {
    
    // 물 애니메이션 데이터
    private static var DEFAULT_AMPLITUDE_RATIO:Double = 0.05
    private static var DEFAULT_WATER_LEVEL_RATIO:Double = 0.5
    private static var DEFAULT_WAVE_LENGTH_RATIO:Double = 1
    private static var DEFAULT_WAVE_SHIFT_RATIO:Double = 0.0
    private static var DEFAULT_BOTTOM_WIDTH_RATIO:Double = 0.6
    private static var DEFAULT_WAVE_MARGIN: Double = 10
    
    private static var DEFAULT_BEHIND_WAVE_COLOR = UIColor(colorLiteralRed: 1, green: 1, blue: 1, alpha: 40/255)
    private static var DEFAULT_FRONT_WAVE_COLOR = UIColor(colorLiteralRed: 1, green: 1, blue: 1, alpha: 60/255)
    private static var DEFAULT_WAVE_SHAPE = ShapeType.CIRCLE;
    
     var mDefaultAmplitude: Double?
    private var mDefaultWaterLevel: Double?
    private var mDefaultWaveLength: Double?
    private var mDefaultAngularFrequency: Double?
    
    @IBInspectable var mAmplitudeRatio:Double = DEFAULT_AMPLITUDE_RATIO{
        didSet{
            updateProperties()
        }
    }
    @IBInspectable var mWaveLengthRatio:Double = DEFAULT_WAVE_LENGTH_RATIO{
        didSet{
            updateProperties()
        }
    }
    @IBInspectable var mWaterLevelRatio:Double = DEFAULT_WATER_LEVEL_RATIO {
        didSet{
            updateProperties()
        }
    }
    @IBInspectable var mWaveShiftRatio:Double = DEFAULT_WAVE_SHIFT_RATIO{
        didSet{
            updateProperties()
        }
        
    }
    @IBInspectable var mBottomWidthRatio:Double = DEFAULT_BOTTOM_WIDTH_RATIO{
        didSet{
            updateProperties()
        }
        
    }
    
    enum ShapeType {
        case CIRCLE, SQUARE, CUP
    }
    
    private var a:Double = 1.5, b:Double = 0, jia=false
    private var currentWaterColor: UIColor?
    private var currentLinePointY:Double = 250.0
    
    // 컵 테두리 레이어
    private var cupLayer: CAShapeLayer!
    
    // 컵 물결 레이어
    private var waterWaveLayer: CALayer!
    private var waterWaveBehindLayer: CAShapeLayer!
    private var waterWaveFrontLayer: CAShapeLayer!
    
    // 컵 물결 마스킹 레이어
    private var waterWaveMaskLayer: CAShapeLayer!
    
    // 컵 밑 길이 비율
    @IBInspectable var cupBottomRatio:Double = 0.6 {
        didSet{
            if self.cupBottomRatio > 1 {
                self.cupBottomRatio = 1
            } else if self.cupBottomRatio < 0 {
                self.cupBottomRatio = 0
            }
            
            updateProperties()
        }
    }
    
    // 컵 테두리 두깨
    @IBInspectable var cupBorderWidth:Int = 15 {
        didSet {
            updateProperties()
        }
    }
    
    // 컵과 물 사이의 마진
    @IBInspectable var waterWaveMargin:Int = 10 {
        didSet {
            updateProperties()
        }
    }
    
    convenience init () {
        self.init(frame:CGRect.zero)
    }
    
    override init (frame : CGRect) {
        super.init(frame : frame)
        
        viewInit()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        
        viewInit()
    }
    
    func viewInit() {
        self.backgroundColor = UIColor.clearColor()
        self.currentWaterColor = UIColor(colorLiteralRed: 86/255.0, green: 202/255.0, blue: 139/255.0, alpha: 1)
        self.currentLinePointY = 250.0
        
//        NSTimer.scheduledTimerWithTimeInterval(0.02, target: self, selector: #selector(WaterWaveView.animateWave), userInfo: nil, repeats: true)
    }
    
    func animateWave() {
            print ("animate wave")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // CupLayer가 초기화 되어있지 않으면 초기화
        if self.cupLayer == nil {
            self.cupLayer = CAShapeLayer()
            
            self.cupLayer.fillColor = nil
            self.cupLayer.opacity = 1.0
            self.cupLayer.strokeColor = UIColor(colorLiteralRed: 78/255, green: 209/255, blue: 227/255, alpha:1).CGColor
            
            layer.addSublayer(self.cupLayer)
        }
        
        if self.waterWaveLayer == nil {
            self.waterWaveLayer = CALayer()
            layer.addSublayer(self.waterWaveLayer)
        }
        
        if self.waterWaveBehindLayer == nil {
            self.waterWaveBehindLayer = CAShapeLayer()
            
            self.waterWaveBehindLayer.fillColor = nil
            self.waterWaveBehindLayer.opacity = 1.0
            self.waterWaveBehindLayer.strokeColor = UIColor(colorLiteralRed: 78/255, green: 209/255, blue: 227/255, alpha:0.3).CGColor
            
            self.waterWaveLayer.addSublayer(self.waterWaveBehindLayer)
        }
        
        if self.waterWaveFrontLayer == nil {
            self.waterWaveFrontLayer = CAShapeLayer()
            
            self.waterWaveFrontLayer.fillColor = nil
            self.waterWaveFrontLayer.opacity = 1.0
            self.waterWaveFrontLayer.strokeColor = UIColor(colorLiteralRed: 78/255, green: 209/255, blue: 227/255, alpha:1).CGColor
            
            self.waterWaveLayer.addSublayer(self.waterWaveFrontLayer)
        }
        
        if self.waterWaveMaskLayer == nil {
            self.waterWaveMaskLayer = CAShapeLayer()
            
            self.waterWaveMaskLayer.fillColor = UIColor.blackColor().CGColor
            self.waterWaveMaskLayer.fillRule = kCAFillRuleNonZero
            self.waterWaveLayer.mask = self.waterWaveMaskLayer
        }
        
        updateProperties()
    }
    
    func updateProperties() {
        // width, height
        let width = Double(self.bounds.width)
        let height = Double(self.bounds.height)
        
        let screenWidth = width * 2
        let screenHeight = height * 2
        
        // 컵 밑변 두깨
        let cupBottomWidth = Double(self.bounds.width) * (self.cupBottomRatio)
        
        // 현재 화면 크기에 맞게 컵 모양 그림
        if self.cupLayer != nil {
            self.cupLayer.lineWidth = CGFloat(self.cupBorderWidth)
            self.cupLayer.lineCap = kCALineCapRound
            self.cupLayer.lineJoin = kCALineJoinRound
            
            // 컵 태두리 패스
            let cupLinePath = UIBezierPath()
            
            var currentX:Double = Double(self.cupBorderWidth) / 2.0
            var currentY:Double = Double(self.cupBorderWidth) / 2.0
            cupLinePath.moveToPoint(CGPoint(x: currentX, y: currentY))
            
            currentX += width / 2.0 - cupBottomWidth / 2.0
            currentY += height - currentY * 2
            cupLinePath.addLineToPoint(CGPoint(x: currentX, y: currentY))
            
            currentX += cupBottomWidth - Double(cupBorderWidth)
            currentY += 0
            cupLinePath.addLineToPoint(CGPoint(x: currentX, y: currentY))
            
            currentX = width - Double(cupBorderWidth) / 2.0
            currentY = Double(cupBorderWidth) / 2.0
            cupLinePath.addLineToPoint(CGPoint(x: currentX, y: currentY))
            
            self.cupLayer.path = cupLinePath.CGPath
        }
        
        if self.waterWaveBehindLayer != nil {

            self.mDefaultAngularFrequency = 2.0 * M_PI / WaterWaveView.DEFAULT_WAVE_LENGTH_RATIO / width
            self.mDefaultAmplitude = height * WaterWaveView.DEFAULT_AMPLITUDE_RATIO
            self.mDefaultWaterLevel = height * WaterWaveView.DEFAULT_WATER_LEVEL_RATIO;
            self.mDefaultWaveLength = width

            let pathtranslate = CGAffineTransformMakeTranslation(
                CGFloat(self.mWaveShiftRatio * width),
                CGFloat((WaterWaveView.DEFAULT_WATER_LEVEL_RATIO - self.mWaterLevelRatio) * height)
            )
            
            // Draw default waves into the bitmap
            // y=Asin(ωx+φ)+h
            let endX:Int = Int(screenWidth) + 1;
            let endY:Int = Int(screenHeight) + 1;
            
            var waveY = [Int: Double]()
            
            let behindWaterWavePath = UIBezierPath()
            for beginX in -endX...endX {
                let wx:Double = Double(beginX) * self.mDefaultAngularFrequency!
                let beginY:Double = Double(mDefaultWaterLevel! + mDefaultAmplitude! * sin(wx))
                behindWaterWavePath.moveToPoint(CGPoint(x: Double(beginX), y: Double(beginY)))
                behindWaterWavePath.addLineToPoint(CGPoint(x: Double(beginX), y: Double(endY)))
                waveY[beginX] = beginY
            }
            
            behindWaterWavePath.applyTransform(pathtranslate)
            self.waterWaveBehindLayer.path = behindWaterWavePath.CGPath
            
            var affineTransform = CGAffineTransformMakeScale(
                CGFloat(self.mWaveLengthRatio / WaterWaveView.DEFAULT_WAVE_LENGTH_RATIO),
                CGFloat(self.mAmplitudeRatio / WaterWaveView.DEFAULT_AMPLITUDE_RATIO)
            )
            
//            var transformedPath = CGPathCreateCopyByTransformingPath(self.waterWaveBehindLayer.path, &affineTransform)
//            
//            self.waterWaveBehindLayer.path = transformedPath
//            self.waterWaveBehindLayer.position = CGPoint(
//                x: 0, y: self.mDefaultWaterLevel!)
            
            
            let frontWaterWavePath = UIBezierPath()
            let wave2Shift = Int(self.mDefaultWaveLength! / 4)
            for beginX in -endX...endX {
                frontWaterWavePath.moveToPoint(CGPoint(x: Double(beginX), y: waveY[(beginX + wave2Shift) % endX]!))
                frontWaterWavePath.addLineToPoint(CGPoint(x: Double(beginX), y: Double(endY)))
            }

            frontWaterWavePath.applyTransform(pathtranslate)
            self.waterWaveFrontLayer.path = frontWaterWavePath.CGPath
            
            /*
            transformedPath = CGPathCreateCopyByTransformingPath(self.waterWaveFrontLayer.path, &affineTransform)
            
            self.waterWaveFrontLayer.path = transformedPath
            self.waterWaveFrontLayer.position = CGPoint(
                x: 0, y: self.mDefaultWaterLevel!)
            */
            
            // 물결 마스크 패스
            let waterWaveMaskPath = UIBezierPath()
            
            var currentX = Double(self.cupBorderWidth) + Double(waterWaveMargin)
            var currentY = Double(self.cupBorderWidth)
            waterWaveMaskPath.moveToPoint(CGPoint(x: currentX, y: currentY))
            
            currentX = width / 2.0 - cupBottomWidth / 2.0 + Double(self.cupBorderWidth) + Double(waterWaveMargin) / 1.4
            currentY = height - Double(self.cupBorderWidth) - Double(waterWaveMargin)
            waterWaveMaskPath.addLineToPoint(CGPoint(x:currentX, y: currentY))
            
            currentX = width - (width / 2.0 - cupBottomWidth / 2.0) - Double(self.cupBorderWidth) - Double(waterWaveMargin) / 1.4
            waterWaveMaskPath.addLineToPoint(CGPoint(x:currentX, y: currentY))
            
            currentX = width - Double(self.cupBorderWidth) - Double(waterWaveMargin)
            currentY = Double(self.cupBorderWidth)
            waterWaveMaskPath.addLineToPoint(CGPoint(x:currentX, y: currentY))
            
            
            self.waterWaveMaskLayer.path = waterWaveMaskPath.CGPath
        }        
    }
}
