//
//  GameViewController.swift
//  sensiblecar
//
//  Created by Omer Cohen on 12/9/19.
//  Copyright © 2019 Omer Cohen. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import CoreBluetooth
import BlueSTSDK


class GameViewController: UIViewController, CBCentralManagerDelegate {
    
    var centralManager: CBCentralManager!
    var mAvailableFeatures = [Any]()
    var node: BlueSTSDKNode?
    
    private var mManager:BlueSTSDKManager!
    fileprivate var mNodes:[BlueSTSDKNode] = []
    var peripheralDevice: CBPeripheral!
    
    var isAccelometerDefined = false
    var isLuminosityDefined = false
    var isBatteryDefined = false
    var xValue:NSNumber?
    var check = true
    
    let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
    let imgSplashScreen: UIImageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async { [unowned self] in
            self.addImageSplashScreen()
            self.showActivityIndicatory(uiView: self.view)
        }
        
        mManager = BlueSTSDKManager.sharedInstance
        mManager.addDelegate(self)
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("central.state is .unknown")
        case .resetting:
            print("central.state is .resetting")
        case .unsupported:
            print("central.state is .unsupported")
        case .unauthorized:
            print("central.state is .unauthorized")
        case .poweredOff:
            print("central.state is .poweredOff")
            addAlert(title: "Bluetooth Disconnected", msg: "Please turn on the blutooth connection", btn: "Open Bluetooth Settings", handler: { _ in
                let url = URL(string:"App-Prefs:root=Bluetooth")
                let app = UIApplication.shared
                app.open(url!, options: [:], completionHandler: nil)
            }, action: nil)
        case .poweredOn:
            print("central.state is .poweredOn")
            mManager.discoveryStart(10*1000)
        @unknown default:
            print("default")
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mNodes.removeAll()
        isAccelometerDefined = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        mAvailableFeatures = node?.getFeatures() ?? []
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        centralManager.cancelPeripheralConnection(peripheralDevice)
    }
    
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .portraitUpsideDown
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func addAlert(title: String, msg: String, btn: String, handler: ((UIAlertAction) -> Void)?, action:UIAlertAction?){
        let alert = UIAlertController(title:title, message:msg, preferredStyle: .alert)
        let okay = UIAlertAction(title: btn, style: .default, handler: handler)
        alert.addAction(okay)
        if let action = action{
            alert.addAction(action)
        }
        present(alert, animated: true, completion: nil)
    }
}

extension GameViewController: BlueSTSDKManagerDelegate, BlueSTSDKFeatureDelegate, BlueSTSDKFeatureAutoConfigurableDelegate, BlueSTSDKNodeStateDelegate, BlueSTSDKFeatureLogDelegate{
    
