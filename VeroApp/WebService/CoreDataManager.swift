//
//  CoreDataManager.swift
//  VeroApp
//
//  Created by Omer Keskin on 22.08.2024.
//




import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "VeroApp")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
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
    
    func saveTasks(_ tasks: [Task]) {
        let context = persistentContainer.viewContext
        tasks.forEach { task in
            let newTask = TaskEntity(context: context)
            newTask.task = task.task
            newTask.title = task.title
            newTask.taskDescription = task.description
            newTask.colorCode = task.colorCode
            newTask.sort = task.sort
            newTask.wageType = task.wageType
            newTask.businessUnit = task.businessUnit
            newTask.parentTaskID = task.parentTaskID
            newTask.preplanningBoardQuickSelect = task.preplanningBoardQuickSelect
            newTask.workingTime = task.workingTime
            newTask.isAvailableInTimeTrackingKioskMode = task.isAvailableInTimeTrackingKioskMode
        }
        saveContext()
    }
    
    func fetchTasks() -> [TaskEntity]? {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching tasks: \(error)")
            return nil
        }
    }
}
