//
//  MovieHeaderView.swift
//  MoviesViewer
//
//  Created by Ilya Kuznetsov on 20/11/2022.
//

import UIKit
import SDWebImage

class MovieHeaderView: UIView {
    
    @IBOutlet private var poster: UIImageView!
    @IBOutlet private var background: UIImageView!
    @IBOutlet private var title: UILabel!
    
    var movie: Movie! {
        didSet {
            title.text = movie.title
            
            Task { @MainActor [weak self] in
                let url = try await movie.fullPosterURL()
                self?.poster.sd_setImage(with: url)
                self?.background.sd_setImage(with: url)
            }
        }
    }
}
