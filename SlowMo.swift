//
//  SlowMo.swift
//  EDF
//
//  Created by Loic Brunot on 07/10/2020.
//  Copyright © 2020 Loic Brunot. All rights reserved.
//

import UIKit

class SlowMo: Ease {
    var _pValue:Float = 0.7;        // Power
    var _p1:Float = 0.0;
    var _p2:Float = 0.0;
    var _p3:Float = 0.0;
    var _lValue:Float = 0.7;        // Linear Ratio
    var _calcEnd = false
    
    override init(type:EaseType = .linear, props:[String:Float]? = nil){
        super.init(type: type)
        
        if let ps = props {
            for p in ps {
                if p.key == "p" { _pValue = p.value }
                else if p.key == "l" { _lValue = min(1.0, p.value) }
            }
        }
        
        _pValue = _lValue != 1.0 ? _pValue : 0.0
        _p1 = (1 - _lValue) / 2;
        _p2 = _lValue;
        _p3 = _p1 + _p2;
    }
    
    override func copy( with zone: NSZone? = nil) -> Ease {
        return SlowMo(type: type, props: ["p": _pValue, "l": _lValue])
    }
    
    override var easeNumber: Float {
        let r:CGFloat = CGFloat(time + (0.5 - time) * _pValue);
        
        if (time < _p1) {
            if (_calcEnd) {
                let tm = 1 - (time / _p1)
                return 1 - tm * tm
            }
            else {
                let tm = 1 - (time / _p1)
                let calc = CGFloat(tm * tm * tm * tm)
                return Float(r - (calc * r))
            }
            //return _calcEnd ? 1 - ((time = 1 - (time / _p1)) * time) : r - ((time = 1 - (time / _p1)) * time * time * time * r);
        }
        else if (time > _p3) {
            if (_calcEnd) {
                let tm = (time - _p3) / _p1
                return 1 - (tm * tm)
            }
            else {
                let tm = (time - _p3) / _p1
                let calc = (time - Float(r)) * tm * tm
                return Float(r) + (calc * tm * tm)
            }
            //return _calcEnd ? 1 - (time = (time - _p3) / _p1) * time : r + ((time - r) * (time = (time - _p3) / _p1) * time * time * time);
        }
        
        return Float(_calcEnd ? 1 : r);
    }
}


/*
 https://github.com/greensock/GreenSock-AS2/blob/master/src/com/greensock/easing/SlowMo.as
 public function SlowMo(linearRatio:Number, power:Number, yoyoMode:Boolean) {
             power = (power || power == 0) ? power : 0.7;
             if (linearRatio == undefined) {
                 linearRatio = 0.7;
             } else if (linearRatio > 1) {
                 linearRatio = 1;
             }
             _p = (linearRatio != 1) ? power : 0;
             _p1 = (1 - linearRatio) / 2;
             _p2 = linearRatio;
             _p3 = _p1 + _p2;
             _calcEnd = (yoyoMode == true);
         }
         
         public function getRatio(p:Number):Number {
             let r:Number = p + (0.5 - p) * _p;
             if (p < _p1) {
                 return _calcEnd ? 1 - ((p = 1 - (p / _p1)) * p) : r - ((p = 1 - (p / _p1)) * p * p * p * r);
             } else if (p > _p3) {
                 return _calcEnd ? 1 - (p = (p - _p3) / _p1) * p : r + ((p - r) * (p = (p - _p3) / _p1) * p * p * p);
             }
             return _calcEnd ? 1 : r;
         }
 */
