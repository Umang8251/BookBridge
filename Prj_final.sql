#Final working code
-- Create Database
CREATE DATABASE PROJ_final;
USE PROJ_final;

-- Creating Category Table
CREATE TABLE Category (
    CategoryID INT PRIMARY KEY AUTO_INCREMENT,
    CategoryName VARCHAR(255) NOT NULL
);

-- Creating SubCategories Table
CREATE TABLE SubCategories (
    CategoryID INT,
    SubCategory VARCHAR(255),
    PRIMARY KEY (CategoryID, SubCategory),
    FOREIGN KEY (CategoryID) REFERENCES Category(CategoryID)
);

-- Creating Publisher Table
CREATE TABLE Publisher (
    PublisherID INT PRIMARY KEY AUTO_INCREMENT,
    PublisherName VARCHAR(255) NOT NULL
);

-- Creating Book Table
CREATE TABLE Book (
    BookID INT PRIMARY KEY AUTO_INCREMENT,
    Title VARCHAR(255) NOT NULL,
    AuthorFName VARCHAR(255) NOT NULL,
    AuthorLName VARCHAR(255) NOT NULL,
    CategoryID INT,
    BookCondition VARCHAR(255),
    PublisherID INT,
    Edition VARCHAR(50),
    FOREIGN KEY (CategoryID) REFERENCES Category(CategoryID),
    FOREIGN KEY (PublisherID) REFERENCES Publisher(PublisherID)
);

-- Creating Location Table (for Seller and Buyer)
CREATE TABLE Location (
    LocationID INT PRIMARY KEY AUTO_INCREMENT,
    Street VARCHAR(255),
    City VARCHAR(100),
    PostalCode VARCHAR(6)
);

-- Creating Seller Table
CREATE TABLE Seller (
    SellerID INT PRIMARY KEY AUTO_INCREMENT,
    FirstName VARCHAR(255),
    LastName VARCHAR(255),
    Email VARCHAR(255),
    PhoneNumber VARCHAR(15),
    LocationID INT,
    FOREIGN KEY (LocationID) REFERENCES Location(LocationID)
);

-- Creating Buyer Table
CREATE TABLE Buyer (
    BuyerID INT PRIMARY KEY AUTO_INCREMENT,
    FirstName VARCHAR(255),
    LastName VARCHAR(255),
    Email VARCHAR(255),
    PhoneNumber VARCHAR(15),
    LocationID INT,
    FOREIGN KEY (LocationID) REFERENCES Location(LocationID)
);

-- Creating Listing Table
CREATE TABLE Listing (
    ListingID INT PRIMARY KEY AUTO_INCREMENT,
    BookID INT,
    SellerID INT,
    DateOfListing DATE,
    Price DECIMAL(10, 2),
    Listing_Status VARCHAR(50),
    FOREIGN KEY (BookID) REFERENCES Book(BookID),
    FOREIGN KEY (SellerID) REFERENCES Seller(SellerID)
);

-- Creating Transaction Table
CREATE TABLE Transactions (
    TransactionID INT PRIMARY KEY AUTO_INCREMENT,
    ListingID INT,
    BuyerID INT,
    DateOfTransaction DATE,
    TransactionAmount DECIMAL(10, 2),
    FOREIGN KEY (ListingID) REFERENCES Listing(ListingID),
    FOREIGN KEY (BuyerID) REFERENCES Buyer(BuyerID)
);

-- Creating BookTag Table
CREATE TABLE BookTag (
    BookID INT,
    Tag VARCHAR(255),
    PRIMARY KEY (BookID, Tag),
    FOREIGN KEY (BookID) REFERENCES Book(BookID)
);

-- Creating Ratings Table
CREATE TABLE Ratings (
    BuyerID INT,
    SellerID INT,
    Rating DECIMAL(3, 2),
    PRIMARY KEY (BuyerID, SellerID),
    FOREIGN KEY (BuyerID) REFERENCES Buyer(BuyerID),
    FOREIGN KEY (SellerID) REFERENCES Seller(SellerID)
);

-- Sample Data Inserts
INSERT INTO Category (CategoryName)
VALUES ('Mathematics'), ('Science'), ('History'), ('Literature'), ('Computer Science');

