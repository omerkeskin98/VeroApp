//
//  ViewModel.swift
//  VeroApp
//
//  Created by Omer Keskin on 22.08.2024.
//



import Foundation

class ViewModel {
    private var tasks: [TaskEntity] = []
    var filteredTasks: [TaskEntity] = []
    
    func loadTasks(completion: @escaping () -> Void) {
        if let savedTasks = CoreDataManager.shared.fetchTasks(), !savedTasks.isEmpty {
            self.tasks = savedTasks
            self.filteredTasks = savedTasks
            completion()
        } else {
            WebService.shared.authenticate { success in
                guard success else { return }
                WebService.shared.fetchTasks { tasks in
                    guard let tasks = tasks else { return }
                    CoreDataManager.shared.saveTasks(tasks)
                    self.tasks = CoreDataManager.shared.fetchTasks() ?? []
                    self.filteredTasks = self.tasks
                    completion()
                }
            }
        }
    }

    func filterTasks(searchText: String) {
        if searchText.isEmpty {
            filteredTasks = tasks
        } else {
            filteredTasks = tasks.filter { task in
                let searchTextLowercased = searchText.lowercased()
                return (task.title?.lowercased().contains(searchTextLowercased) ?? false ||
                        task.task?.lowercased().contains(searchTextLowercased) ?? false ||
                        task.taskDescription?.lowercased().contains(searchTextLowercased) ?? false ||
                        task.sort?.lowercased().contains(searchTextLowercased) ?? false ||
                        task.wageType?.lowercased().contains(searchTextLowercased) ?? false ||
                        task.businessUnit?.lowercased().contains(searchTextLowercased) ?? false ||
                        task.parentTaskID?.lowercased().contains(searchTextLowercased) ?? false ||
                        task.preplanningBoardQuickSelect?.lowercased().contains(searchTextLowercased) ?? false ||
                        task.workingTime?.lowercased().contains(searchTextLowercased) ?? false)
            }
        }
    }
}
