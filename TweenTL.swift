//
//  TweenTL.swift
//  EDF
//
//  Created by Loic Brunot on 09/10/2020.
//  Copyright © 2020 Loic Brunot. All rights reserved.
//


// Enumération pour les différents types d'évènements diffusables (callbacks)
enum TweenEventType:String {
    case onStart = "onStart"
    case onComplete = "onComplete"
    case onUpdate = "onUpdate"
}


// Classe pour créer une valeur PropTween et un tabelau qui va contenir les iages clés à animer
final class M_TweenProp {
    var p:PropTween!
    var keys:[M_TweenKey]?
    
    
    
    // ************************************************************************************************* //
    // ************************************************************************************************* //
    // ************************************************************************************************* //

    init(p:PropTween, keys:[M_TweenKey]? = nil) {
        self.p = p
        self.keys = keys
    }
    
    func kill() {
        keys?.removeAll()
        keys = nil
        p = nil
    }
    
}

// Classe pour stocker les valeurs d'une des clés à animer (time, value et ease)
final class M_TweenKey {
    var t:Float = 0.0
    var v:Any? = nil
    var e:Ease? = nil
    var forceInsert = false
    var isRunning = false
    
    
    // ************************************************************************************************* //
    // ************************************************************************************************* //
    // ************************************************************************************************* //

    init(time t:Float, value v:Any, ease e:Ease? = nil, forceInsertion fI:Bool = false) {
        self.t = t
        self.v = v
        self.e = e
        self.forceInsert = fI
    }
    
    
    
    // ************************************************************************************************* //
    // ************************************************************************************************* //
    // ******************************************************************************String(describing: ******)************* //

    func log() -> String {
        return "time:\(self.t), value:\(self.v ?? "Valeur nulle"), ease:\(String(describing: self.e)), forceInsert:\(self.forceInsert)"
    }
}

// Classe pour stocker les événements à diffuser
final class M_TweenEventKey {
    var t:Float = 0.0                                           // Temps de départ
    var tEnd:Float = -1.0                                       // Temps de fin (si il existe, supérieur à 0.0). Sert pour onUpdate
    var progress:Float = 0.0                                    // Ratio temporel, sert pour onUpdate
    //var easeValue:Float = 0.0                                   // Valeur du ease (ne peut pas fonctionner étant donné qu'il peut il y avoir plusieurs simultanément
    
    private var onComplete:((M_TweenEventKey)->())?            // Callback COMPLETE
    private var onUpdate:((M_TweenEventKey)->())?              // Callback UPDATE
    private var onStart:((M_TweenEventKey)->())?               // Callback START
    
    var target:UIView!                                          // Cible
    
    
    // ************************************************************************************************* //
    // ************************************************************************************************* //
    // ************************************************************************************************* //

    init(target:UIView, time t:Float, events:[TweenEventType: (M_TweenEventKey)->Void] = Dictionary()) {
        self.t = t
        self.target = target
        
        onStart     = events[.onStart]
        onUpdate    = events[.onUpdate]
        onComplete  = events[.onComplete]
    }
    
    convenience init(target:UIView, timeStart t:Float, timeEnd tE:Float, events:[TweenEventType: (M_TweenEventKey)->Void] = Dictionary()) {
        self.init(target: target, time: t, events: events)
        self.tEnd = tE
    }
    
    
    
    // ************************************************************************************************* //
    // ************************************************************************************************* //
    // ************************************************************************************************* //
    
    // Fonction pour diffuser les évènements
    func dispatch(ratioTime rT:Float = 0.0) {
        // Stocke le ratio de temps si besoin
        self.progress = rT
        
        // Diffuse les callbacks
        onStart?(self)
        onUpdate?(self)
        onComplete?(self)
    }
    
    
    
    // ************************************************************************************************* //
    // ************************************************************************************************* //
    // ************************************************************************************************* //
    
    // Debug
    func log() -> String {
        return "Time Diffuse:\(self.t), tEnd:\(self.tEnd) -> Events > onStart:\(String(describing: onStart)), onUpdate:\(String(describing: onUpdate)), onComplete:\(String(describing: onComplete))"
    }
    
    // Kill
    func kill() {
        onComplete = nil
        onUpdate = nil
        onStart = nil
        target = nil
    }
}

