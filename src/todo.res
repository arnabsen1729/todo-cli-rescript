/*
Sample JS implementation of Todo CLI that you can attempt to port:
https://gist.github.com/jasim/99c7b54431c64c0502cfe6f677512a87
*/

/* Returns date with the format: 2021-02-04 */
let getToday: unit => string = %raw(`
function() {
  let date = new Date();
  return new Date(date.getTime())
    .toISOString()
    .split("T")[0];
}
  `)

type fsConfig = {encoding: string, flag: string}

/* https://nodejs.org/api/fs.html#fs_fs_existssync_path */
@bs.module("fs") external existsSync: string => bool = "existsSync"

/* https://nodejs.org/api/fs.html#fs_fs_readfilesync_path_options */
@bs.module("fs")
external readFileSync: (string, fsConfig) => string = "readFileSync"

/* https://nodejs.org/api/fs.html#fs_fs_writefilesync_file_data_options */
@bs.module("fs")
external appendFileSync: (string, string, fsConfig) => unit = "appendFileSync"

@bs.module("fs")
external writeFileSync: (string, string, fsConfig) => unit = "writeFileSync"

/* https://nodejs.org/api/os.html#os_os_eol */
@bs.module("os") external eol: string = "EOL"

let encoding = "utf8"

/*
NOTE: The code below is provided just to show you how to use the
date and file functions defined above. Remove it to begin your implementation.
*/

let pendingTodosFile = "todo.txt"
let completedTodosFile = "done.txt"

let help = Js.String.trim(`Usage :-
$ ./todo add "todo item"  # Add a new todo
$ ./todo ls               # Show remaining todos
$ ./todo del NUMBER       # Delete a todo
$ ./todo done NUMBER      # Complete a todo
$ ./todo help             # Show usage
$ ./todo report           # Statistics`)

// Remove empty strings from an array of strings.
let removeEmpty = (lines: array<string>): array<string> => {
  Belt.Array.keep(lines, line => Js.String.length(line) != 0)
}

// Read a file and return the contents separated by eol.
let readTodos = (filename: string): array<string> => {
  if existsSync(filename) {
    let rawTodos = Js.String.split(eol, readFileSync(filename, {encoding: encoding, flag: "r"}))
    removeEmpty(rawTodos)
  } else {
    writeFileSync(filename, "", {encoding: encoding, flag: "w"})
    []
  }
}

// Write an array of strings joined with eol on the file.
let writeTodos = (filename: string, todos: array<string>): unit => {
  let todoText = Js.Array.joinWith(eol, todos)
  writeFileSync(filename, todoText, {encoding: encoding, flag: "w"})
}

// Update the file using the provided updater function.
let updateFile = (filename: string, updater) => {
  let contents = readTodos(filename)
  writeTodos(filename, updater(contents))
}

// Append a line to the end of the file.
let appendTodos = (filename: string, todo) => {
  appendFileSync(filename, todo ++ eol, {encoding: encoding, flag: "a"})
}

// Delete an item from an array equivalent to slice.
let deleteItem = (arr, delIndex) => {
  Belt.Array.reduceWithIndex(arr, [], (acc, element, index) => {
    if index != delIndex {
      Js.Array.concat(acc, [element])
    } else {
      acc
    }
  })
}

/* COMMAND SPECIFIC FUNCTIONS */

// List all the pending todos
let cmdLs = () => {
  let todos = readTodos(pendingTodosFile)
  if Js.Array.length(todos) == 0 {
    Js.log("There are no pending todos!")
  } else {
    let parsedTodos =
      Belt.Array.mapWithIndex(todos, (index, todo) =>
        `[${Belt.Int.toString(index + 1)}] ${todo}`
      )->Belt.Array.reverse
    Js.Array.joinWith(eol, parsedTodos)->Js.log
  }
}

// Add a todo
let cmdAddTodo = (newTodos: array<string>) => {
  if Belt.Array.length(newTodos) == 0 {
    Js.log("Error: Missing todo string. Nothing added!")
  } else {
    updateFile(pendingTodosFile, todos => Belt.Array.concat(todos, newTodos))
    Js.log(`Added todo: "${Js.Array.joinWith(`","`, newTodos)}"`)
  }
}

// Delete a todo
let cmdDelTodo = (todoIds: array<string>) => {
  if Belt.Array.length(todoIds) == 0 {
    Js.log(`Error: Missing NUMBER for deleting todo.`)
  } else {
    Belt.Array.forEach(todoIds, id => {
      let number = Belt.Int.fromString(id)
      switch number {
      | Some(x) =>
        updateFile(pendingTodosFile, todos => {
          if x < 1 || x > Belt.Array.length(todos) {
            Js.log(`Error: todo #${Belt.Int.toString(x)} does not exist. Nothing deleted.`)
            todos
          } else {
            Js.log(`Deleted todo #${Belt.Int.toString(x)}`)
            deleteItem(todos, x - 1)
          }
        })
      | None => Js.log(`Error: todo #${id} does not exist. Nothing deleted.`)
      }
    })
  }
}

// Mark a todo as done
let cmdDoneTodo = (todoIds: array<string>) => {
  if Belt.Array.length(todoIds) == 0 {
    Js.log("Error: Missing NUMBER for marking todo as done.")
  } else {
    Belt.Array.forEach(todoIds, id => {
      let number = Belt.Int.fromString(id)
      switch number {
      | Some(x) => {
          let todos = readTodos(pendingTodosFile)
          if x < 1 || x > Belt.Array.length(todos) {
            Js.log(`Error: todo #${Belt.Int.toString(x)} does not exist.`)
          } else {
            let completedTodo = todos[x - 1]
            writeTodos(pendingTodosFile, deleteItem(todos, x - 1))
            appendTodos(completedTodosFile, completedTodo)
            Js.log(`Marked todo #${Belt.Int.toString(x)} as done.`)
          }
        }
      | None => Js.log(`Error: todo #${id} does not exist. `)
      }
    })
  }
}

// Give a Report of all todos
let cmdReport = () => {
  let pending = Belt.Array.length(readTodos(pendingTodosFile))
  let completed = Belt.Array.length(readTodos(completedTodosFile))
  Js.log(
    `${getToday()} Pending : ${Belt.Int.toString(pending)} Completed : ${Belt.Int.toString(
        completed,
      )}`,
  )
}

// Display Help
let cmdHelp = () => Js.log(help)

/* MAIN PROGRAM STARTS */

let argv = %raw(`process.argv`)
let argc = Belt.Array.length(argv)

if argc <= 2 {
  Js.log(help)
} else {
  let command = argv[2]
  let args = argc > 3 ? Belt.Array.sliceToEnd(argv, 3) : []
  switch command {
  | "ls" => cmdLs()
  | "add" => cmdAddTodo(args)
  | "del" => cmdDelTodo(args)
  | "done" => cmdDoneTodo(args)
  | "report" => cmdReport()
  | _ => cmdHelp()
  }
}
