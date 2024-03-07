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
    ) async throws -> AsyncThrowingStream<Topdon.BatteryVoltageNotification, Error> {
        guard let peripheral = self[peripheral: accessory] else {
            throw CentralError.unknownPeripheral
        }
        let connection = try await connect(to: accessory)
        let notifications = try await notifications(for: connection)
        try await writeCommand(BT20.Command.loggingIntervalDay.data, for: connection)
        var iterator = notifications.makeAsyncIterator()
        return AsyncStream(unfolding: {
            iterator
                .next()
                .flatMap { BatteryVoltageNotification(data: $0) }
        }, onCancel: {
            notifications.stop()
        })
    }
}

internal extension AccessoryManager {
    
    func writeCommand(_ data: Data, for connection: GATTConnection<NativeCentral>) async throws {
        try await connection.writeTopdonCommand(data)
    }
    
    func notifications(for connection: GATTConnection<NativeCentral>) async throws -> AsyncCentralNotifications<NativeCentral> {
        guard let characteristic = connection.cache.characteristic(.topdonService, service: .topdonNotificationCharacteristic) else {
            throw TopdonAppError.characteristicNotFound(.topdonNotificationCharacteristic)
        }
        return try await connection.central.notify(for: characteristic)
    }
}

internal extension GATTConnection {
    
    func writeTopdonCommand(_ data: Data) async throws {
        guard let characteristic = cache.characteristic(.topdonService, service: .topdonCommandCharacteristic) else {
            throw TopdonAppError.characteristicNotFound(.topdonCommandCharacteristic)
        }
        try await central.writeValue(data, for: characteristic, withResponse: false)
    }
    
    func topdonNotifications() async throws -> AsyncCentralNotifications<Central> {
        guard let characteristic = cache.characteristic(.topdonService, service: .topdonNotificationCharacteristic) else {
            throw TopdonAppError.characteristicNotFound(.topdonNotificationCharacteristic)
        }
        return try await central.notify(for: characteristic)
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
