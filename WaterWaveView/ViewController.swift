//
//  ViewController.swift
//  WaterWaveView
//
//  Created by 권혁 on 2016. 4. 4..
//  Copyright © 2016년 권혁. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var waterWaveView: WaterWaveView!
    
    private var reverseMode = false
    
    private var currentWater:Double = 0
    private var currentAnimatedWater:Double = 0
    private var isDrinkMode = false
    private var isSpiiMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        NSTimer.scheduledTimerWithTimeInterval(0.0009, target: self, selector: #selector(waterWave), userInfo: nil, repeats: true)

        waterWaveView.mWaterLevelRatio = 0
        
        
    }
    @IBAction func spillWater(sender: AnyObject) {
        if(currentWater <=
            0) {
            return
        }
        
        currentWater -= 250
        isSpiiMode = true
        isDrinkMode = false
    }

    @IBAction func drinkWater(sender: AnyObject) {
        if(currentWater >= 2000) {
            return
        }
        
        currentWater += 250
        isSpiiMode = false
        isDrinkMode = true
    }
    
    func waterWave() {
        if(waterWaveView.mWaterLevelRatio <= 1 && currentAnimatedWater <= currentWater && isDrinkMode) {
            
            waterWaveView.mWaterLevelRatio = waterWaveView.mWaterLevelRatio + 0.005
            
            currentAnimatedWater += 10
        } else {
            isDrinkMode = false
        }
        
        if(waterWaveView.mWaterLevelRatio > 0 && currentAnimatedWater > currentWater && isSpiiMode) {
            
            waterWaveView.mWaterLevelRatio = waterWaveView.mWaterLevelRatio - 0.005
            
            currentAnimatedWater -= 10
        } else {
            isSpiiMode = false
        }

        
        if(waterWaveView.mWaveShiftRatio <= 1) {
            waterWaveView.mWaveShiftRatio = waterWaveView.mWaveShiftRatio + 0.01
        } else {
            waterWaveView.mWaveShiftRatio = 0
        }
        
    }
}

