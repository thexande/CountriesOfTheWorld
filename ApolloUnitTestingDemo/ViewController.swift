import UIKit

import WorldAPI

final class WorldCoordinator: CountriesPresenterActionDispatching {
    
    func dispatch(_ action: CountriesPresenter.Action) {
        if case .selectedCountry(let code) = action {
            print(code)
            
            let view = CountryDetailViewController()
            countryPresenter = CountryPresenter(code: code)
            view.dispatcher = countryPresenter
            
            countryPresenter?.render = { [weak view] properties in
                view?.render(properties)
            }
            
            DispatchQueue.main.async {
                self.nav.pushViewController(view, animated: true)
            }
        }
    }
    
    var countriesPresenter: CountriesPresenter?
    var countryPresenter: CountryPresenter?
    let nav = UINavigationController()
    
    init() {
        countriesPresenter = CountriesPresenter()
        
        let countriesView = CountriesViewController()
        countriesView.dispatcher = countriesPresenter
        
        countriesPresenter?.render = { [weak countriesView] data in
            countriesView?.render(data)
        }
        
        countriesPresenter?.dispatcher = self
        
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

final class CountriesPresenter: CountriesViewActionDispatching {
   
    enum Action {
        case selectedCountry(code: String)
    }
    
    private let store: WorldStoreInterface
    weak var dispatcher: CountriesPresenterActionDispatching?
    
    var render: ((LoadableViewProperties<[World.CountryLite]>) -> Void)?
    
    
    init?() {
        let serverAdress = "https://countries.trevorblades.com/"
        
        guard let url = URL(string: serverAdress) else {
            return nil
        }
        
        let factory = StoreFactory()
        self.store = factory.makeStore(with: url)
    }
    
    func dispatch(_ action: CountriesViewController.Action) {
        switch action {
        case .willAppear:
            refresh()
        case let .selectedCountry(code):
            dispatcher?.dispatch(.selectedCountry(code: code))
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


protocol CountriesViewActionDispatching: AnyObject {
    func dispatch(_ action: CountriesViewController.Action)
}

final class CountriesViewController: UITableViewController {
    
    enum Action {
        case willAppear
        case selectedCountry(code: String)
    }
    
    weak var dispatcher: CountriesViewActionDispatching?
    
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
        cell.textLabel?.text = "\(country.emoji) \(country.name.capitalized)"
        cell.textLabel?.font = UIFont.systemFont(ofSize: 24, weight: .regular)
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        dispatcher?.dispatch(.selectedCountry(code: countries[indexPath.item].code))
    }
}

protocol CountryPresenterActionDispatching: AnyObject {
    func dispatch(_ action: CountryPresenter.Action)
}

final class CountryPresenter: CountryDetailActionDispatching {
    enum Action {
        case willAppear
        case selectedCountry(code: String)
    }
    
    private let code: String
    private let store: WorldStoreInterface
    var render: ((LoadableViewProperties<CountryDetailViewController.Properties>) -> Void)?
    

    init?(code: String) {
        self.code = code
        
        let serverAdress = "https://countries.trevorblades.com/"
        
        guard let url = URL(string: serverAdress) else {
            return nil
        }
        
        let factory = StoreFactory()
        self.store = factory.makeStore(with: url)
    }
    
    func dispatch(_ action: CountryDetailViewController.Action) {
        switch action {
        case .willAppear:
            refresh()
        }
    }
    
    
    func refresh() {
        
        store.fetchCountry(code: code) { [weak self] result in
            switch result {
            case let .success(country):
                
                let sections = [
                CountryDetailViewController.Properties.Section(title: "name", items: [country.name]),
                CountryDetailViewController.Properties.Section(title: "continent", items: [country.continent.name]),
                CountryDetailViewController.Properties.Section(title: "currency", items: [country.currency]),
                CountryDetailViewController.Properties.Section(title: "name", items: [country.name]),
                ]
                
                self?.render?(.data(CountryDetailViewController.Properties(sections: sections)))
            case let .failure(error):
                return
            }
        }
    }
}
    


protocol CountryDetailActionDispatching: AnyObject {
    func dispatch(_ action: CountryDetailViewController.Action)
}

final class CountryDetailViewController: UITableViewController {
    
    weak var dispatcher: CountryDetailActionDispatching?
    
    enum Action {
        case willAppear
    }
    
    struct Properties {
        struct Section {
            let title: String
            let items: [String]
        }
        
        let sections: [Section]
    }
    
    var sections: [Properties.Section] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func render(_ properties: LoadableViewProperties<Properties>) {
        switch properties {
        case let .data(properties):
            DispatchQueue.main.async {
                self.sections = properties.sections
            }
        case .error:
            return
        case .loading:
            return
        }
    }
    
    init() {
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: String(describing: UITableViewCell.self))
    }
    
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self)) else {
            return UITableViewCell()
        }
        
        let item = sections[indexPath.section].items[indexPath.item]
        cell.textLabel?.text = item
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView,
                            titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
}