// Classe pour associer à un objet de type UIView un ensemble de propriétés à animer dessus
final class TweenTL: NSObject {
    // Cible
    public var target:UIView!
    // Propriétés animables
    private var props:[M_TweenProp] = [
        M_TweenProp(p: .pX),
        M_TweenProp(p: .pY),
        M_TweenProp(p: .sX),
        M_TweenProp(p: .sY),
        M_TweenProp(p: .r),
        M_TweenProp(p: .alpha),
        M_TweenProp(p: .hidden),
        M_TweenProp(p: .color),
        M_TweenProp(p: .textColor),
        M_TweenProp(p: .fontSize)
    ]
    // Valeurs par défaut
    private var defaultValues = [(p:PropTween, v:Any)]()
    
    // Valeurs en cours
    private var last_pX:CGFloat = 0.0
    private var last_pY:CGFloat = 0.0
    private var last_sX:CGFloat = 1.0
    private var last_sY:CGFloat = 1.0
    private var last_r:CGFloat = 0.0
    
    // Evénements à diffuser
    private var tEvents:[M_TweenEventKey] = [M_TweenEventKey]()
    
    // Dernier temps où l'update a eu lieu
    private var lastTimeUpdate:Float = 0.0
    
    
    // ************************************************************************************************* //
    // ************************************************************************************************* //
    // ************************************************************************************************* //

    // Constructeur
    init(target:UIView) {
        super.init()
        
        // Stocke une référence à la cible
        self.target = target
        
        // Stocke ses valeurs par défaut
        addDefautValues()
    }
    
    
    
    // ************************************************************************************************* //
    // ************************************************************************************************* //
    // ************************************************************************************************* //

    // Stocke les valeurs par défaut de la cible
    private func addDefautValues() {
        // Objet Transform de la cible
        let trans = self.target.transform
        
        // Position
        defaultValues.append((p: .pX, v: trans.tx))
        defaultValues.append((p: .pY, v: trans.ty))
        
        // Echelle
        defaultValues.append((p: .sX, v: sqrt(pow(trans.a, 2) + pow(trans.c, 2))))
        defaultValues.append((p: .sY, v: sqrt(pow(trans.b, 2) + pow(trans.d, 2))))
        
        // Rotation
        defaultValues.append((p: .r, v: atan2(target.transform.b, target.transform.a)))
        
        // Alpha
        defaultValues.append((p: .alpha, v: target.alpha))
        
        // Hidden
        defaultValues.append((p: .hidden, v: target.isHidden))
        
        // BackgroundColor
        defaultValues.append((p: .color, v: target.backgroundColor ?? UIColor.clear))
        
        
        // Si c'est un type Label ------------------------------------------------------
        if let label = target as? UILabel {
            // Couleur du texte
            defaultValues.append((p: .textColor, v: label.textColor ?? UIColor.clear))
            // Taille du texte
            defaultValues.append((p: .fontSize, v: label.font.pointSize))
        }
        
        //Si c'est un CAShapeLayer
        
        // Si c'est un UIPath
        
       // Stocke les valeurs au temps 0
        reinitLastValues()
    }
    
    // Fonction pour réassigner les valeurs par défaut sur les dernières valeurs à afficher
    func reinitLastValues() {
        // Stocke les dernières valeurs
        last_pX = G.transtypeToCGFloat(defaultValues.first{ $0.p == .pX}?.v ?? 0.0)
        last_pY = G.transtypeToCGFloat(defaultValues.first{ $0.p == .pY}?.v ?? 0.0)
        last_sX = G.transtypeToCGFloat(defaultValues.first{ $0.p == .sX}?.v ?? 1.0)
        last_sY = G.transtypeToCGFloat(defaultValues.first{ $0.p == .sY}?.v ?? 1.0)
        last_r = G.transtypeToCGFloat(defaultValues.first{ $0.p == .r}?.v ?? 1.0)
    }
    
