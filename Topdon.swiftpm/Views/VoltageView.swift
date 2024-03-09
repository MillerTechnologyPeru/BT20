//
//  VoltageView.swift
//
//
//  Created by Alsey Coleman Miller on 3/7/24.
//

import Foundation
import SwiftUI
import Bluetooth
import GATT
import Topdon

struct VoltageView: View {
    
    let id: TopdonAccessory.Advertisement.ID
    
    @EnvironmentObject
    private var store: AccessoryManager
    
    @State
    var entries = [(Date, Float)]()
    
    var body: some View {
        VStack(alignment: .leading) {
            List {
                ForEach(entries, id: \.0) { (date, voltage) in
                    HStack {
                        Text(date, style: .time)
                        Text("\(voltage)v")
                    }
                }
            }
        }
        .navigationTitle("Voltage")
        .task {
            do {
                let stream = try await store.readVoltage(for: id)
                Task {
                    do {
                        for try await value in stream {
                            entries.append((Date(), Float(value.voltage) / 1000))
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
