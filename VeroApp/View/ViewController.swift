//
//  ViewController.swift
//  VeroApp
//
//  Created by Omer Keskin on 22.08.2024.
//



import UIKit
import QRCodeReader
import SnapKit
import Reachability

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIScrollViewDelegate {
    
    private let viewModel = ViewModel()
    private let tableView = UITableView()
    private let searchBar = UISearchBar()
    private let refreshControl = UIRefreshControl()
    private let qrScanButton = UIButton(type: .system)
    private var reader: QRCodeReader?
    private var readerViewController: QRCodeReaderViewController?
    private let reachability = try! Reachability()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadTasks()
        setupKeyboardDismissal()
        setupReachability()
        tableView.rowHeight = UITableView.automaticDimension
    
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // Setup QR Scan Button
        qrScanButton.setTitle("Scan QR", for: .normal)
        qrScanButton.addTarget(self, action: #selector(scanQRCode), for: .touchUpInside)
        view.addSubview(qrScanButton)
        
        qrScanButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.right.equalToSuperview().inset(10)
            make.height.equalTo(30)  // Adjust size as needed
        }
        
        // Setup Search Bar
        searchBar.delegate = self
        view.addSubview(searchBar)
        
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(qrScanButton.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(10)
            make.height.equalTo(44)  // Adjust height as needed
        }
        
        // Setup Table View
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TaskCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        
        // Setup Refresh Control
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    private func loadTasks() {
        viewModel.loadTasks {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private func setupReachability() {
        reachability.whenReachable = { _ in
            // Network is reachable
        }
        reachability.whenUnreachable = { _ in
            // Network is unreachable
            DispatchQueue.main.async {
                self.showNoInternetAlert()
            }
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start reachability notifier")
        }
    }
    
    @objc private func refreshData() {
        if reachability.connection != .unavailable {
            viewModel.loadTasks {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                }
            }
        } else {
            self.showNoInternetAlert()
            self.refreshControl.endRefreshing()
        }
    }
    
    private func setupKeyboardDismissal() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Dismiss the keyboard when the user starts scrolling
        dismissKeyboard()
    }
    
    private func showNoInternetAlert() {
        let alert = UIAlertController(title: "No Internet Connection", message: "Please check your internet connection and try again.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filteredTasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TaskCell
        let task = viewModel.filteredTasks[indexPath.row]
        cell.configure(with: task)
        return cell
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.filterTasks(searchText: searchText)
        tableView.reloadData()
    }
    
    @objc private func scanQRCode() {
      
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
            $0.showTorchButton = true
            $0.showCancelButton = true
            $0.cancelButtonTitle = "Cancel"
        }
        readerViewController = QRCodeReaderViewController(builder: builder)
        readerViewController?.delegate = self
        
        
        if let readerVC = readerViewController {
            present(readerVC, animated: true, completion: nil)
        }
    }
}

extension ViewController: QRCodeReaderViewControllerDelegate {
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        searchBar.text = result.value
        searchBar.delegate?.searchBar?(searchBar, textDidChange: result.value)
        
    
        dismiss(animated: true, completion: nil)
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
       
        dismiss(animated: true, completion: nil)
    }
}

