//
//  NodeInfo.swift
//  sensiblecar
//
//  Created by Daniel Radshun on 15/12/2019.
//  Copyright © 2019 Omer Cohen. All rights reserved.
//

import Foundation
import BlueSTSDK

//is pubblic and objc to be used inside the BlueSTSDKNode class
class NodeInfo : NSObject, BleAdvertiseInfo{
    public let name:String?
    public let address:String?
    public let featureMap:UInt32
    public let deviceId:UInt8
    public let protocolVersion:UInt8
    public let boardType:BlueSTSDKNodeType
    public let isSleeping:Bool
    public let hasGeneralPurpose:Bool
    public let txPower:UInt8
    
    init(name: String?, address: String?, featureMap: UInt32, deviceId: UInt8, protocolVersion: UInt8,
               boardType: BlueSTSDKNodeType, isSleeping: Bool, hasGeneralPurpose: Bool, txPower: UInt8){
        self.name = name
        self.address = address
        self.featureMap = featureMap
        self.deviceId = deviceId
        self.protocolVersion = protocolVersion
        self.boardType = boardType
        self.isSleeping = isSleeping
        self.hasGeneralPurpose = hasGeneralPurpose
        self.txPower = txPower
        super.init()
    }
    
}
