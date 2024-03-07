import SwiftUI
import Topdon

struct ContentView: View {
    
    @EnvironmentObject
    var store: AccessoryManager
    
    var body: some View {
        NavigationView {
            NearbyDevicesView()
        }
    }
}
