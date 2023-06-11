//
//  SearchTableViewController.swift
//  dca-calculator
//
//  Created by Ivan Pastukhov on 16.07.2021.
//

import UIKit
import Combine
import MBProgressHUD

class SearchViewModel {
    
    struct Input {
        let viewDidLoadPublisher: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let setupNavigationBar: AnyPublisher<String, Never>
    }
        
    func transform(input: Input) -> Output {
        let setupNavigationBar: AnyPublisher<String, Never> =
        input.viewDidLoadPublisher.flatMap {
            return Just("Search").eraseToAnyPublisher()
        }.eraseToAnyPublisher()
        return .init(setupNavigationBar: setupNavigationBar)
    }
}

class SearchTableViewController: UITableViewController, UIAnimatable {
    
    private let viewDidLoadSubject = PassthroughSubject<Void, Never>()
    private let viewModel = SearchViewModel()
    
    private enum Mode {
        case onboarding
        case search
    }
    
    private lazy var searchController: UISearchController = {
        let sc = UISearchController()
        sc.searchResultsUpdater = self
        sc.delegate = self
        sc.obscuresBackgroundDuringPresentation = false
        sc.searchBar.placeholder = "Enter a company name"
        sc.searchBar.autocapitalizationType = .allCharacters
        return sc
    }()
    
    private let apiService = APIService()
    private var subscribers = Set<AnyCancellable>()
    private var searchResults: SearchResults?
    
    @Published private var mode: Mode = .onboarding
    @Published private var searchQuery = String()
    
    override func loadView() {
        super.loadView()
        observe()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewDidLoadSubject.send()
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.isScrollEnabled = false
        tableView.tableFooterView = UIView()
    }
    
    private func observe() {
        
        let input = SearchViewModel.Input(viewDidLoadPublisher: viewDidLoadSubject.eraseToAnyPublisher())
        let output = viewModel.transform(input: input)
        
        output.setupNavigationBar
            .receive(on: DispatchQueue.main)
            .sink { [weak self] title in
                self?.navigationItem.searchController = self?.searchController
                self?.navigationItem.title = title
            }.store(in: &subscribers )
        
        $searchQuery
            .debounce(for: .milliseconds(700), scheduler: RunLoop.main)
            .sink { [unowned self] searchQuery in
                guard !searchQuery.isEmpty else { return }
                showLoadingAnimation()
                self.apiService.fetchSymbolPublisher(keywords: searchQuery).sink { [weak self] completion in
                    self?.hideLoadingAnimation()
                    switch completion {
                    case .failure(let error):
                        print(error.localizedDescription)
                    case .finished:
                        break
                    }
                } receiveValue: { searchResults in
                    self.searchResults = searchResults
                    self.tableView.reloadData()
                    self.tableView.isScrollEnabled = true
                }.store(in: &self.subscribers)
                
            }.store(in: &subscribers)
        
        $mode.sink { [unowned self] mode in
            switch mode {
            case .onboarding:
                self.tableView.backgroundView = SearchPlaceholderView()
            case .search:
                self.tableView.backgroundView = nil
            }
        }.store(in: &subscribers)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults?.items.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellid", for: indexPath) as! SearchTableViewCell
        if let searchResults = self.searchResults {
            let searchResult = searchResults.items[indexPath.row]
            cell.configure(with: searchResult)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let searchResults = self.searchResults {
            let searchResult = searchResults.items [indexPath.item]
            let symbol = searchResult.symbol
            handleSelection(for: symbol, searchResult: searchResult)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func handleSelection(for symbol: String, searchResult: SearchResult) {
        showLoadingAnimation()
        apiService.fetchTimeSeriesMonthlyAdjustedPublisher(keywords: symbol).sink { [weak self] completionResult in
            self?.hideLoadingAnimation()
            switch completionResult {
            case .failure(let error):
                print (error)
            case .finished:
                break
            }
        } receiveValue: { [weak self] timeSeriesMonthlyAdjusted in
            let asset = Asset(searchResult: searchResult, timeSeriesMonthlyAdjusted: timeSeriesMonthlyAdjusted)
            self?.performSegue(withIdentifier: "showCalculator", sender: asset)
            self?.searchController.searchBar.text = nil
        }.store(in: &subscribers)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "showCalculator",
                let destination = segue.destination as? CalculatorTableViewController,
                let asset = sender as? Asset
        else { return }
        
        destination.asset = asset 
    }
    
}

extension SearchTableViewController: UISearchResultsUpdating, UISearchControllerDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchQuery = searchController.searchBar.text, !searchQuery.isEmpty else { return }
        self.searchQuery = searchQuery
    }
    
    func willPresentSearchController(_ searchController: UISearchController) {
        mode = .search
    }
    
}
