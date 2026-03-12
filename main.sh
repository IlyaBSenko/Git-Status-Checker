#!/bin/bash

# patterns:
# ^\?\?  == untracked
# ^.[^ ] == unstaged
# ^[^ ]  == staged but uncommited


search_dir="$1" # command line argument for the path to search for

# if search_dir is empty
if [ -z "$search_dir" ]; then
	echo "Usage: bash main.sh <directory>"
	exit 1
fi

# find directories that are git repos 
find_repos() {
	find "$search_dir" -type d -name .git 
}

# untracked files only
untracked() {
	find_repos | while read -r gitdir; do
		repo="${gitdir%/.git}"
		if git -C "$repo" status --porcelain | grep -qE '^\?\?'; then
			echo "$repo has untracked files"
		fi
	done
} 

# unadded files only
unstaged() {
	find_repos | while read -r gitdir; do
		repo="${gitdir%/.git}"
		if ! git -C "$repo" diff --quiet; then # now checks for actual unstaged changes directly
			echo "$repo has unadded files"
		fi
	done
}

# uncommited files only 
uncommitted() {
	find_repos | while read -r gitdir; do
		repo="${gitdir%/.git}"
		if git -C "$repo" status --porcelain | grep -qE '^[^ ?]'; then # ?? technically matches so we need to eclude untracked files
			echo "$repo has uncommitted files"
		fi
	done
}


untracked
unstaged
uncommitted
