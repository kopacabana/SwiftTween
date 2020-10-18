//
//  Quint.swift
//  GTween
//
//  Created by Goon Nguyen on 10/10/14.
//  Copyright (c) 2014 Goon Nguyen. All rights reserved.
//

import Foundation
/*
struct Quint {
    
    static var easeIn:String { return "Quint.easeIn"}
    static var easeOut:String { return "Quint.easeOut"}
    static var easeInOut:String { return "Quint.easeInOut"}
    
    
}

class ModeQuint {
    var time:Float!
    var _sValue:Float = 1.70158;
    
    init(){
        
    }
    
    var easeInNumber:Float {
        return time * time * time * time * time;
    }
    
    var easeOutNumber:Float {
        time = time - 1.0;
        time *= time * time * time
        return time * time + 1.0;
    }
    
    var easeInOutNumber:Float {
        time = time * 2.0;
            
        if (time < 1.0){
            time *= time * time * time
            return 0.5 * time * time;
        }
        
        time = time - 2.0;
        time *= time
        time *= time
        time *= time
        time *= time
        return 0.5 * (time + 2.0);
    }
}
*/
class Quint:Ease {
    var _sValue:Float = 1.70158;
    
    override func copy( with zone: NSZone? = nil) -> Ease {
        return Quint(type: type, props: nil)
    }
    
    override var easeInNumber:Float {
        return time * time * time * time * time;
    }
    
    override var easeOutNumber:Float {
        var t = time - 1.0;
        t = t * t * t * t * t
        return t + 1.0;
    }
    
    override var easeInOutNumber:Float {
        var t = time * 2.0;
            
        if (t < 1.0){
            t *= t * t * t
            return 0.5 * t * t;
        }
        
        t = time * 2.0 - 2.0;
        t = t * t * t * t * t
        return 0.5 * (t + 2.0);
    }
}
