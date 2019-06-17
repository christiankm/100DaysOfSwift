//
//  ViewController.swift
//  Day32Challenge
//
//  Created by Christian Mitteldorf on 17/06/2019.
//  Copyright © 2019 MobilePay. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    var shoppingList: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Shopping List"

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(reloadItems))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItem))
    }

    @objc func reloadItems() {
        shoppingList.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }

    @objc func addItem() {
        let alertController = UIAlertController(title: "Add item", message: nil, preferredStyle: .alert)
        alertController.addTextField(configurationHandler: nil)
        alertController.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak self] action in
            if let text = alertController.textFields?.first?.text {
                self?.shoppingList.append(text)
                let indexPath = IndexPath(row: (self?.shoppingList.endIndex ?? 0) - 1, section: 0)
                self?.tableView.insertRows(at: [indexPath], with: .automatic)
            }
        }))
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: UITableView Data Source

extension ViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shoppingList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShoppingItemCell", for: indexPath)
        cell.textLabel?.text = shoppingList[indexPath.row]
        return cell
    }
}

