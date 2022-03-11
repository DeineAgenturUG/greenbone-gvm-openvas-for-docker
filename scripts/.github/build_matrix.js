const fs = require('fs');

let matrix_prepared = {
  BUILD_NAME: ["DEFAULT", "PDF Included", "With Data", "With Data With PDF Included"],
  BUILD_SUFFIX: ["", "-full", "-data", "-data-full"],
  BUILD_ARGS: ["SETUP=0\n", "SETUP=0\nOPT_PDF=1\n", "SETUP=1\n", "SETUP=1\nOPT_PDF=1\n"]
}
let matrix_output = {}
let latest_version


try {
  latest_version = fs.readFileSync('./.checkupdates/latest_version', 'utf8');
  console.log(latest_version);
} catch (e) {
  console.log('Error:', e.stack);
}

matrix_output = JSON.parse(JSON.stringify(matrix_prepared))
matrix_prepared.BUILD_ARGS.forEach((value, index) => {
  matrix_output.BUILD_ARGS[index] = latest_version + value
})

console.log(matrix_output)
