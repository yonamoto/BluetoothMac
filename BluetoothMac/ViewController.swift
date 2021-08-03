//
//  ViewController.swift
//  BluetoothMac
//
//  Created by 要名本義朋 on 2021/07/16.
//

import Cocoa
import CoreBluetooth

class ViewController: NSViewController, CBPeripheralDelegate{
    
    //bluetooth service and Peripheral UUID
    let myCustomServiceUUID: [CBUUID] = [CBUUID(string: "17889116-37EF-4504-AA71-71C738D17407")]
    let myCharacteristicUUID: [CBUUID] = [CBUUID(string: "5211EF6C-F5CF-4896-A0D0-D656E32EEE1B")]
    
    public var cbCentralManager: CBCentralManager!
    public var peripheral: CBPeripheral!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        cbCentralManager = CBCentralManager(delegate: self, queue: nil)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

//参照 : https://qiita.com/tkinjo1/items/c4e1c537546277ca78b6
//参照 : https://medium.com/macoclock/core-bluetooth-ble-swift-d2e7b84ea98e
//参照 : https://cpoint-lab.co.jp/article/201910/12214/

extension ViewController :  CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            central.scanForPeripherals(withServices: nil, options: nil)
            print("Scanning...")
//        switch central.state {
//                case .unknown:
//                    print("unknown")
//                case .resetting:
//                    print("resetting")
//                case .unsupported:
//                    print("unsupported")
//                case .unauthorized:
//                    print("unauthorized")
//                case .poweredOff:
//                    print("powered off")
//                case .poweredOn:
//                    print("powered on")
//                    self.centralManager.scanForPeripherals(withServices: nil, options: nil)
//        }
        }
    }
    
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
      guard peripheral.name != nil else {return}
    
      if peripheral.name! == "要名本義朋のiPhone" {
      
        print("Sensor Found!")
        //stopScan
        cbCentralManager.stopScan()
        
        //connect
        cbCentralManager.connect(peripheral, options: nil)
        self.peripheral = peripheral
       }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
      //discover all service
        print("接続成功")
        
        peripheral.discoverServices(myCustomServiceUUID)
        peripheral.delegate = self
    }
    
}

//MARK:- CBPeripheralDelegate

extension ViewController{
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
      
            //discover characteristics of services
            for service in services {
                peripheral.discoverCharacteristics(myCharacteristicUUID, for: service)
                print("check func")
            }
        }
    }
    
    // Characteristics を発見したら呼ばれる
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("Find Characteristics")
        
        let str = "Hello, peripheral!"
        let data = str.data(using: .utf8)!
        //ペリフェラルの保持しているキャラクタリスティクスから特定のものを探す
        for i in service.characteristics!{
            if i.uuid.uuidString == "5211EF6C-F5CF-4896-A0D0-D656E32EEE1B"{
                //Notification を受け取るというハンドラ
                peripheral.setNotifyValue(true, for: i)
                //書き込み
                peripheral.writeValue(data , for: i, type: .withResponse)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
            guard error == nil else {
                print("キャラクタリスティック値取得・変更時エラー：\(String(describing: error))")
                // 失敗処理
                return
            }
            guard let data = characteristic.value else {
                // 失敗処理
                return
            }
            // データが渡ってくる
            print(data)
        
            // デコード/パース処理を行う
            let message = String(decoding: data, as: UTF8.self)
    }
    
//    // Notificationを受け取ったら呼ばれる
//    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
//        // valueの中にData型で値が入っている
//        print(characteristic.value)
//    }
    
}
