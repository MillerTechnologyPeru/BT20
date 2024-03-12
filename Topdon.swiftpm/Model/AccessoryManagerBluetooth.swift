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
    
    func scan(
        duration: TimeInterval? = nil,
        filterServices: Bool = false
    ) async throws {
        let bluetoothState = await central.state
        guard bluetoothState == .poweredOn else {
            throw TopdonAppError.bluetoothUnavailable
        }
        let filterDuplicates = true //preferences.filterDuplicates
        self.peripherals.removeAll(keepingCapacity: true)
        stopScanning()
        let services = filterServices ? Set(BT20.services) : []
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
    func connect(to accessory: TopdonAccessory.ID) async throws -> GATTConnection<NativeCentral> {
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
    
    func disconnect(_ accessory: TopdonAccessory.ID) async {
        guard let peripheral = self[peripheral: accessory] else {
            assertionFailure()
            return
        }
        // stop notifications
        await central.disconnect(peripheral)
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
        guard let advertisement = TopdonAccessory(scanData.advertisementData) else {
            return false
        }
        self.peripherals[scanData.peripheral] = advertisement
        return true
    }
}


// MARK: - BT20

public extension AccessoryManager {
    
    /// Read BT20 Voltage measurements.
    func readBT20Voltage(
        for accessory: TopdonAccessory.ID
    ) async throws -> AsyncIndefiniteStream<Topdon.BT20.BatteryVoltageNotification> {
        let connection = try await connect(to: accessory)
        let notifications = try await connection.recieveBT20Events()
        try await connection.sendBT20Command(BT20.BatteryVoltageCommand())
        return AsyncIndefiniteStream<Topdon.BT20.BatteryVoltageNotification> { build in
            for try await event in notifications {
                self.log("\(event.opcode) \(event.payload.toHexadecimal())")
                switch event.opcode {
                case .bt20BatteryVoltageNotification:
                    let batteryNotification = try event.decode(BT20.BatteryVoltageNotification.self)
                    build(batteryNotification)
                default:
                    continue
                }
            }
        }
    }
}

internal extension GATTConnection {
    
    func sendBT20Command<T>(_ command: T) async throws where T: Equatable, T: Hashable, T: Encodable, T: Sendable, T: TopdonSerialMessage {
        guard let characteristic = cache.characteristic(.telinkSerialPortProtocolCommand, service: .telinkSerialPortProtocolService) else {
            throw TopdonAppError.characteristicNotFound(.telinkSerialPortProtocolCommand)
        }
        try await central.sendSerialPortProtocol(
            command: TopdonCommand(command),
            characteristic: characteristic
        )
    }
    
    func recieveBT20Events() async throws -> AsyncIndefiniteStream<TopdonEvent> {
        guard let characteristic = cache.characteristic(.telinkSerialPortProtocolNotification, service: .telinkSerialPortProtocolService) else {
            throw TopdonAppError.characteristicNotFound(.telinkSerialPortProtocolNotification)
        }
        return try await central.recieveSerialPortProtocol(TopdonEvent.self, characteristic: characteristic)
    }
}

// MARK: - TB6000Pro

public extension AccessoryManager {
    
    /// Read TB6000Pro Voltage measurements.
    func readTB600ProVoltage(
        for accessory: TopdonAccessory.ID
    ) async throws -> AsyncIndefiniteStream<Topdon.TB6000Pro.BatteryVoltageNotification> {
        let connection = try await connect(to: accessory)
        let notifications = try await connection.recieveTB600ProEvents()
        try await connection.sendTB600ProCommand(TB6000Pro.QuickChargeCommand())
        return AsyncIndefiniteStream<TB6000Pro.BatteryVoltageNotification> { build in
            for try await event in notifications {
                self.log("\(event.opcode) \(event.payload.toHexadecimal())")
                switch event.opcode {
                case .tb6000ProBatteryVoltageNotification:
                    let batteryNotification = try event.decode(TB6000Pro.BatteryVoltageNotification.self)
                    build(batteryNotification)
                default:
                    continue
                }
            }
        }
    }
}

internal extension GATTConnection {
    
    func sendTB600ProCommand<T>(_ command: T) async throws where T: Equatable, T: Hashable, T: Encodable, T: Sendable, T: TopdonSerialMessage {
        
        guard let characteristic = cache.characteristic(.tb6000ProCharacteristic2, service: .tb6000ProService) else {
            throw TopdonAppError.characteristicNotFound(.tb6000ProCharacteristic2)
        }
        let message = try SerialPortProtocolMessage(command: TopdonCommand(command))
        let data = try message.encode()
        try await central.writeValue(data, for: characteristic, withResponse: false)
    }
    
    func recieveTB600ProEvents() async throws -> AsyncIndefiniteStream<TopdonEvent> {
        guard let characteristic = cache.characteristic(.tb6000ProCharacteristic2, service: .tb6000ProService) else {
            throw TopdonAppError.characteristicNotFound(.tb6000ProCharacteristic2)
        }
        let notifications = try await central.notify(for: characteristic)
        return AsyncIndefiniteStream<TopdonEvent> { build in
            for try await data in notifications {
                let message = try SerialPortProtocolMessage(from: data)
                let event = try TopdonEvent.init(from: message)
                build(event)
            }
        }
    }
}
