//
//  Sine.swift
//  GTween
//
//  Created by Goon Nguyen on 10/10/14.
//  Copyright (c) 2014 Goon Nguyen. All rights reserved.
//

import Foundation
/*
struct Sine {
    
    static var easeIn:String { return "Sine.easeIn" }
    static var easeOut:String { return "Sine.easeOut" }
    static var easeInOut:String { return "Sine.easeInOut" }
    
}

class ModeSine {
    var time:Float!
    var _sValue:Float = 1.70158;
    
    init(){
        
    }
    
    var easeInNumber:Float {
        let t = cos(Double(time) * .pi/2)
        return Float(1.0 - t);
    }
    
    var easeOutNumber:Float {
        return Float(sin(Double(time) * .pi/2));
    }
    
    var easeInOutNumber:Float {
        return -0.5 * Float((cos(.pi * Double(time)) - 1.0));
    }
}
*/
class Sine:Ease {
    override func copy( with zone: NSZone? = nil) -> Ease {
        return Sine(type: type, props: nil)
    }
    
    override var easeInNumber:Float {
        let t = cos(Double(time) * .pi/2)
        return Float(1.0 - t);
    }
    
    override var easeOutNumber:Float {
        return Float(sin(Double(time) * .pi/2));
    }
    
    override var easeInOutNumber:Float {
        return -0.5 * Float((cos(.pi * Double(time)) - 1.0));
    }
}