INSERT INTO SubCategories (CategoryID, SubCategory)
VALUES 
(1, 'Algebra'), 
(1, 'Calculus'), 
(2, 'Physics'), 
(2, 'Chemistry'), 
(3, 'World History'), 
(3, 'Ancient Civilizations'), 
(4, 'English Literature'), 
(5, 'Programming'), 
(5, 'Data Structures');

INSERT INTO Publisher (PublisherName)
VALUES 
('Math World'), 
('Advanced Math'), 
('Science Press'), 
('Chemistry House'), 
('History Books'), 
('Historic Publications'), 
('Tech Books'), 
('CS Publications');

INSERT INTO Book (Title, AuthorFName, AuthorLName, CategoryID, BookCondition, PublisherID, Edition)
VALUES 
('Algebra Essentials', 'Emily', 'White', 1, 'New', 1, '1st'),
('Calculus for Beginners', 'John', 'Doe', 1, 'Used', 2, '2nd'),
('Physics Fundamentals', 'Jane', 'Smith', 2, 'New', 3, '1st'),
('Introduction to Chemistry', 'Michael', 'Brown', 2, 'Used', 4, '3rd'),
('World History Overview', 'Sarah', 'Green', 3, 'New', 5, '2nd'),
('Ancient Civilizations', 'Tom', 'Wilson', 3, 'Used', 6, '1st'),
('Introduction to Programming', 'Alice', 'Johnson', 5, 'New', 7, '3rd'),
('Data Structures in C', 'Robert', 'King', 5, 'Used', 8, '4th');

INSERT INTO BookTag (BookID, Tag)
VALUES 
(1, 'Algebra'), 
(2, 'Calculus'), 
(3, 'Physics'), 
(4, 'Chemistry'), 
(5, 'History'), 
(6, 'Ancient History'), 
(7, 'Programming'), 
(8, 'Data Structures');

INSERT INTO Location (Street, City, PostalCode)
VALUES 
('123 Elm St', 'Springfield', '11111'),
('456 Oak St', 'Greenfield', '22222'),
('789 Maple St', 'Bluefield', '33333'),
('321 Pine St', 'Redfield', '44444');

INSERT INTO Seller (FirstName, LastName, Email, PhoneNumber, LocationID)
VALUES 
('John', 'Doe', 'johndoe@example.com', '1234567890', 1),
('Jane', 'Smith', 'janesmith@example.com', '0987654321', 2);

INSERT INTO Buyer (FirstName, LastName, Email, PhoneNumber, LocationID)
VALUES 
('Alice', 'Brown', 'alicebrown@example.com', '5678901234', 3),
('Bob', 'Green', 'bobgreen@example.com', '4321098765', 4);

INSERT INTO Listing (BookID, SellerID, DateOfListing, Price, Listing_Status)
VALUES 
(1, 1, '2024-10-01', 25.99, 'Available'),
(2, 2, '2024-09-15', 20.50, 'Sold'),
(3, 1, '2024-09-20', 30.00, 'Available'),
(4, 2, '2024-08-10', 15.99, 'Available'),
(5, 1, '2024-07-05', 22.00, 'Available');

INSERT INTO Transactions (ListingID, BuyerID, DateOfTransaction, TransactionAmount)
VALUES 
(2, 1, '2024-09-16', 20.50), 
(3, 2, '2024-10-01', 30.00);

INSERT INTO Ratings (BuyerID, SellerID, Rating)
VALUES 
(1, 2, 4.5), 
(2, 1, 5.0);

/*
-- Insert into Book and Listing Procedure
DELIMITER $$

CREATE PROCEDURE AddBook(
    IN p_Title VARCHAR(255),
    IN p_AuthorFName VARCHAR(255),
    IN p_AuthorLName VARCHAR(255),
    IN p_CategoryID INT,
    IN p_BookCondition VARCHAR(255),
    IN p_Price DECIMAL(10, 2),
    IN p_PublisherID INT,
    IN p_Edition VARCHAR(50),
    IN p_SellerID INT
)
BEGIN
    DECLARE newBookID INT;
    
    -- Insert into Book table
    INSERT INTO Book (Title, AuthorFName, AuthorLName, CategoryID, BookCondition, Price, PublisherID, Edition)
    VALUES (p_Title, p_AuthorFName, p_AuthorLName, p_CategoryID, p_BookCondition, p_Price, p_PublisherID, p_Edition);

    -- Get the new BookID for the inserted book
    SET newBookID = LAST_INSERT_ID();
    
    -- Insert into Listing table
    INSERT INTO Listing (BookID, SellerID, DateOfListing, Price, Listing_Status)
    VALUES (newBookID, p_SellerID, CURDATE(), p_Price, 'Available');
END$$

DELIMITER ;
*/

