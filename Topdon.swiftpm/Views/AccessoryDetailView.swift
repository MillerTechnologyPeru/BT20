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
    
    let accessory: TopdonAccessory
    
    @EnvironmentObject
    private var store: AccessoryManager
    
    @State
    private var reloadTask: Task<Void, Never>?
    
    @State
    private var error: String?
    
    @State
    private var isReloading = false
    
    @State
    private var information: Result<TopdonAccessoryInfo, Error>?
    
    init(
        accessory: TopdonAccessory
    ) {
        self.accessory = accessory
    }
    
    var body: some View {
        VStack {
            StateView(
                accessory: accessory,
                information: information
            )
        }
        .refreshable {
            reload()
        }
        .onAppear {
            reload()
        }
        .onDisappear {
            reloadTask?.cancel()
        }
    }
}

extension TopdonAccessoryDetailView {
    
    func reload() {
        // accessory metadata
        if let accessoryInfo = store.accessoryInfo {
            self.information = accessoryInfo[accessory.type].flatMap { .success($0) }
        } else {
            // load accessory info
            fetchAccessoryInfo()
        }
        // Bluetooth
        //connect()
    }
    
    func fetchAccessoryInfo() {
        // networking and Bluetooth
        let store = self.store
        isReloading = true
        reloadTask = Task(priority: .userInitiated) {
            defer { isReloading = false }
            do {
                let accessoryInfo = try await store.downloadAccessoryInfo()
                self.information = accessoryInfo[accessory.type]
                    .flatMap { .success($0) } ?? .failure(CocoaError(.coderValueNotFound))
            }
            catch {
                self.information = .failure(error)
            }
        }
    }
    
    func connect() {
        Task {
            do {
                _ = try await store.connect(to: accessory.id)
            }
            catch {
                store.log("Unable to connect to \(accessory.id). \(error)")
            }
        }
    }
    
    func disconnect() {
        Task {
            await store.disconnect(accessory.id)
        }
    }
    
    var peripheral: NativePeripheral? {
        store.peripherals.first(where: { $0.value.id == self.accessory.id })?.key
    }
    
    var isConnected: Bool {
        guard let peripheral else {
            return false
        }
        return store.connections.contains(peripheral)
    }
}

extension TopdonAccessoryDetailView {
    
    struct StateView: View {
        
        let accessory: TopdonAccessory
        
        let information: Result<TopdonAccessoryInfo, Error>?
        
        var body: some View {
            ScrollView {
                VStack(spacing: 16) {
                    // image view
                    VStack {
                        switch information {
                        case .success(let success):
                            CachedAsyncImage(
                                url: URL(string: success.image),
                                content: { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                }, placeholder: {
                                    ProgressView()
                                        .progressViewStyle(.circular)
                                })
                        case .failure(let failure):
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.yellow)
                            Text(verbatim: failure.localizedDescription)
                        case nil:
                            ProgressView()
                                .progressViewStyle(.circular)
                        }
                    }
                    .frame(height: 250)
                    .padding()
                    
                    // MAC Address
                    Text(verbatim: accessory.address.rawValue)
                    
                    // Actions
                    switch accessory.type {
                    case .bt20:
                        NavigationLink(destination: {
                            VoltageView(id: accessory.id)
                        }, label: {
                            Text("Real-time Voltage")
                        })
                    case .tb6000Pro:
                        EmptyView()
                    }
                    
                    // Links
                    if let information = try? information?.get() {
                        if let manual = information.manual.flatMap({ URL(string: $0) }) {
                            Link("User Manual", destination: manual)
                        }
                        if let website = information.website.flatMap({ URL(string: $0) }) {
                            Link("Product Page", destination: website)
                        }
                    }
                }
            }
            .navigationTitle("\(accessory.name)")
        }
    }
}

// MARK: - Preview


