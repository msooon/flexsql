# flexsql
flexible structure for sql database to build hirarchy, permissions and various items

#init system
sqlite3 flexsql.db < term.sql 
sqlite3 flexsql.db < item.sql
sqlite3 flexsql.db < term_item.sql

chmod +x flexsearch.sh

#test

./flexsearch.sh name test-exam

or in verbose mode

./flexsearch.sh -v name test-exam 
