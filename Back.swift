//
//  Back.swift
//  GTween
//
//  Created by Goon Nguyen on 10/10/14.
//  Copyright (c) 2014 Goon Nguyen. All rights reserved.
//

import Foundation
/*
struct Back {
    
    static var easeIn:String { return "Back.easeIn" }
    static var easeOut:String { return "Back.easeOut" }
    static var easeInOut:String { return "Back.easeInOut" }
    
}

class ModeBack {
    var time:Float!
    //var _sValue:Float = 1.70158;
    var _sValue:Float = 2.2;
    
    init(){
        
    }
    
    var easeInNumber:Float {
        return time * time * ((_sValue + 1) * time - _sValue);
    }
    
    var easeOutNumber:Float {
        time = time - 1;
        let c1 = time * time
        let c2 = (_sValue + 1) * time + _sValue
        return c1 * c2 + 1
        //return time * time * ((_sValue + 1) * time + _sValue) + 1;
    }
    
    var easeInOutNumber:Float {
        //println("easeInOut")
        time = time * 2;
        let s = _sValue * 1.525;
        if (time < 1){
            let calc = (s + 1) * time - s
            let calc2 = time * time * calc
            return 0.5 * calc2;
        }
        else {
            time = time - 2;
            
            let c1 = time * time
            let c2 = ((s + 1) * time + s)
            return 0.5 * (c1 * c2 + 2)
            //return 0.5 * (time * time * ((s + 1) * time + s) + 2);
        }
    }
}
*/
class Back:Ease {
    var _sValue:Float = 2.2;
    
    override init(type:EaseType = .linear, props:[String:Float]? = nil){
        super.init(type: type)
        
        if let ps = props {
            for p in ps {
                if p.key == "s" {
                    _sValue = p.value
                }
            }
        }
    }
    
    override func copy( with zone: NSZone? = nil) -> Ease {
        return Back(type: type, props:["s":_sValue])
    }
    
    override var easeInNumber:Float {
        let calc = ((_sValue + 1) * time - _sValue)
        return time * time * calc;
    }
    
    override var easeOutNumber:Float {
        let t = time - 1;
        let c1 = t * t
        let c2 = (_sValue + 1) * t + _sValue
        return c1 * c2 + 1
        //return time * time * ((_sValue + 1) * time + _sValue) + 1;
    }
    
    override var easeInOutNumber:Float {
        //println("easeInOut")
        time = time * 2;
        let s = _sValue * 1.525;
        if (time < 1){
            let calc = (s + 1) * time - s
            let calc2 = time * time * calc
            return 0.5 * calc2;
        }
        else {
            time = time - 2;
            
            let c1 = time * time
            let c2 = ((s + 1) * time + s)
            return 0.5 * (c1 * c2 + 2)
            //return 0.5 * (time * time * ((s + 1) * time + s) + 2);
        }
    }
}
