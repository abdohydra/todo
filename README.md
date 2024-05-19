# todo
project submission of the course "System Programming and Administration"
This  todo.sh script is a tool for managing a list of todo tasks. Each task has a unique identifier, a title, a description, a location, a due date and time, and a completion marker. The script provides functionalities to create, update, delete, show, list, and search for tasks.
How data is stored: Tasks are stored in a JSON file abdellahtasks.json
Each task is represented as a JSON object with the following structure:
  json
  {
      "id": 1,
      "title": "Solving NP vs P ",
      "description": "np == p or p != np ? ",
      "location": "in my room ",
      "due_date": "202?-??-?? 03:00",
      "completed": false
  }
   The script relies on jq for JSON processing. Ensure jq is installed on your system :)
   jq IS MAGICAL I like it :) 
   JSON files are interesting too 
   HOW TO RUN THE PROGRAM / 
  ./todo.sh create title due_date description location
  ./todo.sh update id title description location due_date completed
  ./todo.sh delete id
  ./todo.sh show id
  ./todo.sh list date
  ./todo.sh search title
  ./todo.sh # for today's tasks 
Notes / 
Ensure abdellahtasks.json exists in the same directory as the script, or it will be created automatically peace :)
   




