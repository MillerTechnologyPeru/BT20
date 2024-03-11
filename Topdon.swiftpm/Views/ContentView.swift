import SwiftUI
import Topdon

struct ContentView: View {
    
    @EnvironmentObject
    var store: AccessoryManager
    
    var body: some View {
        NavigationView {
            NearbyDevicesView()
        }
        .task {
            do {
                try await store.downloadAccessoryInfo()
            }
            catch {
                store.log("Unable to download accessory info. \(error)")
            }
        }
    }
}
