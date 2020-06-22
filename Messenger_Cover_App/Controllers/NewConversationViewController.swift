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

    private let spinner = JGProgressHUD()
    
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

        searchBar.delegate = self
        view.backgroundColor = .white
        
        // Tự gán searchBar = navigation bar để không cần chỉnh vị trí của nó.
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Huỷ",
                            style: .done,
                            target: self,
                            action: #selector(dismissSelf))
        searchBar.becomeFirstResponder()
    }
    
    @objc private func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }
}

extension NewConversationViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
    }
}