    func showActivityIndicatory(uiView: UIView) {
        actInd.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0);
        actInd.center = uiView.center
        actInd.hidesWhenStopped = true
        actInd.style =
            UIActivityIndicatorView.Style.whiteLarge
        uiView.addSubview(actInd)
        actInd.startAnimating()
    }
    
    func addImageSplashScreen(){
        let img = UIImage(named: "SplashScreenImg")
        imgSplashScreen.frame = view.frame
        imgSplashScreen.image = img
        view.addSubview(imgSplashScreen)
    }
    
    func updateUI(){
        
        if let view = self.view as! SKView? {
            self.actInd.stopAnimating()
            self.imgSplashScreen.isHidden = true
            
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "MainMenuScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                scene.anchorPoint = CGPoint.zero
                
                // Present the scene
                view.presentScene(scene)
            }
            view.ignoresSiblingOrder = true
            
            //  view.showsFPS = true
            //  view.showsNodeCount = true
        }
    }
    func feature(_ feature: BlueSTSDKFeature, rawData raw: Data, sample: BlueSTSDKFeatureSample) {
    }
    
    func node(_ node: BlueSTSDKNode, didChange newState: BlueSTSDKNodeState, prevState: BlueSTSDKNodeState) {
        if newState.rawValue == 3{
            DispatchQueue.main.async { [unowned self] in
                self.updateUI()
            }
            if let features = self.mNodes.first?.getFeatures(){
                for feature in features{
                    // print(feature.name)
                    if feature.name == "Accelerometer" && isAccelometerDefined{
                        print(node.isEnableNotification(feature))
                        feature.add(self)
                        feature.addLoggerDelegate(self)
                        print(feature.featureDelegates)
                        if !node.isEnableNotification(feature){
                            node.enableNotification(feature)
                        }
                        print(node.isEnableNotification(feature))
                    }
                    else{
                        isAccelometerDefined = true
                    }
                    
                    if feature.name == "Luminosity" && isLuminosityDefined{
                        feature.add(self)
                        feature.addLoggerDelegate(self)
                        print(feature.featureDelegates)
                        
                        if !node.isEnableNotification(feature){
                            node.enableNotification(feature)
                        }
                    }
                    else{
                        isLuminosityDefined = true
                    }
                    
                    if feature.name == "Battery" && isBatteryDefined{
                        feature.add(self)
                        feature.addLoggerDelegate(self)
                        print(feature.featureDelegates)
                        
                        if !node.isEnableNotification(feature){
                            node.enableNotification(feature)
                        }
                    }
                    else{
                        isBatteryDefined = true
                    }
                    
                }
            }
        } else if newState.rawValue == 5 || newState.rawValue == 6 || newState.rawValue == 7{
            addAlert(title: "Connection Problem", msg: "Can't connect to blutooth device", btn: "OK", handler: nil, action: nil)
        }
    }
    
    func didAutoConfigurationChange(_ feature: BlueSTSDKFeatureAutoConfigurable!, status: Int32) {
        print(feature.name)
    }
    
    func didAutoConfigurationStart(_ feature: BlueSTSDKFeatureAutoConfigurable!) {
        print(feature.name)
    }
    
    func didUpdate(_ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample) {
        
        if feature.name == "Accelerometer"{
            if let sampleFirst = sample.data.first  {
                

                xValue = sampleFirst
                if check{
                    if let xValue = xValue{
                        if Int(truncating: xValue) > 450{
                            print("TURN LEFT ",xValue)
                            NotificationCenter.default.post(name: .CarPosition, object: Car.Status.left)
                        }
                        else if Int(truncating: xValue) < -450{
                            print("TURN RIGHT ",xValue)
                            NotificationCenter.default.post(name: .CarPosition, object: Car.Status.right)
                        }
                        else{
                            print("STAY CENTER ",xValue)
                            NotificationCenter.default.post(name: .CarPosition, object: Car.Status.center)
                        }

                        check = false
                    }
                }
                else{
                    check = true
                }
                
            }
        }else if feature.name == "Luminosity"{
            if let sampleFirst = sample.data.first  {
                if sampleFirst.intValue < 40{
                    NotificationCenter.default.post(name: .LightStatus, object: BackgroundState.DAY)
                }
                else{
                    NotificationCenter.default.post(name: .LightStatus, object: BackgroundState.NIGHT)
                }
            }
        }else if feature.name == "Battery"{
            NotificationCenter.default.post(name: .BatteryStatus, object: sample.data.first)
        }
    }
    
    func manager(_ manager: BlueSTSDKManager, didDiscoverNode: BlueSTSDKNode) {
        DispatchQueue.main.async {
            self.mNodes.append(didDiscoverNode)
        }
        print("NODE!!!! ",didDiscoverNode)
                
        didDiscoverNode.addStatusDelegate(self)
        
        didDiscoverNode.connect()
        
    }
    
    func manager(_ manager: BlueSTSDKManager, didChangeDiscovery: Bool) {
        DispatchQueue.main.async {
        }
    }
}

extension NSNotification.Name{
    static let CarPosition = NSNotification.Name(rawValue: "CarPosition")
    static let LightStatus = NSNotification.Name(rawValue: "LightStatus")
    static let BatteryStatus = NSNotification.Name(rawValue: "BatteryStatus")
}
