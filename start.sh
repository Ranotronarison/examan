#!/bin/bash

# Array of submodule configurations: "folder_name:repository_url"
SUBMODULES=(
  "examan-api:git@github.com:Ranotronarison/examan-api.git"
  "examan-front:git@github.com:Ranotronarison/examan-front.git"
)

# Function to clone or update submodules
setup_submodules() {
  for submodule in "${SUBMODULES[@]}"; do
    IFS=':' read -r folder_name repo_url <<< "$submodule"
    
    if [ ! -d "./$folder_name" ] || [ -z "$(ls -A ./$folder_name)" ]; then
      echo "Cloning $folder_name repository..."
      git clone "$repo_url" && git submodule update --init --recursive
    else
      echo "$folder_name repository already exists. Skipping clone."
    fi
  done
}

# Setup all submodules
setup_submodules

# Make sure all submodules are initialized and updated
echo "Updating all submodules..."
for submodule in "${SUBMODULES[@]}"; do
  IFS=':' read -r folder_name repo_url <<< "$submodule"
  git submodule update --remote "$folder_name"
done

# run docker compose
docker compose up -d --wait

# run composer install in examan-api
docker compose exec -it examan-api composer install
