//
//  AccessoryManagerBluetooth.swift
//  
//
//  Created by Alsey Coleman Miller  on 3/6/24.
//

import Foundation
import Bluetooth
import GATT
import DarwinGATT
import Topdon
import Telink

public extension AccessoryManager {
    
    /// The Bluetooth LE peripheral for the speciifed device identifier..
    subscript (peripheral address: BluetoothAddress) -> NativeCentral.Peripheral? {
        return peripherals.first(where: { $0.value.address == address })?.key
    }
    
    func scan(duration: TimeInterval? = nil) async throws {
        let bluetoothState = await central.state
        guard bluetoothState == .poweredOn else {
            throw TopdonAppError.bluetoothUnavailable
        }
        let filterDuplicates = true //preferences.filterDuplicates
        self.peripherals.removeAll(keepingCapacity: true)
        stopScanning()
        let services = Set(Topdon.BT20.Advertisement.services)
        let scanStream = central.scan(
            with: services,
            filterDuplicates: filterDuplicates
        )
        self.scanStream = scanStream
        let task = Task { [unowned self] in
            for try await scanData in scanStream {
                guard found(scanData) else { continue }
            }
        }
        if let duration = duration {
            precondition(duration > 0.001)
            try await Task.sleep(timeInterval: duration)
            scanStream.stop()
            try await task.value // throw errors
        } else {
            // error not thrown
            Task { [unowned self] in
                do { try await task.value }
                catch is CancellationError { }
                catch {
                    self.log("Error scanning: \(error)")
                }
            }
        }
    }
    
    func stopScanning() {
        scanStream?.stop()
        scanStream = nil
    }
    
    @discardableResult
    func connect(to accessory: TopdonAccessory.Advertisement.ID) async throws -> GATTConnection<NativeCentral> {
        let central = self.central
        guard let peripheral = self[peripheral: accessory] else {
            throw CentralError.unknownPeripheral
        }
        if let connection = self.connectionsByPeripherals[peripheral] {
            return connection
        }
        // connect
        if await loadConnections.contains(peripheral) == false {
            // initiate connection
            try await central.connect(to: peripheral)
        }
        // cache MTU
        let maximumTransmissionUnit = try await central.maximumTransmissionUnit(for: peripheral)
        // get characteristics by UUID
        let servicesCache = try await central.cacheServices(for: peripheral)
        let connectionCache = GATTConnection(
            central: central,
            peripheral: peripheral,
            maximumTransmissionUnit: maximumTransmissionUnit,
            cache: servicesCache
        )
        // store connection cache
        self.connectionsByPeripherals[peripheral] = connectionCache
        return connectionCache
    }
    
    func disconnect(_ accessory: TopdonAccessory.Advertisement.ID) async {
        guard let peripheral = self[peripheral: accessory] else {
            assertionFailure()
            return
        }
        // stop notifications
        await central.disconnect(peripheral)
    }
    
    /// Read Voltage
    func readVoltage(
        for accessory: TopdonAccessory.Advertisement.ID
    ) async throws -> AsyncIndefiniteStream<Topdon.BatteryVoltageNotification> {
        let connection = try await connect(to: accessory)
        let notifications = try await connection.recieveBT20Events()
        let decoder = TelinkDecoder(isLittleEndian: false)
        try await Task.sleep(timeInterval: 1.0)
        try await connection.sendBT20Command(Data(hexadecimal: "55AA0007FFF8FF02FD")!)
        try await Task.sleep(timeInterval: 1.0)
        try await connection.sendBT20Command(Data(hexadecimal: "55AA0007FFF8FF03FC")!)
        try await Task.sleep(timeInterval: 1.0)
        try await connection.sendBT20Command(Data(hexadecimal: "55AA0009FFF6DD0B0001D7")!)
        try await Task.sleep(timeInterval: 1.0)
        try await connection.sendBT20Command(Data(hexadecimal: "55AA0007FFF8DD09D4")!)
        try await Task.sleep(timeInterval: 1.0)
        try await connection.sendBT20Command(Data(hexadecimal: "55AA000FFFF0DD0765EC356065EC36A8")!)
        try await Task.sleep(timeInterval: 1.0)
        try await connection.sendBT20Command(Data(hexadecimal: "55AA000BFFF4DD0965EC36A6CD")!)
        try await Task.sleep(timeInterval: 1.0)
        try await connection.sendBT20Command(Data(hexadecimal: "55AA000DFFF2DD0265EC36A70001C6")!)
        return AsyncIndefiniteStream<Topdon.BatteryVoltageNotification> { build in
            for try await event in notifications {
                self.log("\(event.opcode) \(event.payload.toHexadecimal())")
                switch event.opcode {
                case .batteryVoltageNotification:
                    let batteryNotification = try decoder.decode(BatteryVoltageNotification.self, from: event.payload)
                    build(batteryNotification)
                default:
                    continue
                }
            }
        }
    }
}

internal extension GATTConnection {
    
    func sendBT20Command(_ command: BT20.Command) async throws {
        guard let characteristic = cache.characteristic(.telinkSerialPortProtocolCommand, service: .telinkSerialPortProtocolService) else {
            throw TopdonAppError.characteristicNotFound(.telinkSerialPortProtocolCommand)
        }
        try await central.sendSerialPortProtocol(command: command, characteristic: characteristic)
    }
    
    func sendBT20Command(_ command: Data) async throws {
        guard let characteristic = cache.characteristic(.telinkSerialPortProtocolCommand, service: .telinkSerialPortProtocolService) else {
            throw TopdonAppError.characteristicNotFound(.telinkSerialPortProtocolCommand)
        }
        try await central.writeValue(command, for: characteristic, withResponse: false)
    }
    
    func recieveBT20Events() async throws -> AsyncIndefiniteStream<Topdon.BT20.Event> {
        guard let characteristic = cache.characteristic(.telinkSerialPortProtocolNotification, service: .telinkSerialPortProtocolService) else {
            throw TopdonAppError.characteristicNotFound(.telinkSerialPortProtocolNotification)
        }
        return try await central.recieveSerialPortProtocol(Topdon.BT20.Event.self, characteristic: characteristic)
    }
}

internal extension AccessoryManager {
    
    func observeBluetoothState() {
        // observe state
        Task { [weak self] in
            while let self = self {
                let newState = await self.central.state
                let oldValue = self.state
                if newState != oldValue {
                    self.state = newState
                }
                try await Task.sleep(timeInterval: 0.5)
            }
        }
        // observe connections
        Task { [weak self] in
            while let self = self {
                let newState = await self.loadConnections
                let oldValue = self.connections
                let disconnected = self.connectionsByPeripherals
                    .filter { newState.contains($0.value.peripheral) }
                    .keys
                if newState != oldValue, disconnected.isEmpty == false {
                    for peripheral in disconnected {
                        self.connectionsByPeripherals[peripheral] = nil
                    }
                }
                try await Task.sleep(timeInterval: 0.2)
            }
        }
    }
    
    var loadConnections: Set<NativePeripheral> {
        get async {
            let peripherals = await self.central
                .peripherals
                .filter { $0.value }
                .map { $0.key }
            return Set(peripherals)
        }
    }
    
    func found(_ scanData: ScanData<NativeCentral.Peripheral, NativeCentral.Advertisement>) -> Bool {
        guard let advertisement = TopdonAccessory.Advertisement(scanData.advertisementData) else {
            return false
        }
        self.peripherals[scanData.peripheral] = advertisement
        return true
    }
}
