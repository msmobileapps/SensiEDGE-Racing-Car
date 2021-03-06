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
    
    let tableView = UITableView()
    
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
    static var isOnlyPortrait = true
    
    let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
    let imgSplashScreen: UIImageView = UIImageView()
    let logoSplashScreen: UIImageView = UIImageView()
    let searchingLabel:UILabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async { [unowned self] in
            self.addTableView()
            self.showSearchingLabel()
        }
                
        mManager = BlueSTSDKManager.sharedInstance
        mManager.addDelegate(self)
        centralManager = CBCentralManager(delegate: self, queue: nil)
//        centralManager.delegate = self
        
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
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                  return
                }
                if UIApplication.shared.canOpenURL(settingsUrl)  {
                  if #available(iOS 10.0, *) {
                    UIApplication.shared.open(settingsUrl)
                  }
                  else  {
                    UIApplication.shared.openURL(settingsUrl)
                  }
                }
            }, action: nil)
        case .poweredOn:
            print("central.state is .poweredOn")
            mManager.discoveryStart() //mManager.discoveryStart(10*1000)
            central.scanForPeripherals(withServices: nil, options: nil)
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
            return .portrait
        } else {
            if GameViewController.isOnlyPortrait{
                return .portrait
            }else{
                return .allButUpsideDown
            }
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
    
    /*
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let mAdvertiseFilters:[BlueSTSDKAdvertiseFilter] = BlueSTSDKManager.DEFAULT_ADVERTISE_FILTER
        
        if let name = peripheral.name,
            name.contains("SensiTHING"){
            print("NEW ",peripheral.name)
                        
//            ▿ 0 : 2 elements
//              - key : "kCBAdvDataManufacturerData"
//              - value : <01826dbe 8440>
//            ▿ 1 : 2 elements
//              - key : "kCBAdvDataLocalName"
//              - value : SensiBLE2.0
//            ▿ 2 : 2 elements
//              - key : "kCBAdvDataTxPowerLevel"
//              - value : 0
//            ▿ 3 : 2 elements
//              - key : "kCBAdvDataIsConnectable"
//              - value : 1
            
//        @objc var name:String? {get}
//        @objc var address:String? {get}
//        @objc var featureMap:UInt32 {get}
//        @objc var deviceId:UInt8 {get}
//        @objc var protocolVersion:UInt8 {get}
//        @objc var boardType:BlueSTSDKNodeType {get}
//        @objc var isSleeping:Bool {get}
//        @objc var hasGeneralPurpose:Bool {get}
//        @objc var txPower:UInt8 {get}
            
            let nodeInfo = NodeInfo(name: peripheral.name, address: nil, featureMap: 1841202240, deviceId: UInt8(peripheral.identifier.uuidString) ?? 0, protocolVersion: 1, boardType: BlueSTSDKNodeType.blue_Coin, isSleeping: false, hasGeneralPurpose: false, txPower: 0)
            
            let node = BlueSTSDKNode(peripheral, rssi: RSSI, advertiseInfo:nodeInfo)
            mNodes.append(node)
            tableView.reloadData()
              
            /*
            var advertiseInfo = advertisementData
            advertiseInfo["kCBAdvDataManufacturerData"] = nodeInfo
            advertiseInfo["kCBAdvDataTxPowerLevel"] = 0
            
            print(advertiseInfo)

            let firstMatch = mAdvertiseFilters.lazy.compactMap{ $0.filter(advertiseInfo)}.first
            print(firstMatch)
            if let info = firstMatch{
                let node = BlueSTSDKNode(peripheral, rssi: RSSI, advertiseInfo:info)
                mNodes.append(node)
                tableView.reloadData()
            }
 */
            
//            mPeripheral=peripheral;
//            mPeripheral.delegate=self;
//
//            _tag = peripheral.identifier.UUIDString;
//            [self updateAdvertiseInfo:advertiseInfo];
//
//            [self updateTxPower: [NSNumber numberWithUnsignedChar:_advertiseInfo.txPower]];
//
//            [self updateRssi:rssi];
            
//            let node = BlueSTSDKNode()
//
//            mNodes.append(node)
//            tableView.reloadData()
        }
        
    }
  */
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
    
    func addLogoSplashScreen(){
        let img = UIImage(named: "ms-apps-logo-splash")
        logoSplashScreen.frame = CGRect(x: (UIScreen.main.bounds.size.width - (UIScreen.main.bounds.size.width / 2.5)) / 2, y: view.frame.maxY * 0.8, width: UIScreen.main.bounds.size.width / 2.5, height: UIScreen.main.bounds.size.width / 10)
        logoSplashScreen.image = img
        view.addSubview(logoSplashScreen)
    }
    
    func showSearchingLabel(){
        searchingLabel.text = "Searching for a device..."
        if #available(iOS 12.0, *) {
            if self.traitCollection.userInterfaceStyle == .dark {
                searchingLabel.textColor = UIColor.black
            }
        } else {
            searchingLabel.textColor = UIColor.white
        }
        searchingLabel.font = .systemFont(ofSize: 40)
        searchingLabel.minimumScaleFactor = 0.5
        searchingLabel.adjustsFontSizeToFitWidth = true
        searchingLabel.textAlignment = .center
        
        view.addSubview(searchingLabel)
        searchingLabel.translatesAutoresizingMaskIntoConstraints = false
        searchingLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        searchingLabel.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        searchingLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        searchingLabel.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
    }
    
    func updateUI(){
        
        tableView.removeFromSuperview()
        
        if let view = self.view as! SKView? {
            self.actInd.stopAnimating()
            self.imgSplashScreen.isHidden = true
            self.logoSplashScreen.isHidden = true
            
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
        print(newState.rawValue)
        if newState.rawValue == 3{
            DispatchQueue.main.async { [unowned self] in
                self.updateUI()
            }
            if let features = self.mNodes.first?.getFeatures(){
                for feature in features{
//                    print(feature.name)
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
        DispatchQueue.main.async { [unowned self] in
            if didDiscoverNode.name.contains("Sensi"){
                self.mNodes.append(didDiscoverNode)
                self.tableView.reloadData()
                self.tableView.separatorStyle = .singleLine
                if !self.searchingLabel.isHidden{
                    self.searchingLabel.isHidden = true
                }
            }
        }
        print("NODE!!!! ",didDiscoverNode)
        
        //        didDiscoverNode.addStatusDelegate(self)
        //
        //        didDiscoverNode.connect()
        
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


extension GameViewController: UITableViewDataSource, UITableViewDelegate {
    
    func addTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        
        if #available(iOS 12.0, *) {
            if self.traitCollection.userInterfaceStyle == .dark {
                tableView.backgroundColor = UIColor.black.withAlphaComponent(0)
            }
        } else {
            tableView.backgroundColor = UIColor.black
        }
        
        tableView.separatorStyle = .none
        tableView.separatorColor = UIColor.darkGray
        
        setupTableView()
    }
    
    func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        tableView.register(SubtitleTableViewCell.self, forCellReuseIdentifier: "nodeCell")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mNodes.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "nodeCell", for: indexPath)
        
        let node = mNodes[indexPath.row]
        cell.textLabel?.text = node.name
        cell.detailTextLabel?.text = node.addressEx()
        
        if #available(iOS 12.0, *) {
            if self.traitCollection.userInterfaceStyle == .dark {
                cell.textLabel?.textColor = UIColor.black
                cell.detailTextLabel?.textColor = UIColor.black
                cell.backgroundColor = UIColor.black.withAlphaComponent(0)
            }
        } else {
            cell.textLabel?.textColor = UIColor.white
            cell.detailTextLabel?.textColor = UIColor.white
            cell.backgroundColor = UIColor.black
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let node = mNodes[indexPath.row]
        
        node.addStatusDelegate(self)
        node.connect()
        
        DispatchQueue.main.async { [unowned self] in
            self.addImageSplashScreen()
            self.showActivityIndicatory(uiView: self.view)
            self.addLogoSplashScreen()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
}

class SubtitleTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
