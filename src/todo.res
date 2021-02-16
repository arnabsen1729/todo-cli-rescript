let pendingTodosFile = "todo.txt"
let completedTodosFile = "done.txt"

let help = Js.String.trim(`Usage :-
$ ./todo add "todo item"  # Add a new todo
$ ./todo ls               # Show remaining todos
$ ./todo del NUMBER       # Delete a todo
$ ./todo done NUMBER      # Complete a todo
$ ./todo help             # Show usage
$ ./todo report           # Statistics`)

/* MAIN PROGRAM STARTS */

let argv = %raw(`process.argv`)
let argc = Belt.Array.length(argv)

if argc <= 2 {
  Js.log(help)
} else {
  let command = argv[2]
  let args = argc > 3 ? Belt.Array.sliceToEnd(argv, 3) : []
  switch command {
  | "ls" => Commands.cmdLs(pendingTodosFile)
  | "add" => Commands.cmdAddTodo(~newTodos=args, ~pendingTodosFile)
  | "del" => Commands.cmdDelTodo(~todoIds=args, ~pendingTodosFile)
  | "done" => Commands.cmdDoneTodo(~todoIds=args, ~pendingTodosFile, ~completedTodosFile)
  | "report" => Commands.cmdReport(~pendingTodosFile, ~completedTodosFile)
  | _ => Commands.cmdHelp(help)
  }
}
