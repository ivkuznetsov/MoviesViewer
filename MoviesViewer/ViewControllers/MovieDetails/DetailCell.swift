//
//  DetailCell.swift
//  MoviesViewer
//
//  Created by Ilya Kuznetsov on 20/11/2022.
//

import UIKit
import UIComponents

struct Entry: Hashable {
    let title: String
    let detail: String
}

class DetailCell: BaseTableViewCell {
    
    @IBOutlet private var title: UILabel!
    @IBOutlet private var detail: UILabel!
    
    var entry: Entry! {
        didSet {
            title.text = entry.title
            detail.text = entry.detail
        }
    }
}
