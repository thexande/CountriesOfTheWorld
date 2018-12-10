//
//  ViewController.swift
//  ApolloUnitTestingDemo
//
//  Created by Alexander Murphy on 12/8/18.
//  Copyright © 2018 Alexander Murphy. All rights reserved.
//

import UIKit
import Apollo

class ViewController: UIViewController {
    
//    var store: WorldStore?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
//       store = WorldStore(client: ApolloClient(url: url))
        
//        store?.fetchAllCountries { (result) in
//            switch result {
//            case let .success(properties):
//                print(properties)
//            case let .failure(error):
//                print(error)
//            }
//        }
    }
}


final class WorldCoordinator {
    var countriesPresenter: CountriesPresenter?
    let nav = UINavigationController()
    
    init() {
        countriesPresenter = CountriesPresenter()
        
        let countriesView = CountriesViewController()
        countriesView.dispatcher = countriesPresenter
        
        nav.viewControllers = [countriesView]
        
    }
}

enum LoadableViewProperties<T> {
    case loading
    case error
    case data(T)
}

protocol CountriesPresenterActionDispatching: AnyObject {
    func dispatch(_ action: CountriesPresenter.Action)
}

final class CountriesPresenter: CountriesPresenterActionDispatching {
   
    enum Action {
        case willAppear
        case selectedCountry(code: String)
    }
    
    let store: WorldStoreInterface
    
    var render: ((LoadableViewProperties<[World.CountryLite]>) -> Void)?
    
    
    init?() {
        let serverAdress = "https://countries.trevorblades.com/"
        
        guard let url = URL(string: serverAdress) else {
            return nil
        }
        
        self.store = WorldStore(client: ApolloClient(url: url))
    }
    
    func dispatch(_ action: CountriesPresenter.Action) {
        switch action {
        case .willAppear:
            refresh()
        case let .selectedCountry(code):
            print(code)
        }
    }
    
    
    func refresh() {
        store.fetchAllCountries { [weak self] result in
            switch result {
            case let .success(countries):
                self?.render?(.data(countries))
            case let .failure(error):
                return
            }
        }
    }
}


final class CountriesViewController: UITableViewController {
    
    weak var dispatcher: CountriesPresenterActionDispatching?
    var countries: [World.CountryLite] = []
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self)) else {
            return UITableViewCell()
        }
        
        let country = countries[indexPath.row]
        cell.textLabel?.text = "\(country.emoji) \(country.name.capitalized)"
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}
