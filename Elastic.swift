//
//  Elastic.swift
//  GTween
//
//  Created by Goon Nguyen on 10/10/14.
//  Copyright (c) 2014 Goon Nguyen. All rights reserved.
//
// VOIR : https://github.com/greensock/GreenSock-AS3/blob/6019d64044fd5f466038c731cfda39301be02edf/src/com/greensock/easing/ElasticInOut.as

import Foundation
/*
struct Elastic {
    static var easeIn:String { return "Elastic.easeIn" }
    static var easeOut:String { return "Elastic.easeOut" }
    static var easeInOut:String { return "Elastic.easeInOut" }
}

class ModeElastic {
    var time:Float!
    
    var _pValue:Float = 0.63;
    var _sValue:Float = 0.63 / 4.0;
    var _aValue:Float = 1.0;
    
    let pi = Float.pi
    
    
    init(){
        
    }
    
    var easeInNumber:Float {
            if (time == 0.0){
                return 0.0;
            }
            if (time == 1.0){
                return 1.0;
            }
            time = time - 1
            
            let postfix = pow(2.0, 10.0 * time);
            let c1 = time - _sValue
            let c2 = c1 * (pi * 2)
            let c3 = sin(c2 / _pValue)
            //var result = postfix * sin((Double(time) - _sValue) * (pi * 2) / _pValue)
            var result = postfix * c3
            result = -result
                
            return Float(result);
        }
    
    var easeOutNumber:Float {
            if (time == 0.0){
                return 0.0;
            }
            if (time == 1.0){
                return 1.0;
            }
            
            //let c1 = sin( (Double(time) - _sValue) * (pi * 2) / _pValue )
            let c4 = pow(2.0, (-10.0 * time))
        
            let c1 = time - _sValue
            let c2 = c1 * (pi * 2)
            let c3 = sin(c2 / _pValue)
            //let result = pow(2.0, (-10.0 * Double(time))) * sin( (Double(time) - _sValue) * (pi * 2) / _pValue ) + 1.0;
            let result = c4 * c3 + 1.0;
                
            return Float(result)
        }
    
    var easeInOutNumber:Float {
        //println("easeInOut")
        if (time == 0.0){
            return 0.0;
        }
        if (time >= 1.0){
            return 1.0;
        }
            
            time = time * 2.0;
            if (time < 1) {
                time = time - 1
                let postfix = pow(2.0, 10.0 * time);
                
                let c1 = time - _sValue
                let c2 = c1 * (pi * 2)
                let c3 = sin(c2 / _pValue)
                
                //let t = postfix * sin((Double(time) - _sValue) * (pi * 2) / _pValue)
                let t = postfix * c3
                var result = 0.5 * t
                result = -result
                return Float(result);
            }
            time = time - 1
            let postfix = pow(2.0, -10.0 * time);
            let c1 = time - _sValue
            let c2 = c1 * (pi * 2)
            let c3 = sin(c2 / _pValue)
            //let result = postfix * sin((Double(time) - _sValue) * (pi * 2) / _pValue) * 0.5 + 1.0;
            let result = postfix * c3 * 0.5 + 1.0;
            return Float(result)
    }
}
*/

class Elastic:Ease {
    var _pValue:Float = 0.0;   // Période
    var _aValue:Float = 0.0;   // Amplitude
    var _p3:Float = 0.0
    
    let pi = Float.pi
    let pi2 = Float.pi * 2.0
    
    override init(type:EaseType = .linear, props:[String:Float]? = nil){
        super.init(type: type)
        
        if let ps = props {
            for p in ps {
                if p.key == "p" { _pValue = p.value }
                else if p.key == "a" { _aValue = p.value }
            }
        }
        
        // Si les valeurs n'ont pas été spécifiées en paramètres
        if(_pValue == 0.0){
            if type == .inOut { _pValue = 0.45 }
            else { _pValue = 0.3 }
        }
        if(_aValue == 0.0){
            _aValue = 1.0
        }
        
        // Calcul de _p3
        let asinCalc = asin(1 / _aValue)
        _p3 = _pValue / pi2 * (asinCalc.isNaN ? 0 : asinCalc)
    }
    
    override func copy( with zone: NSZone? = nil) -> Ease {
        return Elastic(type: type, props:["p":_pValue, "a":_aValue])
    }
    
    override var easeInNumber:Float {
        let t:Float = time - 1.0
        return -(_aValue * pow(2, 10 * t) * sin( (t - _p3) * pi2 / _pValue ));
    }
    
    override var easeOutNumber:Float {
        let t:Float = time
        return _aValue * pow(2, -10 * t) * sin((t - _p3) * pi2 / _pValue ) + 1;
    }
    
    override var easeInOutNumber:Float {
        var t:Float = time * 2.0
        if t < 1.0 {
            t -= 1.0
            return -0.5 * (_aValue * pow(2, 10 * t) * sin((t - _p3) * pi2 / _pValue))
        }
        
        t -= 1.0
        return _aValue * pow(2, -10 * t) * sin((t - _p3) * pi2 / _pValue) * 0.5 + 1.0
    }
}
