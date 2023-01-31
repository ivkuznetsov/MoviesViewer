//
//  FavoritesViewController.swift
//  MoviesViewer
//
//  Created by Ilya Kuznetsov on 19/11/2022.
//

import UIKit
import UIComponents
import SharedUIComponents

class FavoritesViewController: BaseController {
    
    private let collection = Collection.make {
        $0.header.text = "No Favorites"
        $0.details.text = "Tap a ⭑ button in the movie details\nto make it favorite"
    }
    private let favorites = Movie.favorites
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        title = "Favorites"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collection.attachTo(view)
        favorites.observe(self) { [weak self] _ in
            self?.reloadView(true)
        }
        reloadView(false)
    }
    
    override func reloadView(_ animated: Bool) {
        collection.set(.with {
            $0.addSection(favorites.objectsOnMain()) { [weak self] in
                self?.navigationController?.pushViewController(MovieDetailsViewController(movie: $0), animated: true)
            }
        }, animated: animated)
    }
}
