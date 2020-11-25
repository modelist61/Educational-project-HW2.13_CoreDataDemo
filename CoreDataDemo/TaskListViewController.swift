//
//  ViewController.swift
//  CoreDataDemo
//
//  Created by Alexey Efimov on 23.11.2020.
//

import UIKit
import CoreData

class TaskListViewController: UITableViewController {
    
    private let context = StorageManager.share.persistentContainer.viewContext
    
    private let cellID = "cell"
    private var tasks: [Task] = []
    private var choosenPathRow = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID) //ячейка на TaleView
        view.backgroundColor = .white
        setupNavigationBar()
        fetchData()
    }


    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navBarAppearance.backgroundColor = UIColor(
            red: 21/255,
            green: 101/255,
            blue: 192/255,
            alpha: 194/255
        )
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        navigationController?.navigationBar.tintColor = .white
    }
    
    @objc private func addNewTask() {
        showAlert(withTitle: "Add New Task", andMessage: "What do you want to do?")
    }
    
    private func fetchData() { //подгрузка из CoreData
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        do {
            tasks = try context.fetch(fetchRequest)
            tableView.reloadData()
        } catch let error {
            print(error)
        }
    }
    
}

// MARK: - Table view data source
extension TaskListViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = tasks[indexPath.row]
        var content = cell.defaultContentConfiguration() //конфигурация ячейки
        content.text = task.name
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { _,_,_ in
            self.choosenPathRow = indexPath.row
            self.showDelAlert(withTitle: "Are You Sure to Delete?", andMessage: "Data will be lost forever")
        }
        
        let edit = UIContextualAction(style: .destructive, title: "Edit") { _,_,_  in
            self.choosenPathRow = indexPath.row
            let choosenPathContent = self.tasks[indexPath.row].name
            self.showEditAlert(withTitle: "Change Task", textForEdit: choosenPathContent ?? "")
        }
        edit.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        
        let swipeActions = UISwipeActionsConfiguration(actions: [delete, edit])
        return swipeActions
    }
}

//MARK: - Alerts
extension TaskListViewController {
    private func showAlert(withTitle title: String, andMessage message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
            self.save(task)
        }
         
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    private func showDelAlert(withTitle title: String, andMessage message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Yes", style: .default) { _ in
            self.delete()
        }
        let cancelAction = UIAlertAction(title: "No", style: .destructive) { _ in
            let cellIndex = IndexPath(row: self.choosenPathRow, section: 0)
            self.tableView.reloadRows(at: [cellIndex], with: .automatic)
        }
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    private func showEditAlert(withTitle title: String, textForEdit text: String = "") {
        let alert = UIAlertController(title: title, message: "", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
            self.editAndSave(task)
        }
         
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { _ in
            let cellIndex = IndexPath(row: self.choosenPathRow, section: 0)
            self.tableView.reloadRows(at: [cellIndex], with: .automatic)
        }
        alert.addTextField { (textField) in
            textField.text = text
        }
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
}

//MARK: - Editing method
extension TaskListViewController {
    private func save(_ taskName: String) {
        let task = StorageManager.share.initTaskEntity()
        
        task.name = taskName
        tasks.append(task)
 
        let cellIndex = IndexPath(row: tasks.count - 1, section: 0)
        tableView.insertRows(at: [cellIndex], with: .automatic)
        
        if context.hasChanges {
            do {
                try context.save()
            } catch let error {
                print(error)
            }
        }
    }
    
    private func delete() {
        let delPath = tasks.remove(at: choosenPathRow)
        
        let cellIndex = IndexPath(row: choosenPathRow, section: 0)
        self.tableView.deleteRows(at: [cellIndex], with: .automatic)

        StorageManager.share.deleteTask(delTask: delPath)
    }
    
    private func editAndSave(_ taskName: String) {
        tasks[choosenPathRow].name = taskName
        let choosTask = tasks[choosenPathRow].name
        
        let cellIndex = IndexPath(row: choosenPathRow, section: 0)
        self.tableView.reloadRows(at: [cellIndex], with: .automatic)

        StorageManager.share.editTask(editTask: choosTask)
    }
}
  



