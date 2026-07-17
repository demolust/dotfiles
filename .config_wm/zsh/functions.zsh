################################### USER FUNCTIONS ##################################
### Function that calls cd, and immediately list its contents
function cs {
  cd "$@" && ls -A
}

function lazygp {
  git pull
  git add .
  git commit -m "$@"
  git push
}
