//
//  Bounce.swift
//  GTween
//
//  Created by Goon Nguyen on 10/10/14.
//  Copyright (c) 2014 Goon Nguyen. All rights reserved.
//

import Foundation
/*
struct Bounce {
    static var easeIn:String { return "Bounce.easeIn" }
    static var easeOut:String { return "Bounce.easeOut" }
    static var easeInOut:String { return "Bounce.easeInOut" }
}

class ModeBounce {
    var time:Float!
    
    var _pValue = 0.3;
    var _sValue = 0.3 / 4.0;
    var _aValue = 1.0;
    
    init(){
        
    }
    
    var easeInNumber:Float {
        time = 1 - time
        return 1.0 - self.easeOutNumber;
    }
    
    var easeOutNumber:Float {
        if (time < 1.0 / 2.75)
        {
            return (7.5625 * time * time);
        }
        else if (time < 2.0 / 2.75)
        {
            time = time - (1.5 / 2.75)
            let postfix = time
            return 7.5625 * postfix! * time + 0.75;
        }
        else if (time < 2.5 / 2.75)
        {
            time = time - (2.25 / 2.75)
            let postfix = time;
            return 7.5625 * postfix! * time + 0.9375;
        }
        else
        {
            time = time - (2.625 / 2.75)
            let postfix = time;
            return 7.5625 * postfix! * time + 0.984375;
            }
    }
    
    var easeInOutNumber:Float {
        //println("easeInOut")
        time = time * 2.0;
        if (time < 1.0){
            time = 1 - time
            let t = self.easeOutWithTime(duration: 1.0)
            return (1.0 - t * 0.5)
        } else {
            time = time - 1
            let result = self.easeOutWithTime(duration: 1.0)
            return result * 0.5 + 0.5;
        }
    }
    
    func easeOutWithTime(duration:Float)->Float
    {
        time = time / duration;
        if (time < 1.0 / 2.75)
        {
            return (7.5625 * time * time);
        }
        else if (time < 2.0 / 2.75)
        {
            time = time - (1.5 / 2.75)
            return 7.5625 * time * time + 0.75;
        }
        else if (time < 2.5 / 2.75)
        {
            time = time - (2.25 / 2.75)
            return 7.5625 * time * time + 0.9375;
        }
        else
        {
            time = time - (2.625 / 2.75);
            return 7.5625 * time * time + 0.984375;
        }
    }
}
*/
class Bounce:Ease {
    var _pValue = 0.3;
    var _sValue = 0.3 / 4.0;
    var _aValue = 1.0;
    
    override func copy( with zone: NSZone? = nil) -> Ease {
        return Bounce(type: type, props: nil)
    }
    
    override var easeInNumber:Float {
        var t:Float = 1.0 - time;
        if (t < 1.0 / 2.75) {
            return 1.0 - (7.5625 * t * t);
        }
        else if (t < 2.0 / 2.75) {
            t -= 1.5 / 2.75
            return 1.0 - (7.5625 * t * t + 0.75);
        }
        else if (t < 2.5 / 2.75) {
            t -= 2.25 / 2.75
            return 1.0 - (7.5625 * t * t + 0.9375);
        }
        else {
            t -= 2.625 / 2.75;
            return 1.0 - (7.5625 * t * t + 0.984375);
        }
    }
    
    override var easeOutNumber:Float {
        var t:Float = time
        if (t < 1.0 / 2.75) {
            return (7.5625 * t * t);
        }
        else if (t < 2.0 / 2.75) {
            t -= (1.5 / 2.75)
            return 7.5625 * t * t + 0.75;
        }
        else if (t < 2.5 / 2.75) {
            t -= (2.25 / 2.75)
            return 7.5625 * t * t + 0.9375;
        }
        else {
            t -= (2.625 / 2.75)
            return 7.5625 * t * t + 0.984375;
            }
    }
    
    override var easeInOutNumber:Float {
        var invert = false
        var t:Float = time
        if (t < 0.5) {
            invert = true;
            t = 1 - (t * 2);
        }
        else {
            t = (t * 2) - 1;
        }
        
        if (t < 1 / 2.75) {
            t = 7.5625 * t * t;
        }
        else if (t < 2 / 2.75) {
            t -= (1.5 / 2.75)
            t = 7.5625 * t * t + 0.75;
        }
        else if (t < 2.5 / 2.75) {
            t -= (2.25 / 2.75)
            t = 7.5625 * t * t + 0.9375;
        }
        else {
            t -= (2.625 / 2.75)
            t = 7.5625 * t * t + 0.984375;
        }
        return invert ? (1 - t) * 0.5 : t * 0.5 + 0.5;
    }
    
}
