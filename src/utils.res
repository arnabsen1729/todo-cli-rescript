/* UTILITY FUNCTIONS */

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

// Returns date with the format: 2021-02-04
let getToday: unit => string = %raw(`
function() {
  let date = new Date();
  return new Date(date.getTime())
    .toISOString()
    .split("T")[0];
}
  `)
