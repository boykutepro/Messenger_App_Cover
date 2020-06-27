//
//  NewConversationViewController.swift
//  Messenger_Cover_App
//
//  Created by Thien Tung on 6/8/20.
//  Copyright © 2020 Thien Tung. All rights reserved.
//

import UIKit
import JGProgressHUD

class NewConversationViewController: UIViewController {

    private let spinner = JGProgressHUD(style: .extraLight)

    private var users = [[String: String]] ()
    
    private var results = [[String: String]] ()
    
    private var hasFetched = false
    
    private let searchBar:UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search For Users"
        return searchBar
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.isHidden = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    private let noResultLbl: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "Không có kết quả nào"
        label.textAlignment = .center
        label.textColor = .green
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        setSearchBar()
        addComponents()
        setTableView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.frame = view.bounds
        noResultLbl.frame = CGRect(x: view.width/4,
                                   y: (view.height-200)/2,
                                   width: view.width/2,
                                   height: 100)
    }
    
    private func addComponents() {
        view.addSubview(noResultLbl)
        view.addSubview(tableView)
    }
    
    private func setTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setSearchBar () {
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
        // Tự gán searchBar = navigation bar để không cần chỉnh vị trí của nó.
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Huỷ",
                            style: .done,
                            target: self,
                            action: #selector(dismissSelf))
    }
    
    @objc private func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }
}

extension NewConversationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = results[indexPath.row]["name"]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Vao man hinh nhan tin
    }
    
}

extension NewConversationViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        
        searchBar.resignFirstResponder()
        
        results.removeAll()
        spinner.show(in: view)
        
        self.searchUsers(query: text)
    }
    
    func searchUsers(query: String) {
        // Kiểm tra mảng chứa kết quả firebase trả về.
        if hasFetched {
        // nếu có: lọc.
            filterUser(with: query)
            
        } else {
        // nếu không: lấy kết quả rồi lọc.
            DatabaseManager.shared.getAllUsers { [weak self] (result) in
                switch result {
                case .success(let userCollection):
                    self?.hasFetched = true
                    self?.users = userCollection
                    self?.filterUser(with: query)
                case .failure(let error):
                    print("Lỗi: \(error)")
                }
            }
            
        }
        // Sau đó update UI
    
    }
    
    func filterUser(with term: String) {
        // UPDATE UI: either show results or show no results label
        guard hasFetched else {
            return
        }
        
        self.spinner.dismiss()
        
        let results: [[String: String]] = self.users.filter({
            guard let name = $0["name"]?.lowercased() else {
                return false
            }
            return name.hasPrefix(term.lowercased())
        })
        
        self.results = results
        updateUI()
    }
    
    func updateUI() {
        if results.isEmpty {
            self.noResultLbl.isHidden = false
            self.tableView.isHidden = true
        } else {
            self.noResultLbl.isHidden = true
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
    }
}
