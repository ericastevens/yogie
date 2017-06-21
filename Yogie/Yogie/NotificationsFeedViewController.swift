//
//  NotificationsFeedViewController.swift
//  Yogie
//
//  Created by Erica Y Stevens on 5/11/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit

class NotificationsFeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        setupViewHierarchy()
        configureConstraints()
        configureNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.statusBarStyle = .default
    }
    
    // MARK: Configuration
    
    func configureNavigationBar() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissVC(_:)))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.YogieTheme.darkPrimaryColor
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(NotificationTableViewCell.self, forCellReuseIdentifier: "NotificationCell")
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    func setupViewHierarchy() {
        self.view.addSubview(tableView)
    }
    
    func configureConstraints() {
        let _ = [
        tableView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
        tableView.heightAnchor.constraint(equalTo: self.view.heightAnchor),
        tableView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
        tableView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
            ].map{ $0.isActive = true }
    }
    
    // MARK: Helper Methods
    
    func dismissVC(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: Lazy Instantiation
    
    lazy var tableView: UITableView = {
       let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    // MARK: UITableView Data Source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationTableViewCell
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
   
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
