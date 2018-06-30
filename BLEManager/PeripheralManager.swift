//
//  PeripheralManager.swift
//  BLEManager
//
//  Created by Hari Keerthipati on 29/06/18.
//  Copyright © 2018 Avantari Technologies. All rights reserved.
//

import UIKit
import CoreBluetooth

class PeripheralManager: NSObject, CBPeripheralManagerDelegate {

    var peripheralManager: CBPeripheralManager!
    var transferCharacteristic: CBMutableCharacteristic!
    var delegate: PeripheralManagerDelegate!

    override init() {
        super.init()
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    init(with peripheralDelegate: PeripheralManagerDelegate) {
        super.init()
        delegate = peripheralDelegate
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    func startAdvertising()
    {
        print("startAdvertising")
        peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey : [CBUUID(string: serviceUUID)], CBAdvertisementDataLocalNameKey: UIDevice.current.name])
    }
    
    func stopAdvertising()
    {
        peripheralManager.stopAdvertising()
    }
    
    func updateValue(string: String) {
        peripheralManager.updateValue(string.data(using: .utf8)!, for: transferCharacteristic, onSubscribedCentrals: nil)
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state != .poweredOn
        {
            print("not powered on")
            return
        }
        print("created characteristic")
        transferCharacteristic = CBMutableCharacteristic(type: CBUUID(string: characteristicUUID), properties: .notify, value: nil, permissions: .readable)
        let transferService = CBMutableService(type: CBUUID(string: serviceUUID), primary: true)
        transferService.characteristics = [transferCharacteristic]
        peripheralManager.add(transferService)
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        let data = "11".data(using: .utf8)
        let didSend = peripheralManager.updateValue(data!, for: transferCharacteristic, onSubscribedCentrals: nil)
        print("did send\(didSend)")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        print("unsubsribed")
    }
    
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        
        let data = "updated Text".data(using: .utf8)
        let didSend = peripheralManager.updateValue(data!, for: transferCharacteristic, onSubscribedCentrals: nil)
        print("did send\(didSend)")
    }
}

protocol PeripheralManagerDelegate {
    
    func updateValue(string: String)
}
