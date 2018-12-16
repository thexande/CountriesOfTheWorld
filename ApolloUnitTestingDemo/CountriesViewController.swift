import UIKit
import WorldAPI

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