CREATE TABLE Login (
    LoginID INT PRIMARY KEY AUTO_INCREMENT,
    Username VARCHAR(50) UNIQUE NOT NULL,
    Password VARCHAR(50) NOT NULL,
    UserType ENUM('Buyer', 'Seller') NOT NULL
);
DELIMITER //

-- ACTION 1 (FUNCTION)
CREATE FUNCTION HandleLogin (
    p_username VARCHAR(50), 
    p_password VARCHAR(50), 
    p_firstname VARCHAR(255), 
    p_lastname VARCHAR(255), 
    p_email VARCHAR(255), 
    p_phonenumber VARCHAR(15), 
    p_street VARCHAR(255), 
    p_city VARCHAR(100), 
    p_postalcode VARCHAR(6)
) 
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_UserType ENUM('Buyer', 'Seller');
    DECLARE v_SellerID INT;

    -- Check login credentials
    SELECT UserType INTO v_UserType 
    FROM Login 
    WHERE Username = p_username AND Password = p_password;

    -- If user exists, proceed based on UserType
    IF v_UserType = 'Seller' THEN
        -- Insert or Update Seller and Location
        INSERT INTO Location (Street, City, PostalCode) 
        VALUES (p_street, p_city, p_postalcode);

        -- Insert into Seller table and get the SellerID
        INSERT INTO Seller (FirstName, LastName, Email, PhoneNumber, LocationID)
        VALUES (p_firstname, p_lastname, p_email, p_phonenumber, LAST_INSERT_ID());
        
        SET v_SellerID = LAST_INSERT_ID();  -- Store the newly created SellerID
    ELSE
        -- If user is a Buyer, perform the Buyer insert and set v_SellerID to NULL
        INSERT INTO Location (Street, City, PostalCode) 
        VALUES (p_street, p_city, p_postalcode);

        INSERT INTO Buyer (FirstName, LastName, Email, PhoneNumber, LocationID)
        VALUES (p_firstname, p_lastname, p_email, p_phonenumber, LAST_INSERT_ID());

        SET v_SellerID = LAST_INSERT_ID();
    END IF;

    RETURN v_SellerID;
END //

DELIMITER ;
-- DROP PROCEDURE HandleLogin;

-- ACTION 2 (PROCEDURE)
DELIMITER //