    // ************************************************************************************************* //
    // Fonction pour ajouter un nouveau point clé dans l'animation
    func addTweenKey(property p:PropTween, time t:Float, value v:Any, ease e:Ease? = nil) {
        //print("AddTweenKey", p, t, v, e)
        for prop in self.props {
            //print(prop.p, p, prop.p == p)
            if prop.p == p {
                // Si la clé n'a pas encore été traitée, il faut créer le tableau par défaut et stocker sa valeur par défaut
                if prop.keys == nil {
                    //_he la valeur par défaut
                    for d in self.defaultValues {
                        // si la clé correspond
                        if d.p == p {
                            // Création du tableau avec une première valeur à l'instant T (0.0)
                            prop.keys = [M_TweenKey(time: 0.0, value: d.v, ease:nil)]
                            // Sort de la boucle
                            break
                        }
                    }
                }
                
                // Ajoute la nouvelle clé
                prop.keys!.append(M_TweenKey(time:t, value:v, ease:e))
                
                // Réordonne le tableau keys par la valeur temporelle
                prop.keys = prop.keys!.sorted(by: { $0.t < $1.t })
                
                // Assigne les bonnes valeurs aux clés d'entrées
                var lastValue:Any!
                if let keys = prop.keys {
                    for key in keys {
                        //print("key.forceInsert:\(key.forceInsert), lastValue:\(lastValue), lastEase:\(lastEase)")
                        if key.forceInsert == true { key.v = lastValue }
                        else { lastValue = key.v }
                    }
                }
                
                // Sort de la boucle
                break
            }
        }
    }
    
    // Fonction pour ajouter un nouveau point clé dans l'animation pour signifier le début d'une anim (startKey)
    func addPrevTweenKey(property p:PropTween, time t:Float, ease e:Ease? = nil) {
        //print("AddTweenKey", p, t, v, e)
        for prop in self.props {
            //print(prop.p, p, prop.p == p)
            if prop.p == p {
                // Si la clé n'a pas encore été traitée, il faut créer le tableau par défaut et stocker sa valeur par défaut
                if prop.keys == nil {
                    //_he la valeur par défaut
                    for d in self.defaultValues {
                        // si la clé correspond
                        if d.p == p {
                            // Création du tableau avec une première valeur à l'instant T (0.0)
                            prop.keys = [M_TweenKey(time: 0.0, value: d.v, ease:nil)]
                            // Sort de la boucle
                            break
                        }
                    }
                }
                
                // Ajoute une clé par défaut (comme entrée)
                prop.keys!.append(M_TweenKey(time:t, value:0.0, ease:nil, forceInsertion: true))
                
                // Sort de la boucle
                break
            }
        }
    }
    
    // Fonction pour ajouter un nouveau point clé dans l'animation
    func addInitialTweenKey(time t:Float, ease e:Ease? = nil) {
        //print("AddTweenKey", p, t, v, e)
        for prop in self.props {
            // Si la clé n'a pas encore été traitée, il faut créer le tableau par défaut et stocker sa valeur par défaut
            if prop.keys != nil {
                // Recherche la valeur par défaut
                for d in self.defaultValues {
                    // si la clé correspond
                    if d.p == prop.p {
                        // Création du tableau avec une première valeur à l'instant T (0.0)
                        prop.keys!.append(M_TweenKey(time: t, value: d.v, ease:e))
                        // Sort de la boucle
                        break
                    }
                }
                // Réordonne le tableau keys par la valeur temporelle
                prop.keys = prop.keys!.sorted(by: { $0.t < $1.t })
            }
        }
    }
    
    // Fonction pour ajouter un nouvel évènement à diffuser à un instant t(timeStart) pour onStart et onComplete
    func addTweenEventKey(time t:Float, events:[TweenEventType: (M_TweenEventKey)->Void] = Dictionary()) {
        tEvents.append(M_TweenEventKey(target: target, time: t, events: events))
    }
    // Fonction pour ajouter un nouvel évènement à diffuser durant un laps de temps (timeStart > timeEnd) pour onUpdate
    func addTweenEventKey(timeStart t:Float, timeEnd tE:Float, events:[TweenEventType: (M_TweenEventKey)->Void] = Dictionary()) {
        tEvents.append(M_TweenEventKey(target: target, timeStart: t, timeEnd:tE, events: events))
    }
    
    
    // ************************************************************************************************* //
    // ************************************************************************************************* //
    // ************************************************************************************************* //

