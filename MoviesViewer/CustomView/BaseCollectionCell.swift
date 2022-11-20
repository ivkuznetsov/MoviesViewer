//
//  BaseCollectionCell.swift
//  MoviesViewer
//
//  Created by Ilya Kuznetsov on 19/11/2022.
//

import UIKit

class BaseCollectionCell: UICollectionViewCell {
    
    override var isHighlighted: Bool {
        didSet {
            if oldValue != isHighlighted {
                UIView.animate(withDuration: isHighlighted ? 0 : 0.15) {
                    self.alpha = self.isHighlighted ? 0.7 : 1
                    self.transform = self.isHighlighted ? .init(scaleX: 0.95, y: 0.95) : .identity
                }
            }
        }
    }
}
