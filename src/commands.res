/* COMMAND SPECIFIC FUNCTIONS */

// List all the pending todos
let cmdLs = pendingTodosFile => {
  let todos = FileHandling.readTodos(pendingTodosFile)
  if Js.Array.length(todos) == 0 {
    Js.log("There are no pending todos!")
  } else {
    let parsedTodos =
      Belt.Array.mapWithIndex(todos, (index, todo) =>
        `[${Belt.Int.toString(index + 1)}] ${todo}`
      )->Belt.Array.reverse
    Js.Array.joinWith(FileHandling.eol, parsedTodos)->Js.log
  }
}

// Add a todo
let cmdAddTodo = (~newTodos, ~pendingTodosFile) => {
  if Belt.Array.length(newTodos) == 0 {
    Js.log("Error: Missing todo string. Nothing added!")
  } else {
    FileHandling.updateFile(pendingTodosFile, todos => Belt.Array.concat(todos, newTodos))
    Js.log(`Added todo: "${Js.Array.joinWith(`","`, newTodos)}"`)
  }
}

// Delete a todo
let cmdDelTodo = (~todoIds, ~pendingTodosFile) => {
  if Belt.Array.length(todoIds) == 0 {
    Js.log(`Error: Missing NUMBER for deleting todo.`)
  } else {
    Belt.Array.forEach(todoIds, id => {
      let number = Belt.Int.fromString(id)
      switch number {
      | Some(x) =>
        FileHandling.updateFile(pendingTodosFile, todos => {
          if x < 1 || x > Belt.Array.length(todos) {
            Js.log(`Error: todo #${Belt.Int.toString(x)} does not exist. Nothing deleted.`)
            todos
          } else {
            Js.log(`Deleted todo #${Belt.Int.toString(x)}`)
            Utils.deleteItem(todos, x - 1)
          }
        })
      | None => Js.log(`Error: todo #${id} does not exist. Nothing deleted.`)
      }
    })
  }
}

// Mark a todo as done
let cmdDoneTodo = (~todoIds, ~pendingTodosFile, ~completedTodosFile) => {
  if Belt.Array.length(todoIds) == 0 {
    Js.log("Error: Missing NUMBER for marking todo as done.")
  } else {
    Belt.Array.forEach(todoIds, id => {
      let number = Belt.Int.fromString(id)
      switch number {
      | Some(x) => {
          let todos = FileHandling.readTodos(pendingTodosFile)
          if x < 1 || x > Belt.Array.length(todos) {
            Js.log(`Error: todo #${Belt.Int.toString(x)} does not exist.`)
          } else {
            let completedTodo = todos[x - 1]
            FileHandling.writeTodos(pendingTodosFile, Utils.deleteItem(todos, x - 1))
            FileHandling.appendTodos(completedTodosFile, completedTodo)
            Js.log(`Marked todo #${Belt.Int.toString(x)} as done.`)
          }
        }
      | None => Js.log(`Error: todo #${id} does not exist. `)
      }
    })
  }
}

// Give a Report of all todos
let cmdReport = (~pendingTodosFile, ~completedTodosFile) => {
  let pending = Belt.Array.length(FileHandling.readTodos(pendingTodosFile))
  let completed = Belt.Array.length(FileHandling.readTodos(completedTodosFile))
  Js.log(
    `${Utils.getToday()} Pending : ${Belt.Int.toString(pending)} Completed : ${Belt.Int.toString(
        completed,
      )}`,
  )
}

// Display Help
let cmdHelp = help => Js.log(help)
