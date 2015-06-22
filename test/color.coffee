chalk = require "chalk"

console.log "
  #{chalk.black "black"}
  #{chalk.red "red"}
  #{chalk.green "green"}
  #{chalk.yellow "yellow"}
  #{chalk.blue "blue"}
  #{chalk.magenta "magenta"}
  #{chalk.cyan "cyan"}
  #{chalk.white "white"}
  #{chalk.gray "gray"}
"

for i in [30..110]
  console.log "\x1b[#{i}m #{i}\x1b[0m"

