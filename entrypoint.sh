#!/bin/bash
# Docker entrypoint script.

# Create, migrate, and seed database if it doesn't exist.
mix ecto.create
mix ecto.migrate
mix run priv/repo/seeds.exs

exec mix phx.server
