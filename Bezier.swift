//
//  Bezier.swift
//  ClimatsDeBourgogne
//
//  Created by Loic Brunot on 04/05/2019.
//  Copyright © 2019 Indelebil. All rights reserved.
//

// VOIR : https://github.com/CapsLock-Studio/CHCubicBezier/blob/master/Sources/CubicBezier.swift
// VOIR : https://github.com/hfutrell/BezierKit
/*
 VOIR :  https://stackoverflow.com/questions/35158422/the-and-operators-have-been-deprecated-xcode-7-3
 
 
// These values are established by empiricism with tests (tradeoff: performance VS precision)
let NEWTON_ITERATIONS = 4;
let NEWTON_MIN_SLOPE = 0.001;
let SUBDIVISION_PRECISION = 0.0000001;
let SUBDIVISION_MAX_ITERATIONS = 10;

var kSplineTableSize = 11;
var kSampleStepSize = 1.0 / (kSplineTableSize - 1.0);

var float32ArraySupported = typeof Float32Array === 'function';

func A (aA1, aA2) { return 1.0 - 3.0 * aA2 + 3.0 * aA1; }
func B (aA1, aA2) { return 3.0 * aA2 - 6.0 * aA1; }
func C (aA1)      { return 3.0 * aA1; }

// Returns x(t) given t, x1, and x2, or y(t) given t, y1, and y2.
func calcBezier (aT, aA1, aA2) { return ((A(aA1, aA2) * aT + B(aA1, aA2)) * aT + C(aA1)) * aT; }

// Returns dx/dt given t, x1, and x2, or dy/dt given t, y1, and y2.
func getSlope (aT, aA1, aA2) { return 3.0 * A(aA1, aA2) * aT * aT + 2.0 * B(aA1, aA2) * aT + C(aA1); }

func binarySubdivide (aX, aA, aB, mX1, mX2) {
    var currentX, currentT, i = 0;
    do {
        currentT = aA + (aB - aA) / 2.0;
        currentX = calcBezier(currentT, mX1, mX2) - aX;
        if (currentX > 0.0) {
            aB = currentT;
        } else {
            aA = currentT;
        }
    } while (Math.abs(currentX) > SUBDIVISION_PRECISION && ++i < SUBDIVISION_MAX_ITERATIONS);
    return currentT;
}

func newtonRaphsonIterate (aX, aGuessT, mX1, mX2) {
    for (var i = 0; i < NEWTON_ITERATIONS; ++i) {
        var currentSlope = getSlope(aGuessT, mX1, mX2);
        if (currentSlope === 0.0) {
            return aGuessT;
        }
        var currentX = calcBezier(aGuessT, mX1, mX2) - aX;
        aGuessT -= currentX / currentSlope;
    }
    return aGuessT;
}

func LinearEasing (x) {
    return x;
}

module.exports = func bezier (mX1, mY1, mX2, mY2) {
    if (!(0 <= mX1 && mX1 <= 1 && 0 <= mX2 && mX2 <= 1)) {
        throw new Error('bezier x values must be in [0, 1] range');
    }
    
    if (mX1 === mY1 && mX2 === mY2) {
        return LinearEasing;
    }
    
    // Precompute samples table
    var sampleValues = float32ArraySupported ? new Float32Array(kSplineTableSize) : new Array(kSplineTableSize);
    for (var i = 0; i < kSplineTableSize; ++i) {
        sampleValues[i] = calcBezier(i * kSampleStepSize, mX1, mX2);
    }
    
    func getTForX (aX) {
        var intervalStart = 0.0;
        var currentSample = 1;
        var lastSample = kSplineTableSize - 1;
        
        for (; currentSample !== lastSample && sampleValues[currentSample] <= aX; ++currentSample) {
            intervalStart += kSampleStepSize;
        }
        --currentSample;
        
        // Interpolate to provide an initial guess for t
        var dist = (aX - sampleValues[currentSample]) / (sampleValues[currentSample + 1] - sampleValues[currentSample]);
        var guessForT = intervalStart + dist * kSampleStepSize;
        
        var initialSlope = getSlope(guessForT, mX1, mX2);
        if (initialSlope >= NEWTON_MIN_SLOPE) {
            return newtonRaphsonIterate(aX, guessForT, mX1, mX2);
        } else if (initialSlope === 0.0) {
            return guessForT;
        } else {
            return binarySubdivide(aX, intervalStart, intervalStart + kSampleStepSize, mX1, mX2);
        }
    }
    
    return func BezierEasing (x) {
        // Because JavaScript number are imprecise, we should guarantee the extremes are right.
        if (x === 0) {
            return 0;
        }
        if (x === 1) {
            return 1;
        }
        return calcBezier(getTForX(x), mY1, mY2);
    };
};
*/


import Foundation

