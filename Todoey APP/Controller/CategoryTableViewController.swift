//
//  ViewController.swift
//  Todoey APP
//
//  Created by Adil Anjum Khan on 20/06/2023.
//
import SwipeCellKit
import UIKit
import CoreData

class CategoryTableViewController: SwipeToDelete {
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    var myTittles=[TaskTittles]()
    var selectedRow:Int?
    var alertController: UIAlertController?
    let context=((UIApplication.shared.delegate) as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        changeNavBarColor()
        loadUserTasksFromDB()
    }
    
    //MARK:- Dismissing keyboard and allerts on tap gestures
    
    @objc func dismissOnTapOutside(){
        self.dismiss(animated: true, completion: nil)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "reusable cell",for: indexPath) as! SwipeTableViewCell
        cell.delegate=self
        cell.textLabel?.text = myTittles[indexPath.row].tittleOfTask
        return cell
    }
    
    // MARK: Adding add button functionality
    
    @IBAction func addTittleToList(_ sender: UIBarButtonItem) {
        
        showAllert(title: "Add Task", message: "Add tittle task",choice: 1)
    }
    
    fileprivate func addRequest(_ txtField:UITextField) {
        if(txtField.text!.trimmingCharacters(in: .whitespaces)=="")
        {
            self.presentingViewController?.dismiss(animated: false, completion: nil)
            showAllert(title: "Add Task", message: "Tittle task shouuld be assigned valid name",choice: 1,placeholder: "Enter a valid name for task",color: UIColor.red)
            
        }
        else
        {
            print("Requested to add...")
            let newTaskHeader=TaskTittles(context: self.context)
            newTaskHeader.tittleOfTask = txtField.text!
            self.myTittles.append(newTaskHeader)
            self.saveContext()
            self.tableView.reloadData()
        }
    }
    
    private func showAllert(title:String,message:String,choice:Int,indexPath:IndexPath? = nil,placeholder:String = "Enter task tittle...", color:UIColor=UIColor.gray)
    {
        var txtFieldOfAddButton:UITextField?
        let allert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        allert.addTextField { txtField in
            txtField.placeholder="Enter task tittle..."
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: color, // Set the desired color
                .font: UIFont.systemFont(ofSize: 16) // Set the desired font
            ]
            txtField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: attributes)
            txtFieldOfAddButton=txtField
        }
        let action=UIAlertAction(title: choice==1 ? "Add" : "Edit", style: .default) { confirmationButton in
            if(choice==1)
            {
                self.addRequest(txtFieldOfAddButton!)
            }
            else
            {
                self.editTittleTask(txtFieldOfAddButton!,indexPath!)
            }
        }
        allert.addAction(action)
        
        self.present(allert, animated: true, completion:{
            allert.view.superview?.isUserInteractionEnabled = true
            allert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.dismissOnTapOutside)))
        })
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
    
    //Adding delete Action
    override func performDeleteAction(indexPath: IndexPath) {
        
        context.delete(self.myTittles[indexPath.row])
        self.myTittles.remove(at: indexPath.row)
        saveContext()
    }
    
    //Adding edit Action
    override func performEditAction(indexPath: IndexPath) {
        showAllert(title: "Edit Tittle", message: "Add the new tittle",choice: 2, indexPath: indexPath)
    }
    
    fileprivate func editTittleTask(_ txtField:UITextField,_ indexPath: IndexPath) {
        if(txtField.text!.trimmingCharacters(in: .whitespaces)=="")
        {
            self.presentingViewController?.dismiss(animated: false, completion: nil)
            showAllert(title: "Add Task", message: "Tittle task shouuld be assigned valid name",choice: 2,indexPath: indexPath,placeholder: "Enter a valid name for task",color: UIColor.red)
        }
        else
        {
            myTittles[indexPath.row].tittleOfTask=txtField.text!
            self.saveContext()
            self.tableView.reloadData()
        }
        
    }
}
