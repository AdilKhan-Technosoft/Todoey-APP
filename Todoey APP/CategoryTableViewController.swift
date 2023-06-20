//
//  ViewController.swift
//  Todoey APP
//
//  Created by Adil Anjum Khan on 20/06/2023.
//

import UIKit

class CategoryTableViewController: UITableViewController {

    @IBOutlet weak var addButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        changeNavBarColor()
        
    }
    
    private func changeNavBarColor()
    {
        // Do any additional setup after loading the view.
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(named: "bar color") // your colour here
        appearance.largeTitleTextAttributes=[NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        addButton.tintColor=UIColor.white
        navigationController?.navigationItem.hidesBackButton=true
        
    }


}