/*
struct Bezier {
    static var ease:String { return "Bezier.ease" }
}

class ModeBezier {
    // -----------------------------------------------------------
    var time:Float!
    
    
    // -----------------------------------------------------------
    let NEWTON_ITERATIONS:Int = 4
    let SUBDIVISION_MAX_ITERATIONS:Int = 10
    let NEWTON_MIN_SLOPE:Float = 0.001
    let SUBDIVISION_PRECISION:Float = 0.0000001
    
    var kSplineTableSize:Int = 11
    var kSampleStepSize:Float = 0.0
    
    //var float32ArraySupported = typeof Float32Array === 'function';
    var sampleValues = [Float]()
    
    var mX1:Float = 0.0, mY1:Float = 0.0, mX2:Float = 0.0, mY2:Float = 0.0
    
    

    // -----------------------------------------------------------
    // -----------------------------------------------------------
    // -----------------------------------------------------------
    init(mX1:Float, mY1:Float, mX2:Float, mY2:Float){
        self.mX1 = mX1
        self.mY1 = mY1
        self.mX2 = mX2
        self.mY2 = mY2
        
        kSampleStepSize = 1.0 / (Float(kSplineTableSize) - 1.0)
        
        if (!(0 <= mX1 && mX1 <= 1 && 0 <= mX2 && mX2 <= 1)) {
            //throw Error('bezier x values must be in [0, 1] range');
        }
        
        // Precompute samples table
        for i in 0..<kSplineTableSize {
            sampleValues.append( calcBezier(Float(i) * kSampleStepSize, mX1, mX2))
        }
    }
    
    
    var ease:Float {
        // Because JavaScript number are imprecise, we should guarantee the extremes are right.
        if (time == 0.0) {
            return 0.0;
        }
        if (time == 1.0) {
            return 1.0;
        }
        return calcBezier(getTForX(time), mY1, mY2);
    }
    
    
    
    
    
    
    func A (_ aA1:Float, _ aA2:Float) -> Float  { return 1.0 - 3.0 * aA2 + 3.0 * aA1; }
    func B (_ aA1:Float, _ aA2:Float) -> Float  { return 3.0 * aA2 - 6.0 * aA1; }
    func C (_ aA1:Float)              -> Float  { return 3.0 * aA1; }
    
    // Returns x(t) given t, x1, and x2, or y(t) given t, y1, and y2.
    func calcBezier(_ aT:Float, _ aA1:Float, _ aA2:Float) -> Float { return ((A(aA1, aA2) * aT + B(aA1, aA2)) * aT + C(aA1)) * aT; }
    
    // Returns dx/dt given t, x1, and x2, or dy/dt given t, y1, and y2.
    func getSlope(_ aT:Float, _ aA1:Float, _ aA2:Float) -> Float { return 3.0 * A(aA1, aA2) * aT * aT + 2.0 * B(aA1, aA2) * aT + C(aA1); }
    
    func binarySubdivide (_ aX:Float, _ aA:Float, _ aB:Float, _ mX1:Float, _ mX2:Float) -> Float {
        var aA_t = aA, aB_t = aB
        
        var currentX:Float = 0.0
        var currentT:Float = 0.0
        var i:Int = 0
        
        repeat {
            currentT = aA_t + (aB_t - aA_t) / 2.0;
            currentX = calcBezier(currentT, mX1, mX2) - aX;
            if (currentX > 0.0) {
                aB_t = currentT;
            }
            else {
                aA_t = currentT;
            }
        }
        while (abs(currentX) > SUBDIVISION_PRECISION && i += 1 < SUBDIVISION_MAX_ITERATIONS);
        
        return currentT;
    }
    
    func newtonRaphsonIterate (_ aX:Float, _ aGuessT:Float, _ mX1:Float, _ mX2:Float) -> Float {
        var aGT = aGuessT
        for _ in 0..<NEWTON_ITERATIONS {
            let currentSlope = getSlope(aGuessT, mX1, mX2);
            if (currentSlope == 0.0) {
                return aGT;
            }
            let currentX = calcBezier(aGuessT, mX1, mX2) - aX;
            aGT -= currentX / currentSlope;
        }
        return aGT;
    }

    
    func getTForX (_ aX:Float) -> Float{
        /*
        var intervalStart:Float = 0.0;
        var currentSample:Int = 1;
        var lastSample:Int = kSplineTableSize - 1;
        
        while currentSample != lastSample && sampleValues[currentSample] <= aX {
            ++currentSample
            
            intervalStart += kSampleStepSize;
        }
        --currentSample;
        
        // Interpolate to provide an initial guess for t
        var dist = (aX - sampleValues[currentSample]) / (sampleValues[currentSample + 1] - sampleValues[currentSample]);
        var guessForT = intervalStart + dist * kSampleStepSize;
        
        var initialSlope = getSlope(guessForT, mX1, mX2);
        if (initialSlope >= NEWTON_MIN_SLOPE) {
            return newtonRaphsonIterate(aX, guessForT, mX1, mX2);
        }
        else if (initialSlope == 0.0) {
            return guessForT;
        }
        else {
            return binarySubdivide(aX, intervalStart, intervalStart + kSampleStepSize, mX1, mX2);
        }
         */
        return 0.0
    }
}
*/
