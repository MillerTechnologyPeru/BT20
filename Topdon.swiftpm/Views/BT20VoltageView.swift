//
//  BT20VoltageView.swift
//
//
//  Created by Alsey Coleman Miller on 3/7/24.
//

import Foundation
import SwiftUI
import Bluetooth
import GATT
import Topdon

struct BT20VoltageView: View {
    
    let id: TopdonAccessory.ID
    
    @EnvironmentObject
    private var store: AccessoryManager
    
    @State
    var values = [BT20.BatteryVoltageNotification]()
    
    var body: some View {
        VStack(alignment: .leading) {
            List {
                ForEach(values) { notification in
                    HStack {
                        Text(notification.date, style: .date)
                        Text(notification.date, style: .time)
                        Text("\(notification.voltage.voltage)v")
                    }
                }
            }
        }
        .navigationTitle("Voltage")
        .task {
            do {
                let stream = try await store.readBT20Voltage(for: id)
                Task {
                    do {
                        for try await value in stream {
                            values.insert(value, at: 0)
                        }
                    }
                    catch {
                        store.log("Unable to read voltage. \(error)")
                    }
                }
            }
            catch {
                store.log("Unable to read voltage. \(error)")
            }
        }
    }
}
