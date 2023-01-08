//
//  ExploreViewController.swift
//  MoviesViewer
//
//  Created by Ilya Kuznetsov on 19/11/2022.
//

import UIKit
import SharedUIComponents
import UIComponents

func runTest(_ progress: (Double)->()) async {
    progress(0.1)
    sleep(1)
    progress(0.2)
    sleep(1)
    progress(0.3)
    sleep(1)
    progress(0.4)
    sleep(1)
    progress(1)
}

class ExploreViewController: BaseController {
    
    private let collection = PagingCollection()
    private let searchVC = SearchViewController()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        title = "Movies Viewer"
        navigationItem.backButtonTitle = "Back"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Check Progress", style: .plain, target: self, action: #selector(progressTest))
    }
    
    @objc private func progressTest() {
        loadingPresenter.helper.run(.translucent) { progress in
            await runTest(progress)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collection.list.attachTo(view)
        collection.list.view.set(cellsPadding: 15)
        collection.list.view.keyboardDismissMode = .onDrag
        
        collection.list.addCell(for: Movie.self,
                                type: MovieCell.self,
                                fill: { $1.movie = $0 },
                                size: { [unowned self] _ in
            MovieCell.size(contentWidth: collection.list.view.defaultWidth, space: 15)
        }, action: { [unowned self] in
            navigationController?.pushViewController(MovieDetailsViewController(movie: $0), animated: true)
        })
        
        collection.paging.firstPageCache = (save: {
            let items = ($0 as? [Movie])?.compactMap { $0.objectID.uriRepresentation().absoluteString }
            UserDefaults.standard.set(items, forKey: "firstPage")
        }, load: {
            let ids = UserDefaults.standard.array(forKey: "firstPage") ?? []
            return ids.compactMap { Movie.object(uri: URL(string: $0 as! String)!) }
        })
        
        collection.paging.set(loadPage: {
            try await Movie.mostPopular(offset: $0).content
        }, with: loadingPresenter.helper)
        
        navigationItem.searchController = searchVC.searchController
        collection.paging.refresh()
    }
}
