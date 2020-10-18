//
//  Cubic.swift
//  GTween
//
//  Created by Goon Nguyen on 10/10/14.
//  Copyright (c) 2014 Goon Nguyen. All rights reserved.
//

import Foundation
/*
struct Cubic {
    static var easeIn:String { return "Cubic.easeIn" }
    static var easeOut:String { return "Cubic.easeOut" }
    static var easeInOut:String { return "Cubic.easeInOut" }
}

class ModeCubic {
    var time:Float!
    var _sValue:Float = 1.70158;
    
    init(){
        
    }
    
    var easeInNumber:Float {
        return time * time * time;
    }
    
    var easeOutNumber:Float {
        time = time - 1.0;
            return time * time * time + 1.0;

    }
    
    var easeInOutNumber:Float {
        time = time * 2.0;
        if (time < 1.0){
            return 0.5 * time * time * time;
        }
        
        time = time - 2.0;
        return 0.5 * (time * time * time + 2.0);
    }
}
*/
class Cubic:Ease {
    
    override func copy( with zone: NSZone? = nil) -> Ease {
        return Cubic(type: type, props: nil)
    }
    
    override var easeInNumber:Float {
        return time * time * time;
    }
    
    override var easeOutNumber:Float {
        let t:Float = time - 1.0;
        return t * t * t + 1.0;
    }
    
    override var easeInOutNumber:Float {
        var t:Float = time * 2.0;
        if (t < 1.0){
            return 0.5 * t * t * t;
        }
        
        t = time * 2.0 - 2.0;
        return 0.5 * (t * t * t + 2.0);
    }
}
