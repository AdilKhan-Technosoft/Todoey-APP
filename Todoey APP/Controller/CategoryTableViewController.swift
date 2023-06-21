//
//  ViewController.swift
//  Todoey APP
//
//  Created by Adil Anjum Khan on 20/06/2023.
//

import UIKit
import CoreData

class CategoryTableViewController: UITableViewController {

    @IBOutlet weak var addButton: UIBarButtonItem!
    var myTittles=[TaskTittles]()
    var selectedRow:Int?
    let context=((UIApplication.shared.delegate) as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        changeNavBarColor()
        loadUserTasksFromDB()
        
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
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        addButton.tintColor=UIColor.white
        navigationController?.navigationItem.hidesBackButton=true
    }
    
    //loadData to represent from DB
    
    private func loadUserTasksFromDB()
    {
        let request:NSFetchRequest<TaskTittles> = TaskTittles.fetchRequest()
        do
        {
            try myTittles=context.fetch(request)
        }
        catch
        {
            print("Error in fetching data from DB \(error)")
        }
    }
    
    
    //MARK:- Adding table view data source methodes
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myTittles.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reusable cell",for: indexPath)
        cell.textLabel?.text = myTittles[indexPath.row].tittleOfTask
        return cell
    }
    
    // MARK: Adding add button functionality
    
    @IBAction func addTittleToList(_ sender: UIBarButtonItem) {
        var txtFieldOfAddButton:UITextField?
        let allert = UIAlertController(title: "Add Task", message: "Add tittle referring sub tasks", preferredStyle: .alert)
        
        allert.addTextField { txtField in
            txtField.placeholder="Enter task tittle..."
           txtFieldOfAddButton=txtField
        }
        let action=UIAlertAction(title: "Add", style: .default) { confirmationButton in
            print("Requested to add...")
            let newTaskHeader=TaskTittles(context: self.context)
            newTaskHeader.tittleOfTask = txtFieldOfAddButton?.text!
            self.myTittles.append(newTaskHeader)
            self.saveContext()
            self.tableView.reloadData()
        }
        allert.addAction(action)
        present(allert, animated: true)
    }
    
    private func saveContext()
    {
        do{
            try context.save()
        }
        catch{
            print("Error in saving data :( \(error)")
        }
    }
    
    //MARK:- Adding delegate functionality for table view
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedRow=indexPath.row
        performSegue(withIdentifier: "transitionToSubTasks", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(80)
    }
    
    //MARK:- Preparing Sague for transition by setting the destination view controller attributes
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier=="transitionToSubTasks")
        {
            if let rowSelected = selectedRow
            {
                let destination = segue.destination as! SubTaskViewController
                destination.tittleForSubTask=myTittles[rowSelected]
            }
            
        }
    }


}

