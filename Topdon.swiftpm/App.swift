import Foundation
import SwiftUI
import CoreBluetooth
import Bluetooth
import GATT
import Topdon

@main
struct TopdonApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(Store.shared)
        }
    }
}
