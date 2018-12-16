import UIKit
import WorldAPI
import Anchorage

protocol CountriesViewActionDispatching: AnyObject {
    func dispatch(_ action: CountriesViewController.Action)
}

final class CountriesViewController: UIViewController {
    
    enum Action {
        case willAppear
        case selectedCountry(code: String)
    }
    
    weak var dispatcher: CountriesViewActionDispatching?
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let loadingView = TableLoadingView()
    
    func render(_ properties: LoadableViewProperties<[World.CountryLite]>) {
        switch properties {
        case let .data(countries):
            DispatchQueue.main.async {
                self.countries = countries
            }
        case .error:
            return
        case .loading:
            view.bringSubviewToFront(loadingView)
        }
    }
    
    private var countries: [World.CountryLite] = [] {
        didSet {
            tableView.reloadData()
            view.bringSubviewToFront(tableView)
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
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: String(describing: UITableViewCell.self))
        
        view.addSubview(tableView)
        view.addSubview(loadingView)
        loadingView.edgeAnchors == view.edgeAnchors
        tableView.edgeAnchors == view.edgeAnchors
    }
}

extension CountriesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return countries.count
    }
    
    func tableView(_ tableView: UITableView,
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
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        dispatcher?.dispatch(.selectedCountry(code: countries[indexPath.item].code))
    }
}


