# SQL_stored-procedure_TRIGGERS
A stored procedure is a precompiled set of one or more SQL statements saved and stored directly on the database server

1. Basic Syntax
Creating a procedure requires changing the default semicolon delimiter temporarily so that the server doesn't execute the individual statements inside the procedure block prematurely. 

DELIMITER //

CREATE PROCEDURE procedure_name()
BEGIN
    -- SQL statements go here
    SELECT * FROM table_name;
END //

DELIMITER ;
DELIMITER: Changes the statement terminator from ; to //.
BEGIN...END: Defines the body of the procedure. 

## SQL_TRIGGERS
In MySQL, a trigger is a specialized stored program that executes automatically in response to a specific event on a permanent table, such as an INSERT, UPDATE, or DELETE. 
Basic Syntax
To create a trigger, use the CREATE TRIGGER statement. When writing multiple statements in a trigger body, you must use a custom delimiter (like $$) so the ; within the code doesn't terminate the creation command prematurely. 

DELIMITER $$

CREATE TRIGGER trigger_name
{BEFORE | AFTER} {INSERT | UPDATE | DELETE}
ON table_name FOR EACH ROW
BEGIN
    -- SQL logic here
    IF NEW.amount < 0 THEN
        SET NEW.amount = 0;
    END IF;
END $$

DELIMITER ;

