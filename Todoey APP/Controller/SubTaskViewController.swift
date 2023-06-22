//
//  SubTaskViewController.swift
//  Todoey APP
//
//  Created by Adil Anjum Khan on 21/06/2023.
//

import UIKit
import CoreData
import SwipeCellKit
import AVFoundation

class SubTaskViewController: SwipeToDelete {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var addButton: UIBarButtonItem!
    var subTasks:[SubTasks]=[]
    var player:AVAudioPlayer!
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
        searchBar.delegate=self
        loadSubTaskForRequestedTask()
        changeSearchBarDisplay()
        tableView.rowHeight=UITableView.automaticDimension
        tableView.estimatedRowHeight=10
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
        
        
    }
    
    // MARK: Adding add button functionality
    
    @IBAction func addButtonFunctionality(_ sender: UIBarButtonItem) {
        
        showAllert(title: "Add Task", message: "Add sub task for \(tittleForSubTask?.tittleOfTask! ?? "Tittle task")...",choice: 1)
    }
    
    fileprivate func addRequest(_ txtField:UITextField) {
        print("Requested to add...")
        if(txtField.text!.trimmingCharacters(in: .whitespaces)=="")
        {
            self.presentingViewController?.dismiss(animated: false, completion: nil)
            showAllert(title: "Add Task", message: "Subtask shoud be assigned a valid name",choice: 1,placeholder: "Enter a valid name for task",color: UIColor.red)
            
        }
        else
        {
            let newSubTask=SubTasks(context: self.context)
            newSubTask.isChecked=false
            newSubTask.subTaskDescription=txtField.text!
            newSubTask.parentTask=self.tittleForSubTask!
            self.subTasks.append(newSubTask)
            self.saveContext()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "reusable cell",for: indexPath) as! SwipeTableViewCell
        cell.delegate=self
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
        if(subTasks[indexPath.row].isChecked)
        {
            subTasks[indexPath.row].isChecked=false
        }
        else
        {
            subTasks[indexPath.row].isChecked=true
            playAllarmSound()
        }
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
    
    //Adding delete Action
    override func performDeleteAction(indexPath: IndexPath) {
        
        context.delete(self.subTasks[indexPath.row])
        self.subTasks.remove(at: indexPath.row)
        do{
            try context.save()
        }
        catch{
            print("Error in saving data :( \(error)")
        }
    }
    
    func playAllarmSound() {
        guard let path = Bundle.main.path(forResource: "allert", ofType:"mp3") else
        {
            return
        }
        let url = URL(fileURLWithPath: path)
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    //Adding edit Action
    override func performEditAction(indexPath: IndexPath) {
        showAllert(title: "Edit Tittle", message: "Add the new name for sub task...",choice: 2, indexPath: indexPath)
    }
    
    fileprivate func editTittleTask(_ txtField:UITextField,_ indexPath: IndexPath) {
        if(txtField.text!.trimmingCharacters(in: .whitespaces)=="")
        {
            self.presentingViewController?.dismiss(animated: false, completion: nil)
            showAllert(title: "Add Task", message: "Subtask shoud be assigned a valid name",choice: 2,indexPath: indexPath,placeholder: "Enter a valid name for task",color: UIColor.red)
        }
        else
        {
            subTasks[indexPath.row].subTaskDescription=txtField.text!
            self.saveContext()
        }
    }
    
}

//MARK:- Implementing functions of searchbar delegate

extension SubTaskViewController:UISearchBarDelegate
{
    
    private func executeSearchAction(subStr:String)
    {
        let request:NSFetchRequest<SubTasks> = SubTasks.fetchRequest()
        let pradicateToSearch = NSPredicate(format: "subTaskDescription CONTAINS[c] %@",subStr)
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
