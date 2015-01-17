# flexsql
flexible structure for sql database to build hirarchy, permissions and various items

#init system
sqlite3 flexsql.db < term.sql 
sqlite3 flexsql.db < item.sql
sqlite3 flexsql.db < term_item.sql

chmod +x flexsearch.sh

#usage
flexsearch.sh [parameter] [tags]

#test

./flexsearch.sh -f name -s test-exam

or in verbose mode
./flexsearch.sh -v -f name -s test-exam
