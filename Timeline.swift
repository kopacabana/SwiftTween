//
//  Timeline.swift
//  EDF
//
//  Created by Loic Brunot on 09/10/2020.
//  Copyright © 2020 Loic Brunot. All rights reserved.
//

import UIKit


// ************************************************************************************************* //
// ************************************************************************************************* //
// ************************************************************************************************* //
final class Timeline: NSObject {
    //var tTweens = [M_GroupTweens]()                 // Tableau qui contient les tweens à traiter (TweenSCN et M_TweenPause
    //var tMarkers = [M_MarkerTimeline]()                     // Tableau qui contient les markers de la timeline
    //var indiceTween:Int = 0                                 // Indice de la tween en cours d'éxécution
    
    private var loop:CADisplayLink!                         // EnterFrame
    private var currentLoop:Int = 0                         // Pour connaître le nombre de répétition effectués
    private var isStarted = false                           // Permet de savoir si la séquence est en cours de lecture
    
    private var onComplete:((Timeline)->())?            // Callback COMPLETE
    private var onUpdate:((Timeline)->())?              // Callback UPDATE
    private var onStart:((Timeline)->())?               // Callback START
    private var onReverse:((Timeline)->())?             // Callback REVERSE
    
    private var timelapse:Double = 0.0
    private var nbFrames:Int = 0
    private var lastTimestamp:Double = 0.0
    //private var forceCalculateBoolEndTime = false
    
    
    /** Valeur pour remapper les valeurs temporelles (l'ensemble) */
    var timeScale:Float = 1.0
    /** Permet de régler la vitesse de lecture de la séquence (ralentis et accélérés) */
    var speedFactor:Float = 1.0
    
    /** Temps courant dans la séquence */
    var currentTime:Float = 0.0
    
    // Dernière tween ajoutée
    var tStartLastTw:Float = 0.0, tEndLastTw:Float = 0.0
    
    /** Temps cumulé pour les tweens */
    var cumulTime:Float = 0.0
    /** Durée totale de la séquence */
    var totalTime:Float = 0.0
    /** Progression totale de la séquence (sous forme de ratio 0.0 > 1.0) */
    var totalProgress:Float = 0.0
    
    /** Permet d'indiquer si la séquence doit être lue d'avant en arrière et inversement */
    var isYoyo = false
    /** Nombre de répétition de la séquence. Si 0 (aucun répétition), si -1 (répétition infinie), au dessus de 0 (nombre défini) */
    var nbLoop = 0
    /** Sens de lecture de la séquence (1.0 ou -1.0) */
    var sensLoop:Int = 1
    /** Séquence en cours de lecture ou non */
    var isPlaying = false
    
    /** Séquence en cours de lecture ou non */
    var name = "sans-nom"
    
    // Sous la forme target:(UIView, UILabel...)
    var tTweensTL:[TweenTL] = [TweenTL]()
    
    
    
    // *************************************************************************************** //
    // *************************************************************************************** //
    // *************************************************************************************** //
    // CONSTRUCTEUR
    
    init(timeScale tS:Float = 1.0, speedFactor sF:Float = 1.0, isYoyo:Bool = false, nbLoop:Int = 0, events:[String: (Timeline)->Void] = Dictionary()) {
        super.init()
        
        // Stocke les propriétés ----------------------------------------------------------------------
        self.timeScale = tS
        self.speedFactor = sF
        self.isYoyo = isYoyo
        self.nbLoop = nbLoop
        
        // CALLBACKS -----------------------------------------------------------------------------------
        onStart     = events["onStart"]
        onUpdate    = events["onUpdate"]
        onComplete  = events["onComplete"]
        onReverse   = events["onReverse"]
        
        
        // Initialise la loop --------------------------------------------------------------------------
        setupLoop()
    }
    
