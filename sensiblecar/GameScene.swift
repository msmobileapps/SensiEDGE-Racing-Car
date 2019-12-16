//
//  GameScene.swift
//  sensiblecar
//
//  Created by Omer Cohen on 12/9/19.
//  Copyright © 2019 Omer Cohen. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var car:Car!
    
    //X central point position of road tracks.
    let POSITION_TRACK_1: CGFloat = 0.275 //103,125
    let POSITION_TRACK_2: CGFloat = 0.5 //187,5
    let POSITION_TRACK_3: CGFloat = 0.725 //271,875
    
    let POSITION_MOVE:CGFloat = 0.225
    
    var textureEnemyUp = SKTexture()
    var textureEnemyDown = SKTexture()
    var blueTextureEnemyUp = SKTexture()
    var blueTextureEnemyDown = SKTexture()
    var greenTextureEnemyUp = SKTexture()
    var greenTextureEnemyDown = SKTexture()
    var whiteRedCarUp = SKTexture()
    var whiteRedCarDown = SKTexture()
    var blackTextureEnemyDown = SKTexture()
    var blackTextureEnemyUp = SKTexture()
    
    var backgroundState: BackgroundState = .DAY
    var liveTexture = SKTexture()
    let logoSplashScreen: UIImageView = UIImageView()
    let defaults = UserDefaults.standard

        
    let PROBABILITY_LIVE = 0.05
    
    struct physicsCategory {
        static let car: UInt32 = 1
        static let enemy: UInt32 = 2
        static let live: UInt32 = 3
    }
    
    let enemys = SKNode()
    let roads = SKNode()
    let grasses = SKNode()
    
    var xTrackPositions: [UInt32:CGFloat] = [:]
    var enemyColorTextures: [UInt32:String] = [:]
    
    var score = NSInteger()
    let scoreLabel = SKLabelNode()
    let batteryLabel = SKLabelNode()
    var batteryPercents: NSNumber = 0
    
    var lives:Int = 3//3
    var live1 = SKSpriteNode()
    var live2 = SKSpriteNode()
    var live3 = SKSpriteNode()
    var live4 = SKSpriteNode()
    var live5 = SKSpriteNode()
    
    let SCORE_BETWEEN_LIVES:Int = 50;
    var lastLive: Int = 0;
    
    var textureCarUp = SKTexture()
    var textureCarDown = SKTexture()
    
    var gameStatus:GameStatus = GameStatus.loading
    enum GameStatus{
        case loading
        case playing
    }
    let smoke = SKEmitterNode(fileNamed: "Smoke")!
    
    override func didMove(to view: SKView) {
        
        GameViewController.isOnlyPortrait = false
        
        self.backgroundColor = UIColor.clear
        
        self.physicsWorld.contactDelegate = self
        
        self.initializeApp()
        
        print("la pantalla mide \(self.frame.size)")
    }
    
    /* Fix tracks positions, defines enemies color and prepare scene*/
    func initializeApp(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateCarPosition(_:)), name: .CarPosition, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateBackgroundState(_:)), name: .LightStatus, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateBattery(_:)), name: .BatteryStatus, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
        
        self.setTextures()
        self.showBar()
        self.showBackground()
        self.showPlayer()
        
        let isLogoLoaded = defaults.bool(forKey: "isLogoLoded")

        if !isLogoLoaded {
            self.addLogoSplashScreen()
        }
        
        xTrackPositions[1] = POSITION_TRACK_1 * self.frame.size.width
        xTrackPositions[2] = POSITION_TRACK_2 * self.frame.size.width
        xTrackPositions[3] = POSITION_TRACK_3 * self.frame.size.width
        
        enemyColorTextures[1] = "Red"
        enemyColorTextures[2] = "Blue"
        enemyColorTextures[3] = "Yellow"
        enemyColorTextures[4] = "Green"
        enemyColorTextures[5] = "Black"
        
        //Enemigos
        textureEnemyUp = SKTexture(imageNamed: "greenCarUp")
        textureEnemyUp.filteringMode = SKTextureFilteringMode.nearest
        
        textureEnemyDown = SKTexture(imageNamed: "greenCarDown")
        textureEnemyDown.filteringMode = SKTextureFilteringMode.nearest
        self.addChild(enemys)
        self.startEnemyCycle()
        
        smoke.position = CGPoint(x:self.car.node.position.x, y:self.car.node.position.y)
        smoke.targetNode = self
        addChild(smoke)
        
        self.gameStatus = .playing
    }
    
    func addLogoSplashScreen(){
        let img = UIImage(named: "ms-apps-logo")
        if let view = view{
            
            if UIDevice.current.orientation.isPortrait {
                logoSplashScreen.frame = CGRect(x: 25, y: UIScreen.main.bounds.size.width * 0.55, width: UIScreen.main.bounds.size.width / 25, height: UIScreen.main.bounds.size.width / 6)
                logoSplashScreen.transform = CGAffineTransform(rotationAngle: .pi / 6)
            } else if UIDevice.current.orientation.isLandscape {
                logoSplashScreen.frame = CGRect(x: 125, y: UIScreen.main.bounds.size.height * 0.45, width: UIScreen.main.bounds.size.height / 20, height: UIScreen.main.bounds.size.height / 5)
                logoSplashScreen.transform = CGAffineTransform(rotationAngle: .pi / 6)
            }
            
            logoSplashScreen.image = img
            logoSplashScreen.isUserInteractionEnabled = true
            let tapGestureRecognizerTime = UITapGestureRecognizer(target: self, action: #selector(imageTimeTapped))
            tapGestureRecognizerTime.numberOfTapsRequired = 1
            logoSplashScreen.addGestureRecognizer(tapGestureRecognizerTime)
            view.addSubview(logoSplashScreen)
            saveUserDefault()
        }
    }
    @objc func imageTimeTapped(_ sender: UITapGestureRecognizer) {
      if let url = URL(string: "http://www.msapps.mobi") {
               if UIApplication.shared.canOpenURL(url) {
                   if #available(iOS 10.0, *) {
                       UIApplication.shared.open(url, options: [:], completionHandler: nil)
                   } else {
                       UIApplication.shared.openURL(url)
                   }
               }
           }
    }
    
    func saveUserDefault() {
        defaults.set(true, forKey: "isLogoLoded")
    }
    
    @objc func rotated() {
        if UIDevice.current.orientation.isPortrait {
            logoSplashScreen.transform = CGAffineTransform(rotationAngle: -(.pi / 6))
            logoSplashScreen.frame = CGRect(x: 25, y: UIScreen.main.bounds.size.width * 0.55, width: UIScreen.main.bounds.size.width / 25, height: UIScreen.main.bounds.size.width / 6)
            logoSplashScreen.transform = CGAffineTransform(rotationAngle: .pi / 6)
        } else if UIDevice.current.orientation.isLandscape {
            logoSplashScreen.transform = CGAffineTransform(rotationAngle: -(.pi / 6))
            logoSplashScreen.frame = CGRect(x: 125, y: UIScreen.main.bounds.size.height * 0.45, width: UIScreen.main.bounds.size.height / 20, height: UIScreen.main.bounds.size.height / 5)
            logoSplashScreen.transform = CGAffineTransform(rotationAngle: .pi / 6)
        }
    }

    @objc func updateCarPosition(_ notification:Notification){
        
        if(self.gameStatus == .playing){
            guard let status = notification.object as? Car.Status else{
                return
            }
            if status == .left {
                self.car.turnLeft()
            }
            else if status == .right {
                self.car.turnRight()
                //self.moveCarTo(position: POSITION_MOVE)
            }
            else{
                self.car.turnCenter()
            }
            self.moveCarTo(position: self.car.status)
        }
        
    }
    
    @objc func updateBackgroundState(_ notification: Notification){
        
        if(self.gameStatus == .playing){
            guard let state = notification.object as? BackgroundState else{
                return
            }
            if state == .DAY && backgroundState == .NIGHT{
                changeBackgroundTo(.NIGHT)
                changeCarsLightsTo(.NIGHT)
                backgroundState = .DAY
            }else if state == .NIGHT && backgroundState == .DAY{
                changeBackgroundTo(.DAY)
                changeCarsLightsTo(.DAY)
                backgroundState = .NIGHT
            }
        }
    }
    
    @objc func updateBattery(_ notification:Notification){
        
        if(self.gameStatus == .playing){
            guard let battery = notification.object as? NSNumber else{
                return
            }
            batteryPercents = battery
        }
    }
    
    func setTextures(){
        textureCarUp = SKTexture(imageNamed: "CarUp")
        textureCarUp.filteringMode = SKTextureFilteringMode.nearest
        
        textureCarDown = SKTexture(imageNamed: "CarDown")
        textureCarDown.filteringMode = SKTextureFilteringMode.nearest
        
        liveTexture = SKTexture(imageNamed: "live")
        liveTexture.filteringMode = SKTextureFilteringMode.nearest
        
        blueTextureEnemyUp = SKTexture(imageNamed: "OrangeEnemyUp")
        blueTextureEnemyUp.filteringMode = SKTextureFilteringMode.nearest
        
        blueTextureEnemyDown = SKTexture(imageNamed: "OrangeEnemyDown")
        blueTextureEnemyDown.filteringMode = SKTextureFilteringMode.nearest
        
        greenTextureEnemyUp = SKTexture(imageNamed: "WhiteEnemyUp")
        greenTextureEnemyUp.filteringMode = SKTextureFilteringMode.nearest
        
        greenTextureEnemyDown = SKTexture(imageNamed: "WhiteEnemyDown")
        greenTextureEnemyDown.filteringMode = SKTextureFilteringMode.nearest
        
        whiteRedCarUp = SKTexture(imageNamed: "whiteRedCarUp")
        whiteRedCarUp.filteringMode = SKTextureFilteringMode.nearest
        
        whiteRedCarDown = SKTexture(imageNamed: "whiteRedCarDown")
        whiteRedCarDown.filteringMode = SKTextureFilteringMode.nearest
        
        blackTextureEnemyUp = SKTexture(imageNamed: "BlackCarUp")
        blackTextureEnemyUp.filteringMode = SKTextureFilteringMode.nearest
        
        blackTextureEnemyDown = SKTexture(imageNamed: "BlackCarDown")
        blackTextureEnemyDown.filteringMode = SKTextureFilteringMode.nearest
        
    }
    
    func changeCarsLightsTo(_ state:BackgroundState){
        if state == .NIGHT{
            textureCarUp = SKTexture(imageNamed: "CarUpNight")
            textureCarUp.filteringMode = SKTextureFilteringMode.nearest
            
            textureCarDown = SKTexture(imageNamed: "CarDownNight")
            textureCarDown.filteringMode = SKTextureFilteringMode.nearest
            
            blueTextureEnemyUp = SKTexture(imageNamed: "OrangeEnemyUpNight")
            blueTextureEnemyUp.filteringMode = SKTextureFilteringMode.nearest
            
            blueTextureEnemyDown = SKTexture(imageNamed: "OrangeEnemyDownNight")
            blueTextureEnemyDown.filteringMode = SKTextureFilteringMode.nearest
            
            greenTextureEnemyUp = SKTexture(imageNamed: "WhiteEnemyUpNight")
            greenTextureEnemyUp.filteringMode = SKTextureFilteringMode.nearest
            
            greenTextureEnemyDown = SKTexture(imageNamed: "WhiteEnemyDownNight")
            greenTextureEnemyDown.filteringMode = SKTextureFilteringMode.nearest
            
            textureEnemyUp = SKTexture(imageNamed: "greenCarUpNight")
            textureEnemyUp.filteringMode = SKTextureFilteringMode.nearest
            
            textureEnemyDown = SKTexture(imageNamed: "greenCarDownNight")
            textureEnemyDown.filteringMode = SKTextureFilteringMode.nearest
            
            whiteRedCarUp = SKTexture(imageNamed: "whiteRedCarUpNight")
            whiteRedCarUp.filteringMode = SKTextureFilteringMode.nearest
            
            whiteRedCarDown = SKTexture(imageNamed: "whiteRedCarDownNight")
            whiteRedCarDown.filteringMode = SKTextureFilteringMode.nearest
            
            blackTextureEnemyUp = SKTexture(imageNamed: "BlackCarUpNight")
            blackTextureEnemyUp.filteringMode = SKTextureFilteringMode.nearest
            
            blackTextureEnemyDown = SKTexture(imageNamed: "BlackCarDownNight")
            blackTextureEnemyDown.filteringMode = SKTextureFilteringMode.nearest
        }else if state == .DAY{
            textureCarUp = SKTexture(imageNamed: "CarUp")
            textureCarUp.filteringMode = SKTextureFilteringMode.nearest
            
            textureCarDown = SKTexture(imageNamed: "CarDown")
            textureCarDown.filteringMode = SKTextureFilteringMode.nearest
            
            blueTextureEnemyUp = SKTexture(imageNamed: "OrangeEnemyUp")
            blueTextureEnemyUp.filteringMode = SKTextureFilteringMode.nearest
            
            blueTextureEnemyDown = SKTexture(imageNamed: "OrangeEnemyDown")
            blueTextureEnemyDown.filteringMode = SKTextureFilteringMode.nearest
            
            greenTextureEnemyUp = SKTexture(imageNamed: "WhiteEnemyUp")
            greenTextureEnemyUp.filteringMode = SKTextureFilteringMode.nearest
            
            greenTextureEnemyDown = SKTexture(imageNamed: "WhiteEnemyDown")
            greenTextureEnemyDown.filteringMode = SKTextureFilteringMode.nearest
            
            textureEnemyUp = SKTexture(imageNamed: "greenCarUp")
            textureEnemyUp.filteringMode = SKTextureFilteringMode.nearest
            
            textureEnemyDown = SKTexture(imageNamed: "greenCarDown")
            textureEnemyDown.filteringMode = SKTextureFilteringMode.nearest
            
            whiteRedCarUp = SKTexture(imageNamed: "whiteRedCarUp")
            whiteRedCarUp.filteringMode = SKTextureFilteringMode.nearest
            
            whiteRedCarDown = SKTexture(imageNamed: "whiteRedCarDown")
            whiteRedCarDown.filteringMode = SKTextureFilteringMode.nearest
            
            blackTextureEnemyUp = SKTexture(imageNamed: "BlackCarUp")
            blackTextureEnemyUp.filteringMode = SKTextureFilteringMode.nearest
            
            blackTextureEnemyDown = SKTexture(imageNamed: "BlackCarDown")
            blackTextureEnemyDown.filteringMode = SKTextureFilteringMode.nearest
        }
    }
    
    func showBar() {
        //Banner
        let infoBar = SKSpriteNode(color: UIColor.brown , size: CGSize(width: self.size.width, height: (self.size.height)*0.075))
        infoBar.anchorPoint = CGPoint.zero
        infoBar.position = CGPoint(x: 0, y:(self.size.height - ((self.size.height)*0.075)))
        infoBar.zPosition = 11
        self.addChild(infoBar)
        
        let blackLine = SKSpriteNode(color: UIColor.black, size: CGSize(width: self.size.width, height: 5))
        blackLine.anchorPoint = CGPoint.zero
        blackLine.position = CGPoint(x: 0, y: self.size.height - 100)
        blackLine.zPosition = 12
        self.addChild(blackLine)
        
        self.lastLive = 0;
        
        self.batteryLabel.fontName = "Arial"
        self.batteryLabel.fontSize = 30
        self.batteryLabel.alpha = 1
        self.batteryLabel.position = CGPoint(x: self.frame.width*0.60, y: self.frame.height-70)
        self.batteryLabel.zPosition = 12
        if batteryPercents != 0{
            self.batteryLabel.text = "Battery: \(batteryPercents)%"
        }
        else{
            self.batteryLabel.text = ""
        }
        self.addChild(self.batteryLabel)
        
        self.score = 0
        self.scoreLabel.fontName = "Arial"
        self.scoreLabel.fontSize = 40
        self.scoreLabel.alpha = 1
        self.scoreLabel.position = CGPoint(x: self.frame.width*0.85, y: self.frame.height-70)
        self.scoreLabel.zPosition = 12
        self.scoreLabel.text = "Score: \(score)"
        self.addChild(self.scoreLabel)
        
        live1 = SKSpriteNode(texture: textureCarUp)
        live1.setScale(0.6)
        live1.position = CGPoint(x: self.frame.width*0.1, y: self.frame.height-60)
        live1.zPosition = 12
        self.addChild(live1)
        live2 = SKSpriteNode(texture: textureCarUp)
        live2.setScale(0.6)
        live2.position = CGPoint(x: self.frame.width*0.2, y: self.frame.height-60)
        live2.zPosition = 12
        self.addChild(live2)
        live3 = SKSpriteNode(texture: textureCarUp)
        live3.setScale(0.6)
        live3.position = CGPoint(x: self.frame.width*0.3, y: self.frame.height-60)
        live3.zPosition = 12
        self.addChild(live3)
        live4 = SKSpriteNode(texture: textureCarUp)
        live4.setScale(0.6)
        live4.position = CGPoint(x: self.frame.width*0.4, y: self.frame.height-60)
        live4.zPosition = 12
        live4.isHidden = true
        self.addChild(live4)
        live5 = SKSpriteNode(texture: textureCarUp)
        live5.setScale(0.6)
        live5.position = CGPoint(x: self.frame.width*0.5, y: self.frame.height-60)
        live5.zPosition = 12
        live5.isHidden = true
        self.addChild(live5)
    }
    
    func showBackground() {
        
        //        let textureGrass = SKTexture(imageNamed: "Grass")
        //        textureGrass.filteringMode = SKTextureFilteringMode.nearest
        //
        //        let grassMovement = SKAction.moveBy(x: 0.0, y: -textureGrass.size().height, duration: 3)
        //        let resetGrass = SKAction.moveBy(x: 0.0, y: textureGrass.size().height, duration: 0.0)
        //        let continuousGrassMovement = SKAction.repeatForever(SKAction.sequence([grassMovement, resetGrass]))
        //
        //        for i:Int in 0 ..< Int(2 + self.frame.size.height/textureGrass.size().height) {
        //            let grass = SKSpriteNode(texture: textureGrass)
        //            grass.anchorPoint = CGPoint.zero
        //            grass.position = CGPoint(x: 0, y: i*Int(grass.size.height))
        //            grass.size.width = view?.frame.width ?? 2000
        //            grass.zPosition = -10
        //            grass.run(continuousGrassMovement)
        //            grasses.addChild(grass)
        //        }
        
        //        if let grassImage = UIImage(named: "Grass"){
        ////            grassImage = resizeImage(image: grassImage, targetSize: view?.frame.size ?? CGSize(width: 2000, height: 2000))
        //            let grassView = UIImageView(image: grassImage)
        //            view?.addSubview(grassView)
        //            view?.sendSubviewToBack(grassView)
        //        }
        
        //Añadir la carretera
        let textureRoad = SKTexture(imageNamed: "RoadDay")
        textureRoad.filteringMode = SKTextureFilteringMode.nearest
        
        let roadMovement = SKAction.moveBy(x: 0.0, y: -textureRoad.size().height, duration: 3)
        let resetRoad = SKAction.moveBy(x: 0.0, y: textureRoad.size().height, duration: 0.0)
        let continuousRoadMovement = SKAction.repeatForever(SKAction.sequence([roadMovement, resetRoad]))
        
        for i:Int in 0 ..< Int(2 + self.frame.size.height/textureRoad.size().height) {
            let road = SKSpriteNode(texture: textureRoad)
            road.anchorPoint = CGPoint.zero
            road.position = CGPoint(x: 0, y: i*Int(road.size.height))
            road.size.width = self.size.width
            road.zPosition = -10
            road.run(continuousRoadMovement)
            roads.addChild(road)
        }
        self.addChild(roads)
    }
    
    func showPlayer() {
        let carMovement = SKAction.animate(with: [textureCarDown, textureCarUp], timePerFrame: 0.30)
        let driving = SKAction.repeatForever(carMovement)
        
        car = Car()
        car.node = SKSpriteNode(texture: textureCarUp)
        
        car.node.position = CGPoint(x: self.frame.size.width/2, y: 100)
        car.node.zPosition = 11
        car.node.name = "car"
        
        //Colisiones
        car.node.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: car.node.size.width*0.8, height: car.node.size.height*0.8))
        car.node.physicsBody?.affectedByGravity = false
        car.node.physicsBody?.allowsRotation = false
        car.node.physicsBody?.categoryBitMask = physicsCategory.car
        car.node.physicsBody?.contactTestBitMask = physicsCategory.enemy
        car.node.physicsBody?.isDynamic = true
        //car.node.physicsBody?.collisionBitMask = categoryEnemy
        
        car.node.run(driving)
        
        self.addChild(car.node)
    }
    
    func startEnemyCycle() {
        let createEnemy = SKAction.run({ () in self.manageEnemies()})
        let delayEnemies = SKAction.wait(forDuration: 0.8)
        let createNextEnemy = SKAction.sequence([createEnemy, delayEnemies])
        let continuousEnemies = SKAction.repeatForever(createNextEnemy)
        enemys.run(continuousEnemies)
    }
    
    func manageEnemies() {
        let textures = self.getRandomEnemyTexture()
        
        if(textures.count == 1){ //if thats true means its a live.
            let live:SKSpriteNode = SKSpriteNode(texture: textures[0])
            
            live.position = CGPoint(x: xTrackPositions[arc4random_uniform(3) + 1]! , y: self.frame.height + live.size.height)
            live.zPosition = 10
            live.setScale(0.6)
            live.name = "live"
            
            let reduceLive = SKAction.scale(by: 0.8, duration: 0.5)
            
            let continuousScale = SKAction.repeatForever(SKAction.sequence([reduceLive, reduceLive.reversed()]))
            live.run(continuousScale)
            
            live.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width:live.size.width*0.8,height:live.size.height*0.8))
            live.physicsBody?.affectedByGravity = false
            live.physicsBody?.allowsRotation = false
            live.physicsBody?.categoryBitMask = physicsCategory.live
            live.physicsBody?.contactTestBitMask = physicsCategory.car
            live.physicsBody?.isDynamic = true
            
            let liveRide = SKAction.move(to: CGPoint(x: live.position.x, y: -live.frame.height) , duration: 4)
            let removeLive = SKAction.removeFromParent()
            
            let liveCycle = SKAction.sequence([liveRide, removeLive])
            
            live.run(liveCycle)
            enemys.addChild(live)
            
        } else { //normal enemy
            
            let enemyMovement = SKAction.animate(with:textures, timePerFrame: 0.30)
            let drivingEnemy = SKAction.repeatForever(enemyMovement)
            
            let enemy = SKSpriteNode(texture: textures[0])
            
            enemy.position = CGPoint(x: xTrackPositions[arc4random_uniform(3) + 1]! , y: self.frame.height + enemy.size.height)
            enemy.zPosition = 10
            enemy.name = "enemy"
            enemy.run(drivingEnemy)
            
            //Colisions
            enemy.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width:enemy.size.width*0.8,height:enemy.size.height*0.8))
            enemy.physicsBody?.affectedByGravity = false
            enemy.physicsBody?.allowsRotation = false
            enemy.physicsBody?.categoryBitMask = physicsCategory.enemy
            enemy.physicsBody?.contactTestBitMask = physicsCategory.car
            enemy.physicsBody?.isDynamic = true
            //enemy.physicsBody?.collisionBitMask = categoryCar
            
            
            let enemyRide = SKAction.move(to: CGPoint(x: enemy.position.x, y: -enemy.frame.height) , duration: 4)
            let removeEnemy = SKAction.removeFromParent()
            
            let enemyCycle = SKAction.sequence([enemyRide, removeEnemy])
            
            enemy.run(enemyCycle)
            enemys.addChild(enemy)
            if self.enemys.speed < 4 {
                self.enemys.speed = self.enemys.speed + 0.015
            }
            if(self.car.node.speed < 2){
                self.car.node.speed = self.car.node.speed + 0.0075
            }
            if(self.roads.speed < 2){
                self.roads.speed = self.roads.speed + 0.015
            }
            self.lastLive += 1
            self.score += 1
            self.scoreLabel.text = "Score: \(score)"
            //print("SPEED ENEMY:::\(self.enemys.speed) AND CAR::\(self.car.node.speed)")
        }
    }
    
    /* Move the car between tracks */
    func moveCarTo(position:Car.Status){
        var pos = POSITION_TRACK_2
        switch position {
        case .left:
            pos = POSITION_TRACK_1
        case .center:
            pos = POSITION_TRACK_2
        case .right:
            pos = POSITION_TRACK_3
        }
        if car != nil{
            let moveAction = SKAction.move(to: CGPoint(x:(self.frame.size.width) * pos, y: 100), duration: 0.5)
            self.smoke.run(moveAction)
            self.car.node.run(moveAction)
        }
    }
    
    /* Get random color car enemy */
    func getRandomEnemyTexture() -> [SKTexture] {
        var result:[SKTexture]
        let color = enemyColorTextures[arc4random_uniform(5) + 1]!
        
        let ranNum:Double = Double(arc4random_uniform(100) + 1)
        let probability = (PROBABILITY_LIVE * 100)
        let isLive = ranNum < probability
        
        if(isLive && self.lastLive > SCORE_BETWEEN_LIVES){
            self.lastLive = 0
            result = [liveTexture]
        } else {
            switch color {
            case "Yellow":
                result = [whiteRedCarUp, whiteRedCarDown]
            case "Blue":
                result = [blueTextureEnemyUp, blueTextureEnemyDown]
            case "Red":
                result = [textureEnemyUp, textureEnemyDown]
            case "Green":
                result = [greenTextureEnemyUp, greenTextureEnemyDown]
            case "Black":
                result = [blackTextureEnemyUp, blackTextureEnemyDown]
            default:
                result = [textureEnemyUp, textureEnemyDown]
            }
        }
        
        return result
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let a = contact.bodyA.node?.name
        let b = contact.bodyB.node?.name
        
        print("han chocado: \(String(describing: a)) con \(String(describing: b))")
        let isLive = (a == "car" && b == "live") || (a == "live" && b == "car")
        
        if (a == "live"){
            contact.bodyA.node?.removeFromParent()
        } else {
            contact.bodyB.node?.removeFromParent()
        }
        
        if(isLive) { //collision player/live
            self.increaseLive()
        } else {
            self.decraseLive()
        }
    }
    
    /* Decrease game live*/
    func decraseLive(){
        self.gameStatus = .loading
        self.lives -= 1
        if lives == 0 {
            live1.isHidden = true
            
            let gameOverScene = GameOverScene(size:self.size)
            gameOverScene.scaleMode = scaleMode
            gameOverScene.score = self.score
            
            let transition = SKTransition.flipVertical(withDuration: 1.0)
            view?.presentScene(gameOverScene, transition:transition)
        } else { //collision player/enemy
            switch(self.lives) {
            case 3:
                live4.isHidden = true
            case 2:
                live3.isHidden = true
            case 1:
                live2.isHidden = true
            default:
                break
            }
            
            self.pauseMovement()
            self.gameStatus = .playing
            let continueGame = SKAction.run({ () in self.restartGame()})
            let delayRestart = SKAction.wait(forDuration: 1)
            let cont = SKAction.sequence([delayRestart, continueGame])
            self.run(cont)
            
            car.node.run(delayRestart)
            self.updateParticle()
        }
        
    }
    
    /* Increase game live */
    func increaseLive(){
        if(lives == 4){
            score += 10
        } else {
            score += 5
            self.lives += 1
            switch(self.lives) {
            case 4:
                live4.isHidden = false
            case 3:
                live3.isHidden = false
            case 2:
                live2.isHidden = false
            default:
                break
            }
            self.updateParticle()
        }
    }
    
    /* Restart screen movement between lives */
    func restartGame(){
        self.car.node.position = CGPoint(x: self.frame.size.width/2, y: 100)
        self.smoke.position = self.car.node.position
        self.startEnemyCycle()
    }
    
    /* Pause screen movement between lives */
    func pauseMovement(){
        enemys.removeAllChildren()
        enemys.removeAllActions()
    }
    
    func updateParticle(){
        switch(self.lives){
        case 1:
            self.smoke.particleBirthRate = 50;
            self.smoke.xAcceleration = 100;
            self.smoke.yAcceleration = 60;
            self.smoke.particleScaleSpeed = 0.5;
        case 2:
            self.smoke.particleBirthRate = 50;
            self.smoke.xAcceleration = 10;
            self.smoke.yAcceleration = 10;
            self.smoke.particleScaleSpeed = 0.0;
        default:
            self.smoke.particleBirthRate = 0;
        }
    }
    
    func touchDown(atPoint pos : CGPoint) {
    }
    
    func touchMoved(toPoint pos : CGPoint) {
    }
    
    func touchUp(atPoint pos : CGPoint) {
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //print("he tocado en: \(touches.first!.location(in: self.view))")
        //        if(self.gameStatus == .playing){
        //            if touches.first!.location(in: self.view).x < (self.view?.frame.width)!/2 {
        //                self.car.turnLeft()
        //            } else {
        //                self.car.turnRight()
        //                //self.moveCarTo(position: POSITION_MOVE)
        //            }
        //            self.moveCarTo(position: self.car.status)
        //        }
        
        //        if backgroundState == .DAY{
        //            changeBackgroundTo(.NIGHT)
        //            backgroundState = .NIGHT
        //        }else{
        //            changeBackgroundTo(.DAY)
        //            backgroundState = .DAY
        //        }
    }
    
    func changeBackgroundTo(_ state: BackgroundState){
        let textureRoad = SKTexture(imageNamed: state.rawValue)
        textureRoad.filteringMode = SKTextureFilteringMode.nearest
        let roadMovement = SKAction.moveBy(x: 0.0, y: -textureRoad.size().height, duration: 3)
        let resetRoad = SKAction.moveBy(x: 0.0, y: textureRoad.size().height, duration: 0.0)
        let continuousRoadMovement = SKAction.repeatForever(SKAction.sequence([roadMovement, resetRoad]))
        
        roads.removeAllChildren()
        
        for i:Int in 0 ..< Int(2 + self.frame.size.height/textureRoad.size().height) {
            let newRoad = SKSpriteNode(texture: textureRoad)
            newRoad.anchorPoint = CGPoint.zero
            newRoad.position = CGPoint(x: 0, y: i*Int(newRoad.size.height))
            newRoad.size.width = self.size.width
            newRoad.zPosition = -10
            newRoad.run(continuousRoadMovement)
            roads.addChild(newRoad)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
}
