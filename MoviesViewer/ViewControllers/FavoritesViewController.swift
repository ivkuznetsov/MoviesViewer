//
//  FavoritesViewController.swift
//  MoviesViewer
//
//  Created by Ilya Kuznetsov on 19/11/2022.
//

import UIKit
import UIComponents
import CommonUtils

class FavoritesViewController: BaseController {
    
    private let collection = Collection()
    private let favorites = Movie.favorites
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        title = "Favorites"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collection.attachTo(view)
        collection.list.set(cellsPadding: 15)
        (collection.emptyStateView as! NoObjectsView).header.text = "No Favorites"
        (collection.emptyStateView as! NoObjectsView).details.text = "Push ⭑ button in movie details\nto make it favorite"
        
        collection.set(cellsInfo: [.init(Movie.self,
                                         MovieCell.self,
                                         { $1.movie = $0 },
                                         size: { [unowned self] _ in
            MovieCell.size(contentWidth: collection.list.defaultWidth, space: 15)
        }, action: { [unowned self] in
            navigationController?.pushViewController(MovieDetailsViewController(movie: $0), animated: true)
            return .deselect
        })])
        
        favorites.observe(self) { [weak self] _ in
            self?.reloadView(true)
        }
        reloadView(false)
    }
    
    override func reloadView(_ animated: Bool) {
        collection.set(favorites.objectsOnMain(), animated: animated)
    }
}
