List tasks = ['task', 'task1', 'task2'];

var isDone = false;

void doneTask(String id) {
  tasks.removeWhere((tasks) => tasks.id == id);
  tasks.where((tasks) => tasks.id == id);
  isDone = true;
}

//backend: schema & method should be updated & developed
// String markCompleteTask() {
//   return """
//   mutation markCompelte(\$id: String!){
//     markCompelte(id: \$id) {
//       status
//     }
//   }
//   """;
// }
