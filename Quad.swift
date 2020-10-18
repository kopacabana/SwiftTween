//
//  Quad.swift
//  GTween
//
//  Created by Goon Nguyen on 10/10/14.
//  Copyright (c) 2014 Goon Nguyen. All rights reserved.
//

import Foundation
/*
struct Quad {
    
    static var easeIn:String { return "Quad.easeIn" }
    static var easeOut:String { return "Quad.easeOut" }
    static var easeInOut:String { return "Quad.easeInOut" }
    
}

class ModeQuad {
    var time:Float!
    var _sValue:Float = 1.70158;
    
    init(){
        
    }
    
    var easeInNumber:Float {
        return time * time;
    }
    
    var easeOutNumber:Float {
        return -time * (time - 2.0);
    }
    
    var easeInOutNumber:Float {
        time = time * 2.0;
        if (time < 1.0){
            return 0.5 * time * time;
        }
        
        time = time - 1;
        return -0.5 * (time * (time - 2.0) - 1.0);
    }
}
*/
class Quad:Ease {
    override func copy( with zone: NSZone? = nil) -> Ease {
        return Quad(type: type, props: nil)
    }
    
    override var easeInNumber:Float {
        return time * time;
    }
    
    override var easeOutNumber:Float {
        return -time * (time - 2.0);
    }
    
    override var easeInOutNumber:Float {
        var t = time * 2.0;
        if (t < 1.0){
            return 0.5 * t * t;
        }
        
        t = time * 2.0 - 1;
        return -0.5 * (t * (t - 2.0) - 1.0)
    }
}
