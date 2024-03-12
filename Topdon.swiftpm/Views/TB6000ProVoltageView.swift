//
//  TB6000ProVoltageView.swift
//  
//
//  Created by Alsey Coleman Miller on 3/11/24.
//

import Foundation
import SwiftUI
import Bluetooth
import GATT
import Topdon

struct TB6000ProVoltageView: View {
    
    let id: TopdonAccessory.ID
    
    @EnvironmentObject
    private var store: AccessoryManager
    
    @State
    var values = [TB6000Pro.BatteryVoltageNotification]()
    
    var body: some View {
        VStack(alignment: .leading) {
            List {
                ForEach(values) { notification in
                    VStack {
                        HStack {
                            Text(notification.date, style: .date)
                            Text(notification.date, style: .time)
                            
                        }
                        Text(verbatim: notification.voltage.description)
                        Text(verbatim: notification.amperage.description)
                        Text(verbatim: notification.watts.description)
                    }
                }
            }
        }
        .navigationTitle("Voltage")
        .task {
            do {
                let stream = try await store.readTB600ProVoltage(for: id)
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
