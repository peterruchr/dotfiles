#!/usr/bin/env bash

dotnet_add_package() {
    # Find nearest csproj
    # If nearest csproj cannot be found attempt to find the solution
    # if solution cannot be found, fail.
    # Present the user with options to pick the multiple projects, if solution was found.
    # Now start a package search using dotnet package search, get it back in json.
    # Was the package has been found, add it to the project(s).
    # Done
}

dotnet_remove_package() {
    # Find nearest csproj
    # If nearest csproj cannot be found attempt to find the solution
    # if solution cannot be found, fail.
    # Present the user with options to pick the multiple projects, if solution was found.
    # Some consideration here, should we allow multiple projects? It will significantly complicate matters, though possible.
    # Display added packages for project(s)
    # Remove it from the project(s).
    # Done
}

dotnet_update_package() {
    # Find nearest csproj
    # If nearest csproj cannot be found attempt to find the solution
    # if solution cannot be found, fail.
    # Present the user with options to pick the multiple projects, if solution was found.
    # Some consideration here, should we allow multiple projects? It will significantly complicate matters, though possible.
    # Display outdated packages for project(s) allow user to select multiple
    # Update packages for the project(s).
    # Done
}
