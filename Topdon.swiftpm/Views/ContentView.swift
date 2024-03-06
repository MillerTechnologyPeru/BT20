import SwiftUI
import Topdon

struct ContentView: View {
    
    @EnvironmentObject
    var store: Store
    
    var body: some View {
        NavigationView {
            NearbyDevicesView()
        }
    }
}
