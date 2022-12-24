//
//  FavoritesViewController.swift
//  MoviesViewer
//
//  Created by Ilya Kuznetsov on 19/11/2022.
//

import UIKit
import UIComponents

class FavoritesViewController: BaseController, CollectionDelegate {
    
    private var collection: Collection!
    private let favorites = Movie.favorites
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        title = "Favorites"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collection = Collection(view: view, delegate: self)
        collection.collection.set(cellsPadding: 15)
        collection.noObjectsView.title.text = "No Favorites"
        collection.noObjectsView.details.text = "Push ⭑ button in movie details\nto make it favorite"
        
        favorites.observe(self) { [weak self] _ in
            self?.reloadView(true)
        }
        reloadView(false)
    }
    
    override func reloadView(_ animated: Bool) {
        collection.set(objects: favorites.objectsOnMain(), animated: animated)
    }
    
    func createCell(object: AnyHashable, collection: Collection) -> UICollectionView.Cell? {
        if let object = object as? Movie {
            return .init(MovieCell.self, { $0.movie = object })
        }
        return nil
    }
    
    func cellSizeFor(object: AnyHashable, collection: Collection) -> CGSize? {
        MovieCell.size(contentWidth: collection.collection.width, space: 15)
    }
    
    func action(object: AnyHashable, collection: Collection) -> Collection.Result? {
        if let object = object as? Movie {
            navigationController?.pushViewController(MovieDetailsViewController(movie: object), animated: true)
        }
        return .deselect
    }
}
