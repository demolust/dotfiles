### Source all other files

RESOURCES_DIR="${0:A:h}"

for file in "$RESOURCES_DIR"/*.zsh(N.); do
  # (N.): Zsh glob qualifier
  #  N -> sets NULL_GLOB (prevents error if no files found)
  #  . -> matches only regular files (skips directories)
  # Skip the main loader script if it lives in the same folder
  [[ "$file" == "${0:A}" ]] && continue
  source "$file"
done
