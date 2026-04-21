#!/usr/bin/env bash

find_nearest_csproj() {
    local dir=$1
    while [[ "$dir" != "/" ]]; do
        csproj=$(fd -e csproj . "$dir" --max-depth 1)
        if [[ -n "$csproj" ]]; then
            echo "$csproj"
            return 0
        fi

        dir=$(dirname "$dir")
    done

    return 1
}

find_all_csproj_from_nearest_solution() {
    local dir=$1
    while [[ "$dir" != "/" ]]; do
        sln=$(fd -e .sln . "$dir" --max-depth 1)
        # if there is a solution file present, look at a further depth to find all csprojs.
        if [[ -n "$sln" ]]; then
            csprojs=$(fd -e csproj . "$dir")
            echo "$csprojs"
            return 0
        fi

        dir=$(dirname "$dir")
    done

    return 1
}

add_dotnet_reference() {
    local dir=$PWD
    local csprojs_in_sln=$(find_all_csproj_from_nearest_solution "$dir")
    if [[ -z $csprojs_in_sln ]]; then
        echo "Could not find any solution file"
        return 1
    fi

    local target_csproj=$(find_nearest_csproj "$dir")
    # Check whether target csproj is empty, if it is, then pick one from the ones found for the solution.
    if [[ -z $target_csproj ]]; then
        target_csproj=$(echo "$csprojs_in_sln" |
            awk -F/ '{print $NF "\t" $0}' |
            fzf --prompt "Multiple projects found, pick one to add a reference to:" --with-nth=1 --delimiter=$'\t' |
            cut -f2)

        if [[ -z $target_csproj ]]; then
            echo "No project selected, terminating..."
            return 1
        fi
    fi

    # Filter target away, since we shouldn't add a reference to itself.
    local csprojs_for_selection=$(echo "$csprojs_in_sln" | grep -vFx "$target_csproj")
    if [[ -z $csprojs_for_selection ]]; then
        echo "Found no other project"
        return 1
    fi

    local selected=$(echo "$csprojs_for_selection" |
        awk -F/ '{print $NF "\t" $0}' |
        fzf --multi --prompt "Select project(s) to add as references" --with-nth=1 --delimiter=$'\t' |
        cut -f2)

    if [[ -z $selected ]]; then
        echo "No projects selected as references"
        return 1
    fi

    while IFS= read -r proj; do
        dotnet reference add $proj --project $target_csproj
    done <<<"$selected"
}

remove_dotnet_reference() {
    local dir=$PWD

    local target_csproj=$(find_nearest_csproj "$dir")
    # If we do not find any target csproj, then look for csprojs in solution and present these using fzf.
    if [[ -z $target_csproj ]]; then
        local csprojs_in_sln=$(find_all_csproj_from_nearest_solution "$dir")
        if [[ -z $csprojs_in_sln ]]; then
            echo "Could not find any project file(s)"
            return 1
        fi

        target_csproj=$(echo "$csprojs_in_sln" |
            awk -F/ '{print $NF "\t" $0}' |
            fzf --prompt "Multiple projects found, pick one to remove a reference from:" --with-nth=1 --delimiter=$'\t' |
            cut -f2)

        if [[ -z $target_csproj ]]; then
            echo "No project selected, terminating..."
            return 1
        fi
    fi

    local references_for_target=$(dotnet reference list --project $target_csproj | tail -n +3)

    local selected=$(echo "$references_for_target" |
        awk -F/ '{print $NF "\t" $0}' |
        fzf --multi --prompt "Select reference(s) to remove" --with-nth=1 --delimiter=$'\t' |
        cut -f2)

    if [[ -z $selected ]]; then
        echo "No references selected to remove"
        return 1
    fi

    while IFS= read -r proj; do
        dotnet reference remove $proj --project $target_csproj
    done <<<"$selected"
}

alias dra=add_dotnet_reference
alias drr=remove_dotnet_reference
