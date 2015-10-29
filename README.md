# flexsql

The aim of this project is to find one approach with logical principles of computer science 
to insert and search data in a flexible structure with hirarchy.

The current way is a combined multiple recursive search.

1. Step: building a prototype only to show how the principle could work
2. Step: compare hirarchical structure ideas and database systems (sql,nosql,...) to find best practice 
3. Step: try to include in other opensource projects

##init system
sqlite3 flexsql.db < term.sql 
sqlite3 flexsql.db < item.sql
sqlite3 flexsql.db < term_item.sql

chmod +x flexsearch.sh

##usage
flexsearch.sh [parameter] [tags]

##test

 ./flexsearch.sh -f name -s test-exam written english science

or in verbose mode

 ./flexsearch.sh -v -f name -s test-exam written english science

r
73

t
22

