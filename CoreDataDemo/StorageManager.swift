//
//  StorageManager.swift
//  CoreDataDemo
//
//  Created by Dmitry Tokarev on 24.11.2020.
//

import Foundation
import CoreData

class StorageManager {
    private init() {}
    static let share = StorageManager()
    
    // MARK: - Core Data stack
    var persistentContainer: NSPersistentContainer = { // свойство для работы с CoreData
        let container = NSPersistentContainer(name: "CoreDataDemo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in //обработка ошибки
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func initTaskEntity() -> Task{
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Task", in: persistentContainer.viewContext) else { return Task.init() }
        guard let task = NSManagedObject(entity: entityDescription, insertInto: persistentContainer.viewContext) as? Task else { return Task.init() }
        return task
    }
    
    func deleteTask(delTask delRow: Task ) {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        do {
            let tasks = try persistentContainer.viewContext.fetch(request)
            for task in tasks as [NSManagedObject] {
                if task == delRow {
                    do {
                        persistentContainer.viewContext.delete(task)
                        try persistentContainer.viewContext.save()
                    } catch let error {
                        print(error)
                    }
                }
            }
        } catch let error {
            print(error)
        }
    }
    
    func editTask(editTask editRow: String?) {
        let request: NSFetchRequest<Task> = Task.fetchRequest()
        do {
            let results = try persistentContainer.viewContext.fetch(request)
            for result in results as [NSManagedObject] {
                if let editTask = result.value(forKey: "name") as? String {
                    if editTask == editRow {
                        result.setValue(editRow, forKey: "name")
                        do {
                            try persistentContainer.viewContext.save()
                        } catch let error {
                            print(error)
                        }
                    }
                }
            }
        } catch let error {
            print(error)
        }
    }
}
