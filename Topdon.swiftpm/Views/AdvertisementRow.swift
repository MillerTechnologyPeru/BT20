//
//  TopdonAdvertisementRow.swift
//  
//
//  Created by Alsey Coleman Miller on 4/12/23.
//

import Foundation
import SwiftUI
import Bluetooth
import Topdon

struct TopdonAdvertisementRow: View {
    
    let advertisement: TopdonAccessory.Advertisement
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(verbatim: advertisement.name)
                .font(.title3)
            Text(verbatim: advertisement.address.rawValue)
                .foregroundColor(.gray)
                .font(.subheadline)
        }
    }
}
/*
#if DEBUG
struct TopdonAdvertisementRow_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            List {
                TopdonAdvertisementRow(type: .bt20, name: "BT20", address: .random)
            }
        }
    }
}
#endif
*/