    /** Fonction pour initialiser la loop */
    private func setupLoop() {
        loop = CADisplayLink(target: self, selector: #selector(onLoop))
        loop.preferredFramesPerSecond = 60
    }
    
    
    
    // *************************************************************************************** //
    // *************************************************************************************** //
    // *************************************************************************************** //
    // AJOUT/SUPPRESSION TweensGroup/Tween/Pause
    
    /** Fonction pour vérifier si la cible est déjà traitée pour l'animation.
    Si ce n'est pas le cas, création d'un nouveau modèle M_TweenTL et ajout au tableau */
    private func commonAdds(target:UIView) -> TweenTL {
        // Vérifie si la cible est déjà dans le tableau
        for t in tTweensTL {
            if t.target == target { return t }
        }
        
        // Création d'une nouvelle instance TweenTL en passant la cible et en stockant ses valeurs par défaut
        let tween = TweenTL(target: target)
        // Ajoute une nouvelle entrée
        tTweensTL.append(tween)
        // Renvoi la tween
        return tween
    }
    
    /** Fonction pour ajouter un nouveau tween en spécifiant le temps d'entrée et la durée
    - parameter target : Cible sur laquelle appliquée le tween (UIView ou UILabel
    - parameter startTime :Temps à laquelle débute la tween.
    Possibilité de passer une valeur absolue (nombre), relative par rapport au temps total "+=2" ou "-=1.4" ou en fonction de la dernière tween rentrée "<1" (au début + 1 seconde), ">-0.2" à la fin moins 0.2 secondes.
    - parameter duration : Durée du tween, exprimé en seconde
    - parameter props : Dictionnaire qui contient les clés à animer de type PropTween et les valeurs associées (Float, UIColor...)
    - parameter events : Dictionnaire qui contient les évènements de type callbacks qui peuvent être écoutés (onStart, onUpdate, onComplete) de type M_TweenEventKey.
    - example :
    ~~~
    // Déclaration de l'instance d'une timeline
    let tl = Timeline(...)
    // Ajout d'un nouveau tween sur un élément donné
    tl.add(target:cube, startTime:"<-0.2", duration:2.0,
     props:[.pX:200, .pY:-50, .sX:0.5, .alpha:0.5],
     events:[
        .onStart:callbackFunction(_:)
     ]
     )
     // Fonction appelée par .onStart (type:M_TweenEventKey)
     func callbackFunction(_ m:M_TweenEventKey)  {
        print(m.progress)
     }
    ~~~
     */
    func add(target:UIView, startTime sT:Any = 0.0, duration dur:Float = 1.0, props:[PropTween:Any]? = nil, events:[TweenEventType: (M_TweenEventKey)->Void]? = nil) {
        let tween:TweenTL = commonAdds(target: target)
       
        // Injecte les propriétés dans la tween
        if let props = props {
            // Il faut dupliquer la ease, sinon elles s'écrasent entre elles
            let ease:Ease = props[.ease] != nil ? props[.ease] as! Ease : Linear(type: .linear)
            
            let delay:Float = props[.delay] != nil ? G.transtypeToFloat(props[.delay]) : Float(0.0)
            let ignoreTime = props[.ignoreTime] != nil ? G.transtypeToBool(props[.ignoreTime]) : false
            let isFromInitialState = props[.fromInitialState] != nil ? G.transtypeToBool(props[.fromInitialState]) : false
            let parseT = parseTime(sT)
            let startTime = parseT < 0.0 ? totalTime : parseT
            
            if isFromInitialState {
                // Assigne les valeurs par défaut
                tween.addInitialTweenKey(time: totalTime + dur + delay, ease: nil)
            }
            else {
                for prop in props {
                    if(prop.key == .pX || prop.key == .pY || prop.key == .sX || prop.key == .sY || prop.key == .r || prop.key == .alpha || prop.key == .color || prop.key == .textColor || prop.key == .fontSize) {
                        // Génère la clé d'entrée
                        tween.addPrevTweenKey(property: prop.key, time: startTime + delay, ease: nil)
                        // Génère la clé de sortie
                        tween.addTweenKey(property: prop.key, time: startTime + delay + dur, value: prop.value, ease: ease.copy())
                    }
                }
            }
            
            // ---------------------------------------------------------------
            // EVENEMENTS
            if let evts = events {
                if evts.keys.contains(.onStart){
                    if let callback = evts.first(where: {$0.key == .onStart})?.value {
                        tween.addTweenEventKey(time: startTime + delay, events: [.onStart:callback])
                    }
                }
                if evts.keys.contains(.onComplete){
                    if let callback = evts.first(where: {$0.key == .onComplete})?.value {
                        tween.addTweenEventKey(time: startTime + delay + dur, events: [.onComplete:callback])
                    }
                }
                if evts.keys.contains(.onUpdate){
                    if let callback = evts.first(where: {$0.key == .onUpdate})?.value {
                        tween.addTweenEventKey(timeStart: startTime + delay, timeEnd: startTime + delay + dur, events: [.onUpdate:callback])
                    }
                }
            }
            
            // ----------------------------------------------------------------
            // Ajoute les durées si elles doivent être prises en compte
            //print("ignoreTime:\(ignoreTime), parseT:\(parseT), startTime:\(startTime), dur:\(dur), delay:\(delay)")
            
            if ignoreTime == false {
                if parseT < 0.0 {
                    totalTime += dur + delay
                    tStartLastTw = startTime
                    tEndLastTw = startTime + dur + delay
                }
                else {
                    totalTime = max(totalTime, startTime + dur + delay)
                    tStartLastTw = startTime
                    tEndLastTw = startTime + dur + delay
                }
            }
            
            //print("Temps\n\t .totalTime:", totalTime, "secondes\n\t .tStartLastTw:\(tStartLastTw)\n\t .tEndLastTw:\(tEndLastTw)")
        }
    }
    
    /** Fonction pour ajouter un nouveau tween en spécifiant uniquement la durée (Ajoute la tween à la fin de la timeline)
    - parameter target : Cible sur laquelle appliquée le tween (UIView ou UILabel
    - parameter duration : Durée du tween, exprimé en seconde
    - parameter props : Dictionnaire qui contient les clés à animer de type PropTween et les valeurs associées (Float, UIColor...)
    - parameter events : Dictionnaire qui contient les évènements de type callbacks qui peuvent être écoutés (onStart, onUpdate, onComplete) de type M_TweenEventKey.
    - example :
    ~~~
    // Déclaration de l'instance d'une timeline
    let tl = Timeline(...)
    // Ajout d'un nouveau tween sur un élément donné
    tl.add(target:cube, duration:2.0,
     props:[.pX:200, .pY:-50, .sX:0.5, .alpha:0.5],
     events:[
        .onStart:callbackFunction(_:)
     ]
     )
     // Fonction appelée par .onStart (type:M_TweenEventKey)
     func callbackFunction(_ m:M_TweenEventKey)  {
        print(m.progress)
     }
    ~~~
     */
    func add(target:UIView, duration dur:Float = 0.0, props:[PropTween:Any]? = nil, events:[TweenEventType: (M_TweenEventKey)->Void]? = nil) {
        self.add(target: target, startTime: -1.0, duration: dur, props: props, events: events)
    }
    
    /*
    /** Fonction pour ajouter un marker de Timeline */
    func add(marker:M_MarkerTimeline) {
        marker.startTime = totalTime
        
        // Création d'un groupe de Tweens (0>juste une pause / 1>une seule tween / x>plusieurs tweens au même instant T
        tMarkers.append(marker)
    }
    */
    
    
    // *************************************************************************************** //
    // *************************************************************************************** //
    // *************************************************************************************** //
    // CONTRÔLES LECTURE SEQUENCE
    
    /** Fonction pour démarrer la lecture de la séquence à l'instant 0.0. */
    func play() {
        // Vérifie si les valeurs M_TweenSet ont bien un temps de fin. Sans quoi on passe la durée totale de la séquence
        //if !forceCalculateBoolEndTime { forceCalculateBooleansEndTime() }
        
        currentLoop = 0
        cumulTime = 0.0
        currentTime = 0.0
        sensLoop = 1
        isStarted = false
        isPlaying = true
        lastTimestamp = -1.0
        
        //indiceTween = 0
        
        // Mise en place de la boucle ENTER_FRAME
        loop.add(to: RunLoop.current, forMode: RunLoop.Mode.common)
        loop.isPaused = false
        
        //activeTweens = tTweens[indiceTween].tweens
        
        // Démarre le décompte de temps
        //G.startElapse()
        //print("PLAY ANIMATOR\nTaille en mémoire", class_getInstanceSize(SCN_Timeline.self), lastTimestamp, currentTime)
    }
    /** Fonction pour mettre en pause la lecture de la séquence. */
    func pause() {
        loop.isPaused = true
        isPlaying = false
    }
    /** Fonction pour relancer la lecture de la séquence après une mise en pause */
    func resume() {
        lastTimestamp = -1.0
        
        loop.isPaused = false
        isPlaying = true
    }
    /** Fonction pour démarrer la lecture de la séquence à l'instant 0.0  sans écraser le nombre de loop ni le isStarted. */
    private func restartLoop() {
        cumulTime = 0.0
        currentTime = 0.0
        sensLoop = 1
        
        lastTimestamp = loop.timestamp
        
        //indiceTween = 0
        //activeTweens = tTweens[indiceTween].tweens
        
        loop.isPaused = false
    }
    /** Fonction pour arrêter la lecture de la séquence et supprimer la loop. */
    func stop() {
        loop.invalidate()
        isPlaying = false
    }
    /** Fonction pour inverser la lecture de la séquence. */
    func reverse() {
        sensLoop *= -1
    }
    
    /** Fonction pour assigner les valeurs des différents Tweens à un instant. */
    func set(ratio:Float) {
        set(time: ratio * totalTime)
    }
    func set(time:Float) {
        pause()
        
        
        // -----------------------------------------------------------------
        // Temps courant de la séquence
        currentTime = time;
        
        // -----------------------------------------------------------------
        // Ratio du temps
        totalProgress = fminf(1.0, fmaxf(0.0, currentTime / totalTime))
        
        // -----------------------------------------------------------------
        // Update des tweens actives
        for t in tTweensTL {
            t.update(time: currentTime, sensLoop: sensLoop)
        }
    }
    
    
    
    // *************************************************************************************** //
    // *************************************************************************************** //
    // *************************************************************************************** //
    // GESTION LOOP
    
    /** Fonction pour gérer la logique d'animation de la séquence */
    @objc private func onLoop(){
        nbFrames += 1
        timelapse = G.elapseNum()
        
        // -----------------------------------------------------------------
        // Vérifie si le timestamp est éligible
        if lastTimestamp < 0.0 {
            lastTimestamp = loop.timestamp
        }
        
        // Temps courant de la séquence
        let ts = loop.timestamp
        //currentTime += (Float(loop.duration) * speedFactor) * Float(sensLoop)
        currentTime += (Float(ts - lastTimestamp) * speedFactor) * Float(sensLoop)
        //print(ts - lastTimestamp, ts, lastTimestamp, currentTime, Float(ts - lastTimestamp) * speedFactor)
        
        // Stocke la dernière valeur de timestamp
        lastTimestamp = ts
        
        // -----------------------------------------------------------------
        // Ratio du temps
        totalProgress = fminf(1.0, fmaxf(0.0, currentTime / totalTime))
        
        //print("Timeline > onLoop :", self.name)
        
        // -----------------------------------------------------------------
        // Update des tweens actives
        for t in tTweensTL {
            t.update(time: currentTime, sensLoop: sensLoop)
        }
        
        
        // -----------------------------------------------------------------
        // Si le temps dépasse la durée totale
        if(sensLoop > 0 && currentTime >= totalTime) {
            // Inverse le sens de lecture et continue la lecture
            if isYoyo {
                sensLoop = -1
                onReverse?(self)
            }
            else if nbLoop == -1 {
                // Réinitialise les valeurs par défaut
                for t in tTweensTL { t.reinitLastValues() }
                // Relance au début
                restartLoop()
            }
            else if nbLoop > 0 && currentLoop < nbLoop {
                currentLoop += 1
                // Réinitialise les valeurs par défaut
                for t in tTweensTL { t.reinitLastValues() }
                // Relance au début
                restartLoop()
            }
            else {
                //print("Complete Timeline")
                
                // Met la séquence en pause
                pause()
                onComplete?(self)
                return
            }
        }
        else if(sensLoop < 0 && currentTime <= 0) {
            // Vérifie si il faut relancer la séquence ou ono
            if nbLoop == -1 {
                onReverse?(self)
                // Relance au début
                restartLoop()
            }
            else if nbLoop > 0 && currentLoop < nbLoop {
                currentLoop += 1
                onReverse?(self)
                // Relance au début
                restartLoop()
            }
            else {
                // Met la séquence en pause
                pause()
                onComplete?(self)
                return
            }
        }
        
        // -----------------------------------------------------------------
        // -----------------------------------------------------------------
        // Callbacks
        if(isStarted == false) {
            isStarted = true
            onStart?(self)
        }
        else {
            onUpdate?(self)
        }
        
        //print("currentTime", currentTime, " | totalProgress:", totalProgress, " | tweenProgress:", tweenProgress)
    }
    
    
    
    // *************************************************************************************** //
    // *************************************************************************************** //
    // *************************************************************************************** //
    // UTILITAIRES
    
    /** Debug
    - parameter getTweens : Permet d'indiquer si on souhaite afficher les infos relatives aux tweens contenues dans la timeline
     */
    func log(getTweens:Bool = true) -> String {
        var str = "// ********************************* //"
        str += "\n// ********************************** //"
        str += "\n// ********************************** //"
        str += "\n CLASSE Timeline"
        str += "\n-------------------------------------"
        str += "\n\t .timeScale:\(timeScale)\n\tspeedFactor:\(speedFactor)"
        str += "\n\t .currentTime:\(String(format:"%2f", currentTime))\n\t.cumulTime:\(String(format:"%2f", cumulTime))"
        str += "\n\t .totalTime:\(totalTime)\n\t.totalProgress:\(totalProgress)"
        str += "\n\t .duration:\(loop.duration)\n\t.timestamp:\(loop.timestamp)"
        str += "\n\t .isYoyo:\(isYoyo) // .nbLoop:\(nbLoop) // .sensLoop:\(sensLoop)"
        
        // Si on souhaite afficher la vzleur des tweens
        if getTweens {
            str += "\n-------------------------------------"
            for t in tTweensTL {
                str += "\n"
                str += t.log()
            }
        }
        
        return str
    }
    
    // *************************************************************************************** //
    /** Fonction pour redimensionner la durée de l'ensemble des tweens présentes */
    func rescaleTime(scaleTimeFactor t:Float) {
        timeScale = t
    }
    /** Fonction qui vérifie si les valeurs M_TweenSet ont bien un temps de fin. Sans quoi on passe la durée totale de la séquence */
    /*
    func forceCalculateBooleansEndTime() {
        if !forceCalculateBoolEndTime {
            for grp in tTweens {
                for t in grp.tweens! {
                    if t is M_TweenSet && t.startTime == t.endTime {
                        t.endTime = totalTime
                        t.duration = t.endTime - t.startTime
                    }
                }
            }
            
            forceCalculateBoolEndTime = true
        }
    }
 */
    /** Fonction pour renvoyer le FPS */
    func getFPS() -> String {
        return "FPS : \(Double(nbFrames) / (timelapse * 0.001))i/s"
    }
    
    // *************************************************************************************** //
    /** Fonction pour passer le temps qui peut être absolu ou relatif */
    private func parseTime(_ param:Any) -> Float {
        if let vInt = param as? Int {
            return Float(vInt)
        }
        else if let vDouble = param as? Double {
            return Float(vDouble)
        }
        else if let vFloat = param as? Float {
            return vFloat
        }
        else if let vCGFloat = param as? CGFloat {
            return Float(vCGFloat)
        }
        else if let vString = param as? String {
            if vString.contains(find: "<") {
                // Au début de la dernière tween ajoutée > Possibilité de faire +1 ou encore -1 (+x/-X)
                
                // Extrait le nombre et le renvoie
                if vString.count == 1 {
                    return tStartLastTw
                }
                else if vString.contains(find: "+") {
                    return tStartLastTw + Float(vString.replacingOccurrences(of: " ", with: "").substringFromIndex(2))!
                }
                else if vString.contains(find: "-") {
                    return tStartLastTw - Float(vString.replacingOccurrences(of: " ", with: "").substringFromIndex(2))!
                }
                else {
                    return tStartLastTw + Float(vString.replacingOccurrences(of: " ", with: "").substringFromIndex(1))!
                }
            }
            else if vString.contains(find: ">") {
                // A la fin de la dernière tween ajoutée > Possibilité de faire +1 ou encore -1 (+x/-X)
                
                // Extrait le nombre et le renvoie
                if vString.count == 1 {
                    return tEndLastTw
                }
                else if vString.contains(find: "+") {
                    return tEndLastTw + Float(vString.replacingOccurrences(of: " ", with: "").substringFromIndex(2))!
                }
                else if vString.contains(find: "-") {
                    return tEndLastTw - Float(vString.replacingOccurrences(of: " ", with: "").substringFromIndex(2))!
                }
                else {
                    return tEndLastTw + Float(vString.replacingOccurrences(of: " ", with: "").substringFromIndex(1))!
                }
            }
            else if vString.contains(find: "+=") {
                // Relatif à la fin de la timeline > Ajoute
                
                // Extrait le nombre et le renvoie
                return totalTime + Float(vString.replacingOccurrences(of: " ", with: "").substringFromIndex(2))!
            }
            else if vString.contains(find: "-=") {
                // Relatif à la fin de la timeline > Soustrait
                
                // Extrait le nombre et le renvoie
                return totalTime - Float(vString.replacingOccurrences(of: " ", with: "").substringFromIndex(2))!
            }
            else if vString.count > 0 {
                // Recherche un marker (position temporelle)
            }
        }
        return 0.0
    }
    
    // *************************************************************************************** //
    /** Pour supprimer proprement */
    func kill() {
        for t in tTweensTL { t.kill() }
        tTweensTL.removeAll()
        //tMarkers.removeAll()
        
        loop.invalidate()
        loop = nil
        
        onComplete = nil
        onUpdate = nil              // Callback UPDATE
        onStart = nil               // Callback START
        onReverse = nil             // Callback REVERSE
    }
    
}
