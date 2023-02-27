//
//  FavoriteButton.swift
//  MoviesViewer
//
//  Created by Ilya Kuznetsov on 20/11/2022.
//

import Foundation
import UIKit
import UIComponents
import CommonUtils

class FavoriteButton: UIBarButtonItem {
    
    private let favorites = Movie.favorites
    
    override init() {
        super.init()
        target = self
        action = #selector(favoriteAction)
        favorites.objectWillChange.sink { [weak self] in
            DispatchQueue.main.async {
                self?.reload()
            }
        }.retained(by: self)
    }
    
    @objc private func favoriteAction() {
        guard let movie = movie else { return }
        
        if favorites.has(movie) {
            favorites.remove(movie)
        } else {
            favorites.add(movie)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var movie: Movie? {
        didSet { reload() }
    }
    
    private func reload() {
        guard let movie = movie else { return }
        image = UIImage(systemName: favorites.has(movie) ? "star.fill" : "star")
    }
}
