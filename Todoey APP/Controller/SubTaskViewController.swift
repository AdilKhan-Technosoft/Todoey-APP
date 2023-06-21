//
//  SubTaskViewController.swift
//  Todoey APP
//
//  Created by Adil Anjum Khan on 21/06/2023.
//

import UIKit
import CoreData

class SubTaskViewController: UITableViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var addButton: UIBarButtonItem!
    var subTasks:[SubTasks]=[]
    let context=((UIApplication.shared.delegate) as! AppDelegate).persistentContainer.viewContext
    
    
    var tittleForSubTask:TaskTittles?
    {
        didSet
        {
            navigationItem.title=tittleForSubTask?.tittleOfTask
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        changeNavBarColor()
        changeSearchBarDisplay()
        searchBar.delegate=self
        loadSubTaskForRequestedTask()
        tableView.rowHeight=UITableView.automaticDimension
        tableView.estimatedRowHeight=100
    }
    
    
    //MARK:- Changing Navbar Configuration
    
    private func changeNavBarColor()
    {
        // Do any additional setup after loading the view.
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(named: "bar color")
        appearance.largeTitleTextAttributes=[NSAttributedString.Key.foregroundColor: UIColor.white]
        appearance.titleTextAttributes=[NSAttributedString.Key.foregroundColor: UIColor.white]
        appearance.backButtonAppearance.normal.titleTextAttributes=[NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        addButton.tintColor=UIColor.white
    }
    
    //MARK:- Changing search bar pdisplay properties
    
    private func changeSearchBarDisplay()
    {
        searchBar.barTintColor = UIColor(named: "bar color")
        
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = UIColor.white
        }
        
        // Set the background color of the search bar cancel button
        if let cancelButton = searchBar.value(forKey: "cancelButton") as? UIButton {
            cancelButton.backgroundColor = UIColor.black
        }
        
    }
    
    // MARK: Adding add button functionality
    
    @IBAction func addButtonFunctionality(_ sender: UIBarButtonItem) {
        var txtFieldOfAddButton:UITextField?
        let allert = UIAlertController(title: "Add Task", message: "Add tittle referring sub tasks", preferredStyle: .alert)
        
        allert.addTextField { txtField in
            txtField.placeholder="Enter task tittle..."
            txtFieldOfAddButton=txtField
        }
        let action=UIAlertAction(title: "Add", style: .default) { confirmationButton in
            print("Requested to add...")
            let newSubTask=SubTasks(context: self.context)
            newSubTask.isChecked=false
            newSubTask.subTaskDescription=txtFieldOfAddButton?.text!
            newSubTask.parentTask=self.tittleForSubTask!
            self.subTasks.append(newSubTask)
            self.saveContext()
        }
        allert.addAction(action)
        present(allert, animated: true)
    }
    
    private func saveContext()
    {
        do{
            try context.save()
            loadSubTaskForRequestedTask()
        }
        catch{
            print("Error in saving data :( \(error)")
        }
    }
    
    //MARK:- Adding table view data source methodes
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subTasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reusable cell",for: indexPath)
        cell.textLabel?.text = subTasks[indexPath.row].subTaskDescription
        cell.accessoryType = subTasks[indexPath.row].isChecked==true ? .checkmark : .none
        return cell
    }
    
    //MARK:- Adding delegate functionality for table view
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(80)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        subTasks[indexPath.row].isChecked = !subTasks[indexPath.row].isChecked
        saveContext()
        
    }
    
    //load data from db
    private func loadSubTaskForRequestedTask(request:NSFetchRequest<SubTasks>=SubTasks.fetchRequest() , pradicate:NSPredicate?=nil)
    {
        let pradicateToLoadforParentOnly = NSPredicate(format: "parentTask.tittleOfTask MATCHES %@",(tittleForSubTask?.tittleOfTask)!)
        
        let sortDiscriptor = NSSortDescriptor(key: "isChecked", ascending: true)
        request.sortDescriptors = [sortDiscriptor]
        
        if let subSearchPradicate=pradicate
        {
            let combinedPradicate=NSCompoundPredicate(andPredicateWithSubpredicates: [pradicateToLoadforParentOnly,subSearchPradicate])
            request.predicate=combinedPradicate
            
        }
        else
        {
            request.predicate=pradicateToLoadforParentOnly
        }
        request.sortDescriptors=[sortDiscriptor]
        do
        {
            try subTasks=context.fetch(request)
            tableView.reloadData()
        }
        catch
        {
            print("Error in fetching data from DB \(error)")
        }
    }
    
}

//MARK:- Implementing functions of searchbar delegate

extension SubTaskViewController:UISearchBarDelegate
{
    
    private func executeSearchAction(subStr:String)
    {
        let request:NSFetchRequest<SubTasks> = SubTasks.fetchRequest()
        let pradicateToSearch = NSPredicate(format: "subTaskDescription CONTAINS %@",subStr)
        loadSubTaskForRequestedTask(request: request,pradicate: pradicateToSearch)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if(searchBar.searchTextField.text! != "")
        {
            executeSearchAction(subStr: searchBar.searchTextField.text!)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchBar.searchTextField.text!.count==0)
        {
            loadSubTaskForRequestedTask()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
        else
        {
            executeSearchAction(subStr: searchBar.searchTextField.text!)
        }
    }
}
