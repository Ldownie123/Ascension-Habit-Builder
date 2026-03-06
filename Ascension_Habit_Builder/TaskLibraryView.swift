//
//  TaskLibraryView.swift
//  Ascension_Habit_Builder
//
//  Created by Luke Downie on 3/5/26.
//

import SwiftUI
import SwiftData

struct TaskLibraryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Task.sortOrder) private var tasks: [Task]
    
    @State private var showAddTaskSheet = false
    
    /// When true, the add task sheet opens automatically when the view appears.
    var openAddTaskOnAppear: Bool = false
    
    var body: some View {
        ZStack {
            AscensionColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(AscensionColors.primary)
                            .frame(width: 40, height: 40)
                            .background(AscensionColors.dateSelectorBackground)
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text("Task Library")
                        .font(.system(size: 25, weight: .bold))
                        .foregroundStyle(AscensionColors.primary)
                    
                    Spacer()
                    
                    Button(action: { showAddTaskSheet = true }) {
                        ZStack {
                            Circle()
                                .fill(AscensionColors.completedButton)
                                .frame(width: 40, height: 40)
                                .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
                            
                            Image(systemName: "plus")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 24)
                
                // Content
                List {
                    ForEach(tasks) { task in
                        TaskLibraryRow(prompt: task.prompt)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                    }
                    .onDelete(perform: deleteTasks)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .scrollIndicators(.hidden)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            if openAddTaskOnAppear {
                showAddTaskSheet = true
            }
        }
        .sheet(isPresented: $showAddTaskSheet) {
            AddTaskSheet(
                onAdd: { prompt in
                    let newTask = Task(prompt: prompt, sortOrder: tasks.count)
                    modelContext.insert(newTask)
                    showAddTaskSheet = false
                },
                onDismiss: { showAddTaskSheet = false }
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }
    
    private func deleteTasks(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(tasks[index])
        }
    }
}

private struct AddTaskSheet: View {
    @State private var promptText = ""
    @FocusState private var isTextFieldFocused: Bool
    
    let onAdd: (String) -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Add Task")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(AscensionColors.primary)
                .padding(.top, 24)
            
            TextField("Enter your task...", text: $promptText, axis: .vertical)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(AscensionColors.primary)
                .padding(16)
                .background(AscensionColors.dateSelectorBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .lineLimit(3...6)
                .focused($isTextFieldFocused)
                .padding(.horizontal, 20)
            
            HStack(spacing: 12) {
                Button(action: onDismiss) {
                    Text("Cancel")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AscensionColors.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AscensionColors.dateSelectorBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain)
                
                Button(action: {
                    let trimmed = promptText.trimmingCharacters(in: .whitespacesAndNewlines)
                    if !trimmed.isEmpty {
                        onAdd(trimmed)
                    }
                }) {
                    Text("Add")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            promptText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                ? AscensionColors.secondary.opacity(0.5)
                                : AscensionColors.completedButton
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain)
                .disabled(promptText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .background(AscensionColors.background)
        .onAppear {
            isTextFieldFocused = true
        }
    }
}

private struct TaskLibraryRow: View {
    let prompt: String
    
    var body: some View {
        HStack(spacing: 16) {
            Text(prompt)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(AscensionColors.primary)
                .multilineTextAlignment(.leading)
            
            Spacer(minLength: 0)
        }
        .padding(16)
        .background(AscensionColors.dateSelectorBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    TaskLibraryView()
        .modelContainer(for: Task.self, inMemory: true)
}
