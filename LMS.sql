-- Library Management System -- 
-- Project Task --
 
-- Task 1. Create a New Book Record -- "978-1-60129-456-2',
 -- 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee',
--  'J.B. Lippincott & Co.')"

insert into books
(isbn,book_title, category,rental_price,`status`, author, publisher)
values
("978-1-60129-456-2",
  "To Kill a Mockingbird", "Classic", 6.00, "yes", "Harper Lee",
  "J.B. Lippincott & Co.");
SELECT 
    *
FROM
    books;
    
-- Task 2: Update an Existing Member's Address-- 

UPDATE members 
SET 
    member_address = '124 main'
WHERE
    member_id = 'C101';

SET SQL_SAFE_UPDATES = 1;
SET SQL_SAFE_UPDATES = 0;

-- Delete a Record from the Issued Status Table 
-- -- Objective: Delete the 
-- record with issued_id = 'IS121' from the issued_status table

DELETE FROM issued_status 
WHERE
    issued_id = 'IS121';
    
-- Task 4: Retrieve All Books Issued by a Specific Employee 
-- Objective: Select all books issued by the employee with emp_id = 'E101'.

SELECT 
    *
FROM
    issued_status
WHERE
    issued_emp_id = 'E101';
    
-- Task 5: List Members Who Have Issued More Than One Book 
-- Objective: Use GROUP BY to find members who have issued more than one book.
SELECT 
    issued_emp_id, COUNT(*) as total_book_issued
FROM
    issued_status
GROUP BY 1
HAVING COUNT(*) > 1;

-- Task 6: Create Summary Tables: Used CTAS to generate new tables based 
-- on query results each book and total book_issued_cnt**
CREATE TABLE no_issued AS (SELECT b.isbn, b.book_title, COUNT(s.issued_id) AS no_issued FROM
    books AS b
        JOIN
    issued_status AS s ON b.isbn = s.issued_book_isbn
GROUP BY 1 , 2);

-- Task 7. Retrieve All Books in a Specific Category:
SELECT 
    *
FROM
    books
WHERE
    category = 'Classic';
    
-- Task 8: Find Total Rental Income by Category:

SELECT 
    b.category, SUM(b.rental_price)
FROM
    books AS b
        JOIN
    issued_status AS s ON b.isbn = s.issued_book_isbn
GROUP BY 1;

-- Task 10 List Members Who Registered in the Last 180 Days-- 
insert into members
(member_id,member_name,member_address,reg_date)
values
('C120','Alice Jhonson','124 main st','2024-06-01');
SELECT 
    *
FROM
    members
WHERE
    reg_date >= current_date - interval 180 day ;
 
--  Task 10 List Employees with Their Branch Manager's Name and their branch details:
SELECT 
    e1.*, b.manager_id, e2.emp_name AS manager
FROM
    employees AS e1
        JOIN
    branch AS b ON e1.branch_id = b.branch_id
        JOIN
    employees AS e2 ON e2.emp_id = b.manager_id;
    
-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold
CREATE TABLE expensive_book AS SELECT * FROM
    books
WHERE
    rental_price > 7.00
    
 -- Task 12. Retrieve the List of Books Not Yet Returned 
 SELECT 
    i.issued_book_name
FROM
    issued_status AS i
        LEFT JOIN
    return_status AS r ON i.issued_id = r.issued_id
WHERE
    r.return_id IS NULL

-- Task 13: Identify Members with Overdue Books
-- Write a query to identify members who have overdue books
-- (assume a 30-day return period). Display the member's_id, member's name,
--  book title, issue date, and days overdue.

SELECT iss.issued_member_id,
       m.member_name,
       b.book_title,
       iss.issued_date,
       current_date - iss.issued_date AS overdue_days
FROM issued_status AS iss
JOIN members AS m
ON m.member_id = iss.issued_member_id
JOIN books AS b
ON b.isbn = iss.issued_book_isbn
LEFT JOIN return_status AS rs
ON rs.issued_id = iss.issued_id
WHERE rs.return_date IS NULL
AND (current_date - iss.issued_date) > 30;

-- Task 15: Branch Performance Report
-- Create a query that generates a performance report for each branch, 
-- showing the number of books issued, the number of books returned, 
-- and the total revenue generated from book rentals.
create table branch_report
as
SELECT 
    b.branch_id,
    b.manager_id,
    COUNT(ist.issued_id) AS number_book_issued,
    COUNT(rs.return_id) AS number_of_book_return,
    SUM(bk.rental_price) AS total_revenue
FROM
    issued_status AS ist
        JOIN
    employees AS e ON e.emp_id = ist.issued_emp_id
        JOIN
    branch AS b ON e.branch_id = b.branch_id
        LEFT JOIN
    return_status AS rs ON rs.issued_id = ist.issued_id
        JOIN
    books AS bk ON ist.issued_book_isbn = bk.isbn
GROUP BY 1 , 2;

-- Task 16: CTAS: Create a Table of Active Members
-- Use the CREATE TABLE AS (CTAS) statement to create a new table 
-- active_members containing members who have issued at least 
-- one book in the last 2 months.
create table active_members1
as
select * from members
where member_id in (select distinct issued_member_id
					from issued_status
                    where issued_date >= current_date - interval 2 month
                    );
                    
-- Task 17: Find Employees with the Most Book Issues Processed
-- Write a query to find the top 3 employees who have processed the most
--  book issues. Display the employee name, number of books processed, 
--  and their branch.
SELECT 
    e.emp_name,
    b.branch_id,
    b.manager_id,
    COUNT(ist.issued_id) as no_book_issued
FROM issued_status as ist
JOIN
employees as e
ON e.emp_id = ist.issued_emp_id
JOIN
branch as b
ON e.branch_id = b.branch_id
GROUP BY 1,2,3
order by no_book_issued desc



