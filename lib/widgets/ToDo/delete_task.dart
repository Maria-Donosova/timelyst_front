List tasks = ['task', 'task1', 'task2'];

void deleteTask(String id) {
  tasks.removeWhere((tasks) => tasks.id == id);
}

String removeTask() {
  return """
  mutation removeTask(\$id: String!){
    removeTask(id: \$id) {
      task_description
    }
  }
  """;
}
