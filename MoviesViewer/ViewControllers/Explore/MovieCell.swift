//
//  MovieCell.swift
//  MoviesViewer
//
//  Created by Ilya Kuznetsov on 19/11/2022.
//

import UIKit
import SDWebImage

class PosterContainerView: UIView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.shadowRadius = 3
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowOpacity = 0.15
        layer.borderColor = UIColor(white: 0, alpha: 0.05).cgColor
        layer.borderWidth = 1 / UIScreen.main.scale
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = UIBezierPath(rect: layer.bounds).cgPath
    }
}

class MovieCell: BaseCollectionCell {
    
    @IBOutlet private var title: UILabel!
    @IBOutlet private var poster: UIImageView!
    
    var movie: Movie! {
        didSet {
            if oldValue == movie { return }
            
            title.text = movie.title
            poster.image = nil
            
            let movie = self.movie
            Task { @MainActor [weak self] in
                let url = try await movie?.fullPosterURL()
                if self?.movie == movie {
                    self?.poster.sd_setImage(with: url)
                }
            }
        }
    }
    
    static func size(contentWidth: CGFloat, space: CGFloat) -> CGSize {
        let width = contentWidth
        
        let count = floor(width / 150)
        if count == 0 { return CGSize(width: width, height: height(for: width)) }
        
        let side = (width - (space * (count - 1))) / count
        return CGSize(width: side, height: height(for: side))
    }
    
    static func height(for width: CGFloat) -> CGFloat {
        var height = (width - 16) / 3 * 4
        height += 53
        return height
    }
}