CREATE PROCEDURE UploadBook(
    IN p_title VARCHAR(255), 
    IN p_author_fname VARCHAR(255),
    IN p_author_lname VARCHAR(255), 
    IN p_category_name VARCHAR(255),
    IN p_subcategory VARCHAR(255), 
    IN p_book_condition VARCHAR(255),
    IN p_publisher_name VARCHAR(255), 
    IN p_edition VARCHAR(50),
    IN p_seller_id INT, 
    IN p_price DECIMAL(10, 2), 
    IN p_tags JSON
)
BEGIN
    DECLARE v_category_id INT;
    DECLARE v_subcategory_exists INT DEFAULT 0;
    DECLARE v_publisher_id INT;
    DECLARE v_book_id INT;
    DECLARE cur_tag VARCHAR(255);
    
    -- Adding an alias `jt` to the JSON_TABLE function
    DECLARE tag_cursor CURSOR FOR 
        SELECT JSON_UNQUOTE(json_extract(p_tags, CONCAT('$[', idx, ']'))) 
        FROM JSON_TABLE(p_tags, '$[*]' COLUMNS(idx FOR ORDINALITY)) AS jt;
        
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_subcategory_exists = 1;

    -- Insert or get Category
    SELECT CategoryID INTO v_category_id 
    FROM Category WHERE CategoryName = p_category_name;

    IF v_category_id IS NULL THEN
        INSERT INTO Category (CategoryName) VALUES (p_category_name);
        SET v_category_id = LAST_INSERT_ID();
    END IF;

    -- Insert or get Subcategory
    SELECT 1 INTO v_subcategory_exists 
    FROM SubCategories WHERE CategoryID = v_category_id AND SubCategory = p_subcategory;

    IF v_subcategory_exists = 0 THEN
        INSERT INTO SubCategories (CategoryID, SubCategory) VALUES (v_category_id, p_subcategory);
    END IF;

    -- Insert or get Publisher
    SELECT PublisherID INTO v_publisher_id 
    FROM Publisher WHERE PublisherName = p_publisher_name;

    IF v_publisher_id IS NULL THEN
        INSERT INTO Publisher (PublisherName) VALUES (p_publisher_name);
        SET v_publisher_id = LAST_INSERT_ID();
    END IF;

    -- Insert Book
    INSERT INTO Book (Title, AuthorFName, AuthorLName, CategoryID, BookCondition, PublisherID, Edition)
    VALUES (p_title, p_author_fname, p_author_lname, v_category_id, p_book_condition, v_publisher_id, p_edition);
    SET v_book_id = LAST_INSERT_ID();

    -- Insert Book Tags
    OPEN tag_cursor;

    read_loop: LOOP
        FETCH tag_cursor INTO cur_tag;
        IF v_subcategory_exists = 1 THEN
            LEAVE read_loop;
        END IF;
        INSERT INTO BookTag (BookID, Tag) VALUES (v_book_id, cur_tag);
    END LOOP;

    CLOSE tag_cursor;

    -- Insert Listing
    INSERT INTO Listing (BookID, SellerID, DateOfListing, Price, Listing_Status)
    VALUES (v_book_id, p_seller_id, CURDATE(), p_price, 'Available');
END //

DELIMITER ;


-- ACTION 3 (PROCEDURE)
-- DROP PROCEDURE BuyBook;
DELIMITER //

CREATE PROCEDURE BuyBook(
    IN p_listing_id INT,
    IN p_buyer_id INT,
    IN p_rating DECIMAL(3, 2)
)
BEGIN
    DECLARE v_seller_id INT;
	DECLARE v_price DECIMAL(10,2);
    -- Retrieve SellerID from the Listing
    SELECT SellerID, Price INTO v_seller_id ,v_price FROM Listing WHERE ListingID = p_listing_id;

    -- Insert into Transactions
    INSERT INTO Transactions (ListingID, BuyerID, DateOfTransaction, TransactionAmount)
    VALUES (p_listing_id, p_buyer_id, CURDATE(), v_price);

    -- Insert or Update Ratings
    INSERT INTO Ratings (BuyerID, SellerID, Rating)
    VALUES (p_buyer_id, v_seller_id, p_rating)
    ON DUPLICATE KEY UPDATE Rating = p_rating;

    -- Update Listing Status to 'SOLD'
    UPDATE Listing SET Listing_Status = 'SOLD' WHERE ListingID = p_listing_id;
END //

DELIMITER ;

-- ACTION 4
DELIMITER //

CREATE PROCEDURE GetTransactionHistory(
    IN p_buyer_id INT
)
BEGIN
    SELECT 
        T.TransactionID,
        T.ListingID,
        L.BookID,
        B.Title AS BookTitle,
        S.SellerID,
        S.FirstName AS SellerFirstName,
        S.LastName AS SellerLastName,
        BUY.BuyerID,
        BUY.FirstName AS BuyerFirstName,
        BUY.LastName AS BuyerLastName,
        T.DateOfTransaction,
        T.TransactionAmount,
        L.Price AS OriginalPrice,
        L.Listing_Status
    FROM 
        Transactions T
        JOIN Listing L ON T.ListingID = L.ListingID
        JOIN Book B ON L.BookID = B.BookID
        JOIN Seller S ON L.SellerID = S.SellerID
        JOIN Buyer BUY ON T.BuyerID = BUY.BuyerID
    WHERE
        BUY.BuyerID = p_buyer_id
    ORDER BY 
        T.DateOfTransaction ASC;
END //

DELIMITER ;

-- ACTION 5 (JOIN QUERY)
DELIMITER //

