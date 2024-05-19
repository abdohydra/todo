#!/bin/bash

TASKS_FILE="abdellahtasks.json"

function load_tasks {
    if [[ ! -f $TASKS_FILE ]]; then
        echo "[]" > $TASKS_FILE
    fi
}


function create_task {
    load_tasks
    id=$(jq 'map(.id) | max + 1' $TASKS_FILE)
    [[ $id == null ]] && id=1
    task=$(jq -n \
        --arg id "$id" \
        --arg title "$1" \
        --arg description "$2" \
        --arg location "$3" \
        --arg due_date "$4" \
        '{
            id: $id | tonumber,
            title: $title,
            description: $description,
            location: $location,
            due_date: $due_date,
            completed: false
        }')
    jq --argjson task "$task" '. += [$task]' $TASKS_FILE > temp.json && mv temp.json $TASKS_FILE
    echo "Task '$1' created."
}

function update_task {
    load_tasks
    id=$1
    task=$(jq --arg id "$id" 'map(select(.id == ($id | tonumber))) | .[0]' $TASKS_FILE)
    if [[ $task == null ]]; then
        echo "No task found with ID $id." >&2
        return
    fi
    title=$(echo $task | jq -r '.title')
    description=$(echo $task | jq -r '.description')
    location=$(echo $task | jq -r '.location')
    due_date=$(echo $task | jq -r '.due_date')
    completed=$(echo $task | jq -r '.completed')
    
    new_title=${2:-$title}
    new_description=${3:-$description}
    new_location=${4:-$location}
    new_due_date=${5:-$due_date}
    new_completed=${6:-$completed}

    jq --arg id "$id" \
       --arg title "$new_title" \
       --arg description "$new_description" \
       --arg location "$new_location" \
       --arg due_date "$new_due_date" \
       --arg completed "$new_completed" \
       'map(if .id == ($id | tonumber) then 
            .title = $title | 
            .description = $description | 
            .location = $location | 
            .due_date = $due_date | 
            .completed = ($completed | test("true")) 
          else . end)' $TASKS_FILE > temp.json && mv temp.json $TASKS_FILE
    echo "Task with ID $id updated."
}

function delete_task {
    load_tasks
    id=$1
    task=$(jq --arg id "$id" 'map(select(.id == ($id | tonumber))) | .[0]' $TASKS_FILE)
    if [[ $task == null ]]; then
        echo "No task found with ID $id." >&2
        return 1
    fi
    jq --arg id "$id" 'map(select(.id != ($id | tonumber)))' $TASKS_FILE > temp.json && mv temp.json $TASKS_FILE
    echo "Task with ID $id deleted."
}


function show_task {
    load_tasks
    id=$1
    task=$(jq --arg id "$id" 'map(select(.id == ($id | tonumber))) | .[0]' $TASKS_FILE)
    if [[ $task == null ]]; then
        echo "No task found with ID $id." >&2
        return
    fi
    echo $task | jq
}

function list_tasks {
    load_tasks
    date_str=${1:-$(date +%Y-%m-%d)}
    tasks=$(jq --arg date_str "$date_str" '[.[] | select(.due_date | startswith($date_str))]' $TASKS_FILE)
    completed=$(echo $tasks | jq '[.[] | select(.completed == true)]')
    uncompleted=$(echo $tasks | jq '[.[] | select(.completed == false)]')

    echo "Completed tasks:"
    echo $completed | jq

    echo -e "\nUncompleted tasks:"
    echo $uncompleted | jq
}

function search_task {
    load_tasks
    title=$1
    tasks=$(jq --arg title "$title" '[.[] | select(.title | test($title; "i"))]' $TASKS_FILE)
    echo $tasks | jq
}

if [[ $# -eq 0 ]]; then
    list_tasks
else
    case $1 in
        create)
            shift
            if [[ $# -lt 2 ]]; then
                echo "Usage: $0 create <title> <due_date> [description] [location]" >&2
                exit 1
            fi
            create_task "$1" "${3:-}" "${4:-}" "$2"
            ;;
        update)
            shift
            if [[ $# -lt 1 ]]; then
                echo "Usage: $0 update <id> [title] [description] [location] [due_date] [completed]" >&2
                exit 1
            fi
            update_task "$@"
            ;;
        delete)
            shift
            if [[ $# -lt 1 ]]; then
                echo "Usage: $0 delete <id>" >&2
                exit 1
            fi
            delete_task "$1"
            ;;
        show)
            shift
            if [[ $# -lt 1 ]]; then
                echo "Usage: $0 show <id>" >&2
                exit 1
            fi
            show_task "$1"
            ;;
        list)
            shift
            list_tasks "$1"
            ;;
        search)
            shift
            if [[ $# -lt 1 ]]; then
                echo "Usage: $0 search <title>" >&2
                exit 1
            fi
            search_task "$1"
            ;;
        *)
            echo "Unknown command: $1" >&2
            exit 1
            ;;
    esac
fi