    // Fonction pour mettre à l'état de l'objet en fonction de la valeur temporelle de la timeline
    func update(time:Float, sensLoop:Int = 1) {
        //print("UPDATE", time)
        
        // ------------------------------------------------------------------------------
        // Fonction pour renvoyer la valeur du ease
        func calculEase(ratioTime:Float, ease:Ease?) -> Float {
            // Vérifie si un ease associé est défini
            if let e = ease {
                e.time = ratioTime
                return e.easeNumber
            }
            // Sinon renvoie une valeur linéaire qui correspond au ratio temps
            return ratioTime
        }
        
        // Fonction pour mettre à jour les valeurs
        func updateValues(ratioTime ratio:Float, key:M_TweenKey, prevKey:M_TweenKey, prop:M_TweenProp) {
            // Si l'animation n'a pas encore été déclenchée, indique que cette partie est en cours d'animation
            if ratio < 1.0 && key.isRunning == false { key.isRunning = true }
            // Si l'animation a déjà été déclenchée et que le ratio est de 1.0, ça veut dire qu'il stopper l'animation en prenant 1.0 pour avoir la valeur finale désirée
            else if sensLoop == 1 && ratio == 1.0 && key.isRunning == true { key.isRunning = false }
            // Si l'animation a déjà été déclenchée et que le ratio est de 1.0, ça veut dire qu'il stopper l'animation en prenant 1.0 pour avoir la valeur finale désirée
            else if sensLoop == -1 && ratio == 0.0 && key.isRunning == true { key.isRunning = false }
            
            // Calcul la valeur du ease
            let easeNumber = calculEase(ratioTime: ratio, ease: key.e)
            //print("time:\(time), prevKey.t:\(prevKey.t), key.t:\(key.t)\n\t .prevKey.v:\(prevKey.v), key.v:\(key.v)\n\t .prop:\(prop.p)\n\t .ratio:\(ratio), ease:\(key.e), easeNumber:\(easeNumber)")
            
            // Selon le type de propriété
            if prop.p == .pX {
                last_pX = getNewValue(toValue: G.transtypeToCGFloat(key.v ?? 0.0), fromValue: G.transtypeToCGFloat(prevKey.v ?? 0.0), ease: easeNumber)
            }
            else if prop.p == .pY {
                last_pY = getNewValue(toValue: G.transtypeToCGFloat(key.v ?? 0.0), fromValue: G.transtypeToCGFloat(prevKey.v ?? 0.0), ease: easeNumber)
            }
            else if prop.p == .sX {
                last_sX = getNewValue(toValue: G.transtypeToCGFloat(key.v ?? 1.0), fromValue: G.transtypeToCGFloat(prevKey.v ?? 1.0), ease: easeNumber)
            }
            else if prop.p == .sY {
                last_sY = getNewValue(toValue: G.transtypeToCGFloat(key.v ?? 1.0), fromValue: G.transtypeToCGFloat(prevKey.v ?? 1.0), ease: easeNumber)
            }
            else if prop.p == .r {
                last_r = getNewValue(toValue: G.transtypeToCGFloat(key.v ?? 0.0), fromValue: G.transtypeToCGFloat(prevKey.v ?? 0.0), ease: easeNumber)
            }
            else if prop.p == .alpha {
                target.alpha = getNewValue(toValue: G.transtypeToCGFloat(key.v ?? 1.0), fromValue: G.transtypeToCGFloat(prevKey.v ?? 1.0), ease: easeNumber)
            }
            else if prop.p == .hidden {
                //target.isHidden = Bool(value)
            }
            else if prop.p == .color {
                target.backgroundColor = getNewColorValue(toValue: key.v as? UIColor ?? UIColor.clear, fromValue: prevKey.v as? UIColor ?? UIColor.clear, ease: easeNumber)
            }
            else if prop.p == .textColor {
                if let label = target as? UILabel {
                    label.textColor = getNewColorValue(toValue: key.v as? UIColor ?? UIColor.clear, fromValue: prevKey.v as? UIColor ?? UIColor.clear, ease: easeNumber)
                }
            }
            else if prop.p == .fontSize {
                if let label = target as? UILabel {
                    label.font = label.font.withSize(getNewValue(toValue: G.transtypeToCGFloat(key.v ?? 18.0), fromValue: G.transtypeToCGFloat(prevKey.v ?? 18.0), ease: easeNumber))
                    //print(key.v, label.font.pointSize)
                }
            }
        }
        
        // ------------------------------------------------------------------------------
        // Parcours toutes les propriétés animables qui sont différentes de nil
        // Applique les tansofmations seulement après avoir parcouru toutes les propriété animables
        for prop in props {
            //print("----------------------")
            if let keys = prop.keys {
                // Clé précédente (par défaut premier élément du tableau
                var prevKey:M_TweenKey = keys.first!
                
                // Parcours les clés pour trouver la valeur à appliquer
                for key in keys {
                    if(time > 0.0 && time >= prevKey.t && time <= key.t) {
                        if(key.forceInsert == false) {
                            // Calcul le ratio entre prevKey.t et key.t (valeur comprise entre 0.0 et 1.0 mais sans être sûr de passer par 1.0
                            let ratio = (time - prevKey.t) / (key.t - prevKey.t)
                            // Mise à jour des valeurs en fonction du ratio
                            updateValues(ratioTime: ratio, key: key, prevKey: prevKey, prop: prop)
                        }
                        // Stocke la clé en l'interprétant comme la clé previous
                        prevKey = key
                    }
                    
                    // Si le temps dépasse la valeur 't' de la clé (ratio >= 1.0) et que l'anim est toujours prise en compte
                    // Force le ratio à 1.0 pour être sûr que la valeur arrive bien à ce qui est défini dans la tween.
                    // Dans le cas contraire, il peut y avoir des petits décalages
                    if(sensLoop == 1 && key.isRunning == true && time > 0.0 && time >= key.t) {
                        updateValues(ratioTime: 1.0, key: key, prevKey: prevKey, prop: prop)
                    }
                    // TODO: A VERIFIER
                    if(sensLoop == -1 && key.isRunning == true && time > 0.0 && time <= prevKey.t) {
                        updateValues(ratioTime: 0.0, key: key, prevKey: prevKey, prop: prop)
                    }
                    
                    // Stocke la clé en l'interprétant comme la clé previous
                    prevKey = key
                }
            }
        }
        
        // Applique les transformations dans l'ordre scale, rotation, translation
        let tT = CGAffineTransform(translationX: last_pX, y: last_pY)
        let rT = CGAffineTransform(rotationAngle: last_r)
        let sT = CGAffineTransform(scaleX: last_sX, y: last_sY)
        target.transform = sT.concatenating(rT).concatenating(tT)
        
        // Boucle sur le tableau d'évènements
        for event in tEvents {
            if event.tEnd > 0.0 && event.t < lastTimeUpdate && time < event.tEnd {
                event.dispatch(ratioTime: (time - event.t) / (event.tEnd - event.t))
            }
            if event.t > lastTimeUpdate && event.t < time {
                event.dispatch()
            }
        }
        
        // Stocke le dernier temps d'update
        lastTimeUpdate = time
    }
    
    
    