CREATE PROCEDURE SearchBookByCategory(
    IN p_category_name VARCHAR(255)
)
BEGIN
    SELECT 
        B.BookID,
        B.Title,
        B.AuthorFName,
        B.AuthorLName,
        B.Edition,
        C.CategoryName,
        L.ListingID,
        L.Price,
        L.Listing_Status
    FROM 
        Book B
        JOIN Category C ON B.CategoryID = C.CategoryID
        JOIN Listing L ON B.BookID = L.BookID
    WHERE 
        C.CategoryName = p_category_name
        AND L.Listing_Status = 'Available';
END //

DELIMITER ;

-- ACTION 6 (UPDATE - CRUD)
DELIMITER //

CREATE PROCEDURE UpdateBookPrice(
    IN p_listing_id INT,
    IN p_new_price DECIMAL(10, 2)
)
BEGIN
    UPDATE Listing
    SET Price = p_new_price
    WHERE ListingID = p_listing_id;
END //

DELIMITER ;

-- ACTION 7 (NESTED AND AGGREGATE QUERY)
-- DROP PROCEDURE GetHighestRatedSellers;

DELIMITER //
CREATE PROCEDURE GetHighestRatedSellers()
BEGIN
    SELECT 
        S.SellerID,
        S.FirstName,
        S.LastName,
        AVG(R.Rating) AS AverageRating
    FROM 
        Seller S
        JOIN Ratings R ON S.SellerID = R.SellerID
    GROUP BY 
        S.SellerID
    HAVING 
        AVG(R.Rating) = (
            SELECT MAX(avg_rating)
            FROM (
                SELECT SellerID, AVG(Rating) AS avg_rating
                FROM Ratings
                GROUP BY SellerID
            ) AS SellerAvgRatings
        );
END //

DELIMITER ;

-- ACTION 8
DELIMITER //

CREATE PROCEDURE GetCurrentListingsBySeller(
    IN p_seller_id INT
)
BEGIN
    SELECT 
        L.ListingID,
        B.Title AS BookTitle,
        L.Price,
        L.Listing_Status,
        L.DateOfListing
    FROM 
        Listing L
        JOIN Book B ON L.BookID = B.BookID
    WHERE 
        L.SellerID = p_seller_id
        AND L.Listing_Status = 'Available';
END //

DELIMITER ;

-- ACTION 9 (TRIGGER)
DELIMITER //

CREATE TRIGGER EnsureNonNegativePrice
BEFORE INSERT ON Listing
FOR EACH ROW
BEGIN
    IF NEW.Price < 0 THEN
        SET NEW.Price = 0;
    END IF;
END //

DELIMITER ;

-- ACTION 10
-- Trigger for updating price to non-negative value
DELIMITER //

CREATE TRIGGER EnsureNonNegativePriceOnUpdate
BEFORE UPDATE ON Listing
FOR EACH ROW
BEGIN
    IF NEW.Price < 0 THEN
        SET NEW.Price = 0;
    END IF;
END //

DELIMITER ;


-- ROLES AND PRIVILEGES
-- Create the Buyer and Seller roles
CREATE ROLE Buyer;
CREATE ROLE Seller;

-- Grant permissions to the Buyer role
GRANT SELECT ON Book TO Buyer; 
GRANT INSERT ON Transactions TO Buyer;
GRANT SELECT, UPDATE ON Transactions TO Buyer; 
GRANT INSERT ON Ratings TO Buyer;
GRANT SELECT ON Listing TO Buyer;

-- Grant permissions to the Seller role
GRANT SELECT, INSERT, UPDATE ON Seller TO Seller;
GRANT SELECT, INSERT, UPDATE ON Listing TO Seller;
GRANT SELECT ON Book TO Seller;
GRANT SELECT ON Category TO Seller;
GRANT SELECT ON Publisher TO Seller;

CREATE USER 'tani'@'localhost' IDENTIFIED BY 'tani';
GRANT Buyer TO 'tani'@'localhost';

-- Assign Seller Role
CREATE USER 'nami'@'localhost' IDENTIFIED BY '2345';
GRANT Seller TO 'nami'@'localhost';

SELECT * FROM mysql.role_edges;

select * from login;
select * from seller;
select * from ratings;
select * from location;
select * from buyer;
select * from listing;
select * from book;
SELECT * from category;
