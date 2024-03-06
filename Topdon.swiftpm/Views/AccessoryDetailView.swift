//
//  TopdonDetailView.swift
//  
//
//  Created by Alsey Coleman Miller on 4/12/23.
//

import Foundation
import SwiftUI
import Bluetooth
import GATT
import Topdon

struct TopdonAccessoryDetailView: View {
    
    let peripheral: NativePeripheral
    
    let advertisement: TopdonAccessory.Advertisement
        
    @EnvironmentObject
    private var store: Store
    
    @State
    private var reloadTask: Task<Void, Never>?
    
    @State
    private var error: String?
    
    @State
    private var isReloading = false
    
    init(
        peripheral: NativePeripheral,
        advertisement: TopdonAccessory.Advertisement
    ) {
        self.peripheral = peripheral
        self.advertisement = advertisement
    }
    
    var body: some View {
        Text("\(advertisement.name)")
        .refreshable {
            //reload()
        }
        .onAppear {
            //reload()
        }
        .onDisappear {
            reloadTask?.cancel()
        }
        .navigationTitle("\(advertisement.name)")
    }
}
/*
extension TopdonDetailView {
    
    func reload() {
        let oldTask = reloadTask
        reloadTask = Task {
            self.error = nil
            self.isReloading = true
            defer { self.isReloading = false }
            await oldTask?.value
            do {
                guard let beacons = store.peripherals[peripheral], beacons.isEmpty == false else {
                    throw CentralError.unknownPeripheral
                }
                self.address = beacons.compactMapValues { $0.address }.values.first
                self.capability = beacons.compactMap { $0.value.capability }.first ?? []
                self.ioCapability = beacons.compactMap { $0.value.ioCapability }.first ?? []
                // read characteristics
                try await store.central.connection(for: peripheral) { connection in
                    try await readCharacteristics(connection: connection)
                }
            }
            catch {
                self.error = error.localizedDescription
            }
        }
    }
    
    func readCharacteristics(connection: GATTConnection<NativeCentral>) async throws {
        var batteryService = ServiceSection(
            id: .batteryService,
            name: "Battery Service",
            characteristics: []
        )
        
        // read battery level
        if let characteristic = connection.cache.characteristic(.batteryLevel, service: .batteryService) {
            let data = try await connection.central.readValue(for: characteristic)
            guard data.count == 1 else {
                throw TopdonAppError.invalidCharacteristicValue(.batteryLevel)
            }
            let value = data[0]
            batteryService.characteristics.append(
                CharacteristicItem(
                    id: characteristic.uuid.rawValue,
                    name: "Battery Level",
                    value: "\(value)%"
                )
            )
        }
        
        // read temperature and humidity
        var thermometerService = ServiceSection(
            id: TemperatureHumidityCharacteristic.service,
            name: "Mi Thermometer Service",
            characteristics: []
        )
        if let characteristic = connection.cache.characteristic(TemperatureHumidityCharacteristic.uuid, service: TemperatureHumidityCharacteristic.service) {
            let data = try await connection.central.readValue(for: characteristic)
            guard let value = TemperatureHumidityCharacteristic(data: data) else {
                throw TopdonAppError.invalidCharacteristicValue(TemperatureHumidityCharacteristic.uuid)
            }
            thermometerService.characteristics += [
                CharacteristicItem(
                    id: characteristic.uuid.rawValue + "-" + "Temperature",
                    name: "Temperature",
                    value: value.temperature.description
                ),
                CharacteristicItem(
                    id: characteristic.uuid.rawValue + "-" + "Humidity",
                    name: "Humidity",
                    value: value.humidity.description
                ),
                CharacteristicItem(
                    id: characteristic.uuid.rawValue + "-" + "BatteryVoltage",
                    name: "Battery Voltage",
                    value: value.batteryVoltage.description
                )
            ]
        }
        
        // read device information
        var deviceInformationService = ServiceSection(
            id: .deviceInformation,
            name: "Device Information",
            characteristics: []
        )
        if let characteristic = connection.cache.characteristic(.manufacturerNameString, service: .deviceInformation) {
            let data = try await connection.central.readValue(for: characteristic)
            guard let value = String(data: data, encoding: .utf8) else {
                throw TopdonAppError.invalidCharacteristicValue(.manufacturerNameString)
            }
            deviceInformationService.characteristics.append(
                CharacteristicItem(
                    id: BluetoothUUID.manufacturerNameString.rawValue,
                    name: "Manufacturer Name",
                    value: value
                )
            )
        }
        if let characteristic = connection.cache.characteristic(.modelNumberString, service: .deviceInformation) {
            let data = try await connection.central.readValue(for: characteristic)
            guard let value = String(data: data, encoding: .utf8) else {
                throw TopdonAppError.invalidCharacteristicValue(.modelNumberString)
            }
            deviceInformationService.characteristics.append(
                CharacteristicItem(
                    id: BluetoothUUID.modelNumberString.rawValue,
                    name: "Model",
                    value: value
                )
            )
        }
        if let characteristic = connection.cache.characteristic(.serialNumberString, service: .deviceInformation) {
            let data = try await connection.central.readValue(for: characteristic)
            guard let value = String(data: data, encoding: .utf8) else {
                throw TopdonAppError.invalidCharacteristicValue(.serialNumberString)
            }
            deviceInformationService.characteristics.append(
                CharacteristicItem(
                    id: BluetoothUUID.serialNumberString.rawValue,
                    name: "Serial Number",
                    value: value
                )
            )
        }
        if let characteristic = connection.cache.characteristic(.firmwareRevisionString, service: .deviceInformation) {
            let data = try await connection.central.readValue(for: characteristic)
            guard let value = String(data: data, encoding: .utf8) else {
                throw TopdonAppError.invalidCharacteristicValue(.firmwareRevisionString)
            }
            deviceInformationService.characteristics.append(
                CharacteristicItem(
                    id: BluetoothUUID.firmwareRevisionString.rawValue,
                    name: "Firmware Revision",
                    value: value
                )
            )
        }
        if let characteristic = connection.cache.characteristic(.hardwareRevisionString, service: .deviceInformation) {
            let data = try await connection.central.readValue(for: characteristic)
            guard let value = String(data: data, encoding: .utf8) else {
                throw TopdonAppError.invalidCharacteristicValue(.hardwareRevisionString)
            }
            deviceInformationService.characteristics.append(
                CharacteristicItem(
                    id: BluetoothUUID.hardwareRevisionString.rawValue,
                    name: "Hardware Revision",
                    value: value
                )
            )
        }
        if let characteristic = connection.cache.characteristic(.softwareRevisionString, service: .deviceInformation) {
            let data = try await connection.central.readValue(for: characteristic)
            guard let value = String(data: data, encoding: .utf8) else {
                throw TopdonAppError.invalidCharacteristicValue(.softwareRevisionString)
            }
            deviceInformationService.characteristics.append(
                CharacteristicItem(
                    id: BluetoothUUID.softwareRevisionString.rawValue,
                    name: "Software Revision",
                    value: value
                )
            )
        }
        
        // set services
        self.services = [
            thermometerService,
            batteryService,
            deviceInformationService
        ]
        .filter { $0.characteristics.isEmpty == false }
    }
}

extension TopdonDetailView {
    
    struct StateView: View {
        
        let product: ProductID
        
        let address: BluetoothAddress?
        
        let version: UInt8
        
        let capability: Topdon.Capability
        
        let ioCapability: Topdon.Capability.IO
        
        let services: [ServiceSection]
        
        var body: some View {
            List {
                Section("Advertisement") {
                    if let address = self.address {
                        SubtitleRow(
                            title: Text("Address"),
                            subtitle: Text(verbatim: address.rawValue)
                        )
                    }
                    SubtitleRow(
                        title: Text("Version"),
                        subtitle: Text(verbatim: version.description)
                    )
                    #if DEBUG
                    if capability.isEmpty == false {
                        SubtitleRow(
                            title: Text("Capability"),
                            subtitle: Text(verbatim: capability.description)
                        )
                    }
                    if ioCapability.isEmpty == false {
                        SubtitleRow(
                            title: Text("IO Capability"),
                            subtitle: Text(verbatim: ioCapability.description)
                        )
                    }
                    #endif
                }
                ForEach(services) { service in
                    Section(service.name) {
                        ForEach(service.characteristics) { characteristic in
                            SubtitleRow(
                                title: Text(characteristic.name),
                                subtitle: Text(verbatim: characteristic.value)
                            )
                        }
                    }
                }
            }
            .navigationTitle("\(product.description)")
        }
    }
}

extension TopdonDetailView {
    
    struct ServiceSection: Equatable, Identifiable {
        
        let id: BluetoothUUID
        
        let name: LocalizedStringKey
        
        var characteristics: [CharacteristicItem]
    }
    
    struct CharacteristicItem: Equatable, Identifiable {
        
        let id: String
        
        let name: LocalizedStringKey
        
        let value: String
    }
}
*/
