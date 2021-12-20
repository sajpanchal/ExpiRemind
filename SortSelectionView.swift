//
//  SortSelectionView.swift
//  NotifyExpiryDate (iOS)
//
//  Created by saj panchal on 2021-12-19.
//

import SwiftUI

struct SortSelectionView: View {
    @Binding var selectedSortItem: ProductsSort
    let sorts: [ProductsSort]
    var body: some View {
        if #available(iOS 15.0, *) {
            Menu {
                Picker("Sort By", selection: $selectedSortItem) {
                    ForEach(sorts, id: \.self) { sort in
                        Text("\(sort.name)")
                    }
                }
            } label: {
                Label("Sort", systemImage: "line.horizontal.3.decrease.circle")
            }
            .pickerStyle(.inline)
        }
   
    }

}

struct SortSelectionView_Previews: PreviewProvider {
    static var previews: some View {        
        SortSelectionView(selectedSortItem: .constant(ProductsSort.default), sorts: ProductsSort.sorts)
    }
}
