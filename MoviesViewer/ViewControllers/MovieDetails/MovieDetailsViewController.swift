//
//  MovieDetailsViewController.swift
//  MoviesViewer
//
//  Created by Ilya Kuznetsov on 20/11/2022.
//

import Foundation
import UIComponents
import Database
import UIKit

class MovieDetailsViewController: BaseController, TableDelegate {
    
    private var table: Table!
    @DBObservable private var movie: Movie?
    private let header = MovieHeaderView.loadFromNib()
    
    init(movie: Movie) {
        self.movie = movie
        super.init()
        let button = FavoriteButton()
        button.movie = movie
        navigationItem.rightBarButtonItem = button
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table = Table(view: view, delegate: self)
        table.table.tableHeaderView = UIView()
        table.table.separatorInset = .zero
        header.movie = movie
        
        _movie.didChange = { [weak self] replaced in
            self?.reloadView(false)
        }
        reloadView(false)
        
        operationHelper.run({ [weak self] completion, _ in
            self?.movie?.updateDetails().runWith(completion)
        }, loading: movie?.isLoaded == true ? .none : .opaque)
    }
    
    @objc private func favoriteAction() {
        
    }
    
    override func reloadView(_ animated: Bool) {
        guard let movie = movie else {
            navigationController?.popViewController(animated: true)
            return
        }

        var objects: [AnyHashable] = [header]
        
        let addEntry: (String, String?)->() = {
            if let detail = $1, detail.isValid {
                objects.append(Entry(title: $0, detail: detail))
            }
        }
        addEntry("Genres", movie.genres?.joined(separator: ", "))
        addEntry("Companies", movie.companies?.joined(separator: "\n"))
        addEntry("Countries", movie.countries?.joined(separator: "\n"))
        addEntry("Overview", movie.overview )
        
        table.set(objects: objects, animated: animated)
    }
    
    func createCell(object: AnyHashable, table: Table) -> Table.Cell? {
        if let object = object as? Entry {
            return .init(DetailCell.self, { $0.entry = object })
        }
        return nil
    }
}
