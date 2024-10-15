#!/bin/bash

# Check if an argument is provided
if [[ -z $1 ]]; then
  echo "Please provide an element as an argument."
  exit 
fi

# Query to fetch element details based on atomic number, symbol, or name
ELEMENT=$(psql -U postgres -d periodic_table -t -c \
"SELECT TRIM(atomic_number::text), 
        TRIM(name), 
        TRIM(symbol), 
        TRIM(type), 
        TRIM(atomic_mass::text), 
        TRIM(melting_point_celsius::text), 
        TRIM(boiling_point_celsius::text)
FROM elements 
INNER JOIN properties USING (atomic_number) 
INNER JOIN types USING (type_id) 
WHERE atomic_number::text = '$1' OR symbol = '$1' OR name = '$1';")

# Check if the element was found
if [[ -z $ELEMENT ]]; then
  echo "I could not find that element in the database."
else
  # Format the output to match the required specifications
  IFS='|' read -r atomic_number name symbol type atomic_mass melting_point boiling_point <<< "$ELEMENT"

  # Clean up spaces before output
  atomic_number=$(echo $atomic_number | xargs)
  name=$(echo $name | xargs)
  symbol=$(echo $symbol | xargs)
  type=$(echo $type | xargs)
  atomic_mass=$(echo $atomic_mass | xargs)
  melting_point=$(echo $melting_point | xargs)
  boiling_point=$(echo $boiling_point | xargs)

  echo "The element with atomic number $atomic_number is $name ($symbol). It's a $type, with a mass of $atomic_mass amu. $name has a melting point of $melting_point celsius and a boiling point of $boiling_point celsius."
fi
