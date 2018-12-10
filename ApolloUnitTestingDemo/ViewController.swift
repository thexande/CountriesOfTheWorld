import UIKit

import WorldAPI

final class WorldCoordinator {
    var countriesPresenter: CountriesPresenter?
    let nav = UINavigationController()
    
    init() {
        countriesPresenter = CountriesPresenter()
        
        let countriesView = CountriesViewController()
        countriesView.dispatcher = countriesPresenter
        
        countriesPresenter?.render = { [weak countriesView] data in
            countriesView?.render(data)
        }
        
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
        
        self.store = StoreFactory().makeStore(with: url)
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
    
    func render(_ properties: LoadableViewProperties<[World.CountryLite]>) {
        switch properties {
        case let .data(countries):
            DispatchQueue.main.async {
                self.countries = countries
            }
        case .error:
            return
        case .loading:
            return
        }
    }
    
    private var countries: [World.CountryLite] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard isViewLoaded else {
            return
        }
        
        dispatcher?.dispatch(.willAppear)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "🌎 Countries"
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: String(describing: UITableViewCell.self))
    }
    
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self)) else {
            return UITableViewCell()
        }
        
        let country = countries[indexPath.row]
//        cell.textLabel?.text = "\(country.emoji) \(country.name.capitalized)"
        cell.textLabel?.font = UIFont.systemFont(ofSize: 24, weight: .regular)
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}
