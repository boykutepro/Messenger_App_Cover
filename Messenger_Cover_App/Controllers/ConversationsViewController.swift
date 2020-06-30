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

struct Conversation {
    let id: String
    let name: String
    let otherUserEmail: String
    let latestMessage: LatestMessage
}

struct LatestMessage {
    let date: String
    let text: String
    let isRead: Bool
}

class ConversationsViewController: UIViewController {

    private let spinner = JGProgressHUD(style: .dark)

    private var conversations = [Conversation] ()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.isHidden = true
        tableView.register(ConversationTableViewCell.self,
                           forCellReuseIdentifier: ConversationTableViewCell.identifier)
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
        startListeningForConversation()
    }
    
    private func startListeningForConversation() {
        
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        print("starting conversation fetch...")
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        DatabaseManager.shared.getAllConversations(for: safeEmail) { [weak self] (result) in
            switch result {
            case .success(let conversations):
                print("Successfully got conversation models")
                guard !conversations.isEmpty else {
                    return
                }
                self?.conversations = conversations
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
                
            case .failure(let error):
                print("Failed to get convos: \(error)")
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.frame = view.bounds
    }
    
    @objc func didTapComposeButton() {
        let newChatVC = NewConversationViewController()
        newChatVC.completion = { [weak self] result in
            //print(result)
            self?.createNewConversation(result: result)
        }
        let navigation = UINavigationController(rootViewController: newChatVC)
        present(navigation, animated: true, completion: nil)
    }
    
    private func createNewConversation(result: [String: String]) {
        guard let name = result["name"],
            let email = result["email"] else {
                return
        }
        let chatVC = ChatViewController(with: email)
        chatVC.isNewConversation = true
        chatVC.title = name  //"Tung Vu Thien"
        chatVC.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(chatVC, animated: true)
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
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = conversations[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.identifier, for: indexPath) as! ConversationTableViewCell
        cell.configure(with: model)
//        cell.textLabel?.text = "Hello World"
//        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = conversations[indexPath.row]
        
        let chatVC = ChatViewController(with: model.otherUserEmail)
        chatVC.title = model.name
        chatVC.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}
