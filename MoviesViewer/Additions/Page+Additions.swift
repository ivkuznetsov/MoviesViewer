//
//  Page+Additions.swift
//  MoviesViewer
//
//  Created by Ilya Kuznetsov on 07/01/2023.
//

import Foundation
import SharedUIComponents

extension Page {
    
    var content: Paging.Content { .init(items as! [AnyHashable], next: next) }
}