    // ************************************************************************************************* //
    // ************************************************************************************************* //
    // ************************************************************************************************* //

    // Fonction pour obtenir la nouvelle valeur d'une propriété en fonction de la valeur du tween
    private func getNewValue(toValue:CGFloat, fromValue:CGFloat, ease:Float)->CGFloat {
        let changeValue = toValue - fromValue
        return fromValue + changeValue * CGFloat(ease)
    }
    // Fonction pour obtenir la nouvelle valeur d'une propriété UIColor en fonction de la valeur du tween
    private func getNewColorValue(toValue:UIColor, fromValue:UIColor, ease:Float)->UIColor {
        let fV = fromValue.rgba
        let tV = toValue.rgba
        let r = fV.red + (tV.red - fV.red) * CGFloat(ease)
        let g = fV.green + (tV.green - fV.green) * CGFloat(ease)
        let b = fV.blue + (tV.blue - fV.blue) * CGFloat(ease)
        let a = fV.alpha + (tV.alpha - fV.alpha) * CGFloat(ease)
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
    
    
    // ************************************************************************************************* //
    // ************************************************************************************************* //
    // ************************************************************************************************* //

    // Fonction pour debug
    func log() -> String {
        var str = "////////////////////////////////\nInstance TweenTL\n\t .target:\(target)"
        str += "\n-----------------------------\nDefault Values :"
        for d in defaultValues {
            str += "\n\t .\(d.p) : \(d.v)"
        }
        str += "\n-----------------------------\nAnimable Keys :"
        for prop in props {
            if(prop.keys != nil) {
                str += "\n\t .PROP : \(prop.p)"
                for key in prop.keys! {
                    str += "\n\t\t .KEY > \(key.log())"
                }
            }
        }
        str += "\n-----------------------------\nEvents :"
        for evt in tEvents {
            str += "\n\t .EVENT : \(evt.log())"
        }
        
        return str
    }
    
    
    
    // ************************************************************************************************* //
    // ************************************************************************************************* //
    // ************************************************************************************************* //

    // Pour killer proprement l'instance
    func kill() {
        for prop in props { prop.kill() }
        props.removeAll()
        
        // Valeurs par défaut
        defaultValues.removeAll()
        
        // Evénements à diffuser
        for event in tEvents { event.kill() }
        tEvents.removeAll()
        
        // Cible
        target = nil
    }
    
}
