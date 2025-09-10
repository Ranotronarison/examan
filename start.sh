#!/bin/bash

if [ ! -d "./examan-api" ] || [ -z "$(ls -A ./examan-api)" ]; then
  echo "Cloning examan-api repository..."
  git clone git@github.com:Ranotronarison/examan-api.git && git submodule update --init --recursive
else
  echo "examan-api repository already exists. Skipping clone."
fi

# make sure all submodules are initialized and updated
git submodule update --remote examan-api

# run docker compose
docker compose up -d --build --wait

# run composer install in examan-api
docker compose exec -it examan-api composer install