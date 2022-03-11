const fs = require('fs');

let matrix_prepared = {
  BUILD_NAME: ["DEFAULT", "PDF Included", "With Data", "With Data With PDF Included"],
  BUILD_SUFFIX: ["", "-full", "-data", "-data-full"],
  BUILD_ARGS: ["SETUP=0\n", "SETUP=0\nOPT_PDF=1\n", "SETUP=1\n", "SETUP=1\nOPT_PDF=1\n"]
}
let matrix_output = {include:[]}
let latest_version


try {
  latest_version = fs.readFileSync('./.checkupdates/latest_version', 'utf8');
} catch (e) {
  process.exit(1)
}

matrix_prepared.BUILD_ARGS.forEach((value, index) => {
  matrix_output.include[index] = {
    BUILD_NAME:matrix_prepared.BUILD_NAME[index],
    BUILD_SUFFIX:matrix_prepared.BUILD_SUFFIX[index],
    BUILD_ARGS:latest_version + value,
  }
})

console.log(JSON.stringify(matrix_output))
