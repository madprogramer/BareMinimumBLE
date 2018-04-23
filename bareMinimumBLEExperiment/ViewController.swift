//
//  ViewController.swift
//  bareMinimumBLEExperiment
//
//  Created by Ahmet Akkoc on 4/1/18.
//  Copyright © 2018 Some Organization. All rights reserved.
//

import CoreBluetooth
import UIKit



class ViewController: UIViewController {
    
    var centralManager: CBCentralManager?
    var peripheralManager = CBPeripheralManager()
    
    var friends:Set<CBPeripheral> = Set<CBPeripheral>()
    
    var lastMessage :String = String()
    var timer : Timer!
    
    var count: Int = 0
    var checking: Bool = false
    
    final let debuguuid = CBUUID(string:"52522072-5c7f-4a1f-89b0-10b6b09032b5")

    
    @IBOutlet weak var CentralLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        activateTimer()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func timerTick(sender: Timer!){
        if(friends.isEmpty){
            CentralLabel.text = "No One Nearby"
        }
        else if(friends.count == 1){
            CentralLabel.text = "There's 1 user nearby"
        }
        else{
            CentralLabel.text = String("There are " + String(friends.count) + " users nearby")
        }
        
        friends.removeAll()
        self.centralManager?.stopScan()
        self.centralManager?.scanForPeripherals(withServices: [debuguuid], options: nil)
    }
    
    func updateAdvertisement() {
        if (peripheralManager.isAdvertising) {
            peripheralManager.stopAdvertising()
        }
        
        let advertisementData = "DATA"
        
        peripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey:[debuguuid], CBAdvertisementDataLocalNameKey: advertisementData])
    }
    
    func activateTimer(){
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(timerTick), userInfo: nil, repeats: true)
    }
    
}

extension ViewController : CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if (central.state == .poweredOn) {
            self.centralManager?.scanForPeripherals(withServices: [debuguuid], options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if(!friends.contains(peripheral)){
            friends.insert(peripheral)
        }
    }
}

extension ViewController : CBPeripheralManagerDelegate {
    
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
        if (peripheral.state == .poweredOn){
            
            updateAdvertisement()
        }
    }
}

