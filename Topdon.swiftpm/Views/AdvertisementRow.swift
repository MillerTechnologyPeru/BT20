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
    
    @EnvironmentObject
    private var store: AccessoryManager
    
    let advertisement: TopdonAccessory
    
    var body: some View {
        StateView(
            advertisement: advertisement,
            information: store.accessoryInfo?[advertisement.type]
        )
    }
}

internal extension TopdonAdvertisementRow {
    
    struct StateView: View {
        
        let advertisement: TopdonAccessory
        
        let information: TopdonAccessoryInfo?
        
        var body: some View {
            HStack {
                // icon
                VStack {
                    if let information {
                        CachedAsyncImage(
                            url: URL(string: information.image),
                            content: { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            }, placeholder: {
                                Image(systemName: information.symbol)
                            })
                    } else {
                        Image(systemName: "minus.plus.batteryblock")
                    }
                }
                .frame(width: 40)
                
                // Text
                VStack(alignment: .leading) {
                    Text(verbatim: advertisement.name)
                        .font(.title3)
                    Text(verbatim: advertisement.address.rawValue)
                        .foregroundColor(.gray)
                        .font(.subheadline)
                }
            }
            
        }
    }
}

// MARK: - Preview

#if DEBUG
struct TopdonAdvertisementRow_Previews: PreviewProvider {
    
    static var previews: some View {
        NavigationView {
            List {
                TopdonAdvertisementRow(
                    advertisement: .bt20(BT20(MockAdvertisementData.bt20)!)
                )
                TopdonAdvertisementRow(
                    advertisement: .tb6000Pro(TB6000Pro(MockAdvertisementData.tb6000Pro)!)
                )
            }
        }
    }
}
#endif
