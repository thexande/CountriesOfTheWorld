import UIKit
import WorldAPI

protocol CountriesViewActionDispatching: AnyObject {
    func dispatch(_ action: CountriesViewController.Action)
}

final class CountriesViewController: UITableViewController {
    
    enum Action {
        case willAppear
        case selectedCountry(code: String, title: String)
        case refresh
    }
    
    weak var dispatcher: CountriesViewActionDispatching?
    private let loading = TableLoadingView()
    
    func render(_ properties: LoadableViewProperties<[World.CountryLite]>) {
        switch properties {
        case let .data(countries):
            DispatchQueue.main.async {
                self.countries = countries
            }
        case .error:
            return
        case .loading:
            self.tableView.bringSubviewToFront(loading)
        }
    }
    
    private var countries: [World.CountryLite] = [] {
        didSet {
            tableView.sendSubviewToBack(loading)
            tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        dispatcher?.dispatch(.willAppear)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "🌎 Countries"
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: String(describing: UITableViewCell.self))
        
        tableView.refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        
        tableView.tableFooterView = UIView()
        tableView.backgroundView = self.loading
    }
    
    @objc func refreshData() {
        dispatcher?.dispatch(.refresh)
        
        // prevent the refresh control from being janky
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.refreshControl?.endRefreshing()
        }
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
        let country = countries[indexPath.item]
        dispatcher?.dispatch(.selectedCountry(code: country.code,
                                              title: "\(country.emoji) \(country.name)"))
    }
}


