//
//  ViewController.swift
//  Messenger_Cover_App
//
//  Created by Thien Tung on 6/8/20.
//  Copyright © 2020 Thien Tung. All rights reserved.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class ConversationsViewController: UIViewController {

    private let spinner = JGProgressHUD(style: .dark)
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.isHidden = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    } ()
    
    private let noConversationLb: UILabel = {
        let label = UILabel()
        label.text = "Chưa có cuộc hội thoại nào"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    } ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(didTapComposeButton))
        
        addComponents()
        setupTableView()
        fetchConversations()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.frame = view.bounds
    }
    
    @objc func didTapComposeButton() {
        let newChatVC = NewConversationViewController()
        let navigation = UINavigationController(rootViewController: newChatVC)
        navigation.modalPresentationStyle = .fullScreen
        present(navigation, animated: true, completion: nil)
    }
    
    func addComponents() {
        view.addSubview(tableView)
        view.addSubview(noConversationLb)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        validateAuth()
        
    }
    
    private func validateAuth() {
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let loginVC = LoginViewController()
            let navigation = UINavigationController.init(rootViewController: loginVC)
            navigation.modalPresentationStyle = .fullScreen
            present(navigation, animated: false, completion: nil)
        }
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func fetchConversations (){
        tableView.isHidden = false
    }
}

extension ConversationsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = "Hello World"
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let chatVC = ChatViewController()
        chatVC.title = "Tung Vu Thien"
        chatVC.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(chatVC, animated: true)
    }
}
