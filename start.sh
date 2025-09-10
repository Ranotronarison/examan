#!/bin/bash

# check if the examan api repository exists
if [ ! -d "./examan-api" ]; then
  echo "Cloning examan-api repository..."
  git clone git@github.com:Ranotronarison/examan-api.git
else
  echo "examan-api repository already exists. Skipping clone."
fi

# run docker compose
docker compose up -d --build