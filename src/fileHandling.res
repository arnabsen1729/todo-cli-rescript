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

/* FILE HANDLING */

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
