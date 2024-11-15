#### WORKING FINAL CODE
import mysql.connector
import streamlit as st
import json

def create_connection():
    try:
        connection = mysql.connector.connect(
            host="localhost",
            user="root",
            password="root",
            database="PROJ_final"
        )
        if connection.is_connected():
            st.success("Successfully connected to the database.")
        return connection
    except mysql.connector.Error as err:
        st.error(f"Error: {err}")
        return None

def get_connection():
    if 'connection' not in st.session_state or st.session_state['connection'] is None:
        st.session_state['connection'] = create_connection()
    return st.session_state['connection']

# Function to register a new user
def register_user(username, password, user_type):
    connection = get_connection()
    if connection is None:
        st.error("Connection not established.")
        return False
    cursor = connection.cursor()
    try:
        cursor.execute("SELECT * FROM Login WHERE Username = %s", (username,))
        if cursor.fetchone():
            st.error("Username already exists. Please choose a different one.")
            return False
        cursor.execute("INSERT INTO Login (Username, Password, UserType) VALUES (%s, %s, %s)", 
                      (username, password, user_type))
        connection.commit()
        st.success("Registration successful!")
        return True
    except mysql.connector.Error as e:
        st.error(f"Error: {e}")
        return False
    finally:
        cursor.close()

def handle_user_registration(username, password, user_type, first_name, last_name, email, phone_number, street, city, postal_code):
    connection = get_connection()
    if connection is None:
        st.error("Connection not established.")
        return None
    
    cursor = connection.cursor()
    try:
        st.write("You are successfully registered, now you can login!")
        # Call the HandleLogin function and get the ID
        query = """
        SELECT HandleLogin(%s, %s, %s, %s, %s, %s, %s, %s, %s) AS user_id
        """
        cursor.execute(query, (username, password, first_name, last_name, email, 
                             phone_number, street, city, postal_code))
        result = cursor.fetchone()
        user_id = result[0] if result else None
        
        if user_id:
            connection.commit()
            return user_id
        return None
        
    except mysql.connector.Error as e:
        st.error(f"Error during registration: {e}")
        return None
    finally:
        cursor.close()

# Function to log in an existing user
def login_user(username, password):
    connection = get_connection()
    if connection is None:
        st.error("Connection not established.")
        return None
    cursor = connection.cursor(dictionary=True)
    cursor.execute("SELECT UserType FROM Login WHERE Username = %s AND Password = %s", 
                  (username, password))
    user = cursor.fetchone()
    cursor.close()
    return user

def upload_book(title, author_fname, author_lname, category_name, subcategory, 
                book_condition, publisher_name, edition, seller_id, price, tags):
    connection = get_connection()
    if connection is None:
        st.error("Database connection not established.")
        return False
    
    cursor = connection.cursor()
    try:
        # Print seller_id for debugging
        st.write(f"Uploading book for seller ID: {seller_id}")
        
        # Convert tags list to JSON string
        tags_json = json.dumps(tags)
        
        # Call the UploadBook stored procedure
        args = (title, author_fname, author_lname, category_name, subcategory,
               book_condition, publisher_name, edition, seller_id, price, tags_json)
        
        cursor.callproc('UploadBook', args)
        connection.commit()
        
        st.success("Book uploaded successfully!")
        return True
        
    except mysql.connector.Error as e:
        st.error(f"Error uploading book: {e}")
        return False
    finally:
        cursor.close()  # Don't close the connection, just the cursor

def get_highest_rated_sellers():
    connection = get_connection()
    if connection is None:
        raise Exception("Database connection not established.")
    
    cursor = connection.cursor(dictionary=True)
    
    try:
        # Call the GetHighestRatedSellers stored procedure
        cursor.callproc('GetHighestRatedSellers')
        
        # Fetch the results
        sellers = []
        for result in cursor.stored_results():
            sellers.extend(result.fetchall())
        
        return sellers
        
    except mysql.connector.Error as e:
        raise Exception(f"Error fetching highest rated sellers: {e}")
    
    finally:
        cursor.close()

def update_book_price(listing_id, new_price):
    connection = get_connection()
    cursor = connection.cursor()

    try:
        # Call the EnsureNonNegativePrice trigger

        cursor.execute("CALL UpdateBookPrice(%s, %s)", (listing_id, new_price))
        connection.commit()
        st.success("Book price updated successfully!")
        return True
    except mysql.connector.Error as e:
        st.error(f"Error updating book price: {e}")
        return False
    finally:
        cursor.close()

def get_current_listings_by_seller(seller_id):
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    try:
        # Call the GetCurrentListingsBySeller stored procedure
        cursor.callproc('GetCurrentListingsBySeller', (seller_id,))

        # Fetch the results
        listings = []
        for result in cursor.stored_results():
            listings.extend(result.fetchall())

        return listings
    except mysql.connector.Error as e:
        st.error(f"Error getting current listings: {e}")
        return []
    finally:
        cursor.close()

def get_transaction_history(buyer_id):
    connection = get_connection()
    if connection is None:
        raise Exception("Database connection not established.")
    
    cursor = connection.cursor(dictionary=True)
    
    try:
        # Call the GetTransactionHistory stored procedure and pass the buyer_id
        cursor.callproc('GetTransactionHistory', (buyer_id,))
        
        # Fetch the results
        transactions = []
        for result in cursor.stored_results():
            transactions.extend(result.fetchall())
        
        return transactions
        
    except mysql.connector.Error as e:
        raise Exception(f"Error fetching transaction history: {e}")
    
    finally:
        cursor.close()

def buy_book(listing_id, buyer_id, rating):
    connection = get_connection()
    if connection is None:
        raise Exception("Database connection not established.")
    
    cursor = connection.cursor(dictionary=True)
    
    try:
        # Call BuyBook procedure
        cursor.callproc('BuyBook', (listing_id, buyer_id, rating))
        
        # Delete the listing after it's marked as sold
        #cursor.execute("DELETE FROM Listing WHERE ListingID = %s AND Listing_Status = 'SOLD'", (listing_id,))
        
        connection.commit()
        return "Book purchased successfully."
        
    except mysql.connector.Error as e:
        raise Exception(f"Error in buying book: {e}")
    
    finally:
        cursor.close()

def search_books_by_category(category_name):
    connection = get_connection()
    if connection is None:
        raise Exception("Database connection not established.")
    
    cursor = connection.cursor(dictionary=True)
    
    try:
        # Call the SearchBookByCategory stored procedure
        cursor.callproc('SearchBookByCategory', (category_name,))
        
        # Fetch the results
        books = []
        for result in cursor.stored_results():
            books.extend(result.fetchall())
        
        return books
        
    except mysql.connector.Error as e:
        raise Exception(f"Error searching books: {e}")
    
    finally:
        cursor.close()

# Initialize session state variables
if 'logged_in' not in st.session_state:
    st.session_state['logged_in'] = False
if 'register' not in st.session_state:
    st.session_state['register'] = False
if 'user_type' not in st.session_state:
    st.session_state['user_type'] = None
if 'seller_id' not in st.session_state:
    st.session_state['seller_id'] = None
if 'buyer_id' not in st.session_state:
    st.session_state['buyer_id'] = None
if 'show_details_form' not in st.session_state:
    st.session_state['show_details_form'] = False
if 'username' not in st.session_state:
    st.session_state['username'] = None
if 'password' not in st.session_state:
    st.session_state['password'] = None

st.title("Affordable Educational Books Resale System")

# Registration and Login options
if not st.session_state['logged_in']:
    option = st.selectbox("Choose an option:", ["Login", "Register"])
    
    if option == "Register":
        with st.form("register_form"):
            new_username = st.text_input("New Username")
            new_password = st.text_input("New Password", type="password")
            user_type = st.selectbox("User Type", ["Buyer", "Seller"])
            submit_register = st.form_submit_button("Submit Registration")
            
            if submit_register and new_username:
                if register_user(new_username, new_password, user_type):
                    st.session_state['logged_in'] = False
                    st.session_state['register'] = True
                    st.session_state['show_details_form'] = True
                    st.session_state['user_type'] = user_type
                    st.session_state['username'] = new_username
                    st.session_state['password'] = new_password
                    st.rerun()

    elif option == "Login":
        with st.form("login_form"):
            username = st.text_input("Username")
            password = st.text_input("Password", type="password")
            submit_login = st.form_submit_button("Login")
            
            if submit_login:
                user = login_user(username, password)
                if user:
                    st.session_state['logged_in'] = True
                    st.session_state['user_type'] = user['UserType']
                    st.session_state['username'] = username
                    st.session_state['password'] = password
                    st.success("Login successful!")
                    st.rerun()
                else:
                    st.error("Invalid username or password.")

if st.session_state['register'] and st.session_state['show_details_form']:
    st.write(f"Welcome! You are registered in as a {st.session_state['user_type']}")
    
    with st.form("details_form"):
        first_name = st.text_input("First Name")
        last_name = st.text_input("Last Name")
        email = st.text_input("Email")
        phone_number = st.text_input("Phone Number")
        street = st.text_input("Street")
        city = st.text_input("City")
        postal_code = st.text_input("Postal Code")
        submit_details = st.form_submit_button("Submit Details")
        
        if submit_details:
            result_id = handle_user_registration(
                st.session_state['username'], 
                st.session_state['password'], 
                st.session_state['user_type'].lower(),
                first_name, last_name, email, 
                phone_number, street, city, postal_code
            )
            if result_id:
                if st.session_state['user_type'] == 'Seller':
                    st.session_state['seller_id'] = result_id
                if st.session_state['user_type'] == 'Buyer':
                    st.session_state['buyer_id'] = result_id
                st.session_state['show_details_form'] = False
                st.success("Details submitted successfully!")
                st.rerun()

if st.session_state['logged_in'] and st.session_state['user_type'] == 'Buyer' and not st.session_state['show_details_form']:
    #st.write("Debug Info:")
    st.write(f"Buyer ID in session: {st.session_state.get('buyer_id')}")
    st.subheader("Search Books by Category")
    
    with st.form("search_books_form"):
        category_name = st.text_input("Category Name")
        submit_search = st.form_submit_button("Search")
        
        if submit_search:
            try:
                books = search_books_by_category(category_name)
                if books:
                    st.subheader("Available Books:")
                    for book in books:
                        st.write(f"Title: {book['Title']}")
                        st.write(f"Author: {book['AuthorFName']} {book['AuthorLName']}")
                        st.write(f"Category: {book['CategoryName']}")
                        st.write(f"Price: {book['Price']}")
                        st.write(f"Listing Status: {book['Listing_Status']}")
                        st.write(f"Listing ID: {book['ListingID']}")
                        st.write(f"")
                        st.write("---")
            except Exception as e:
                st.error(f"Error: {e}")
    st.subheader("Buy Book")
    
    listing_id_input = st.text_input("Listing ID")
    buyer_id_input = st.text_input("Buyer ID")
    rating_input = st.text_input("Rating")
    
    # Add check for empty input fields before conversion
    if st.button("Buy Book"):
        if listing_id_input and buyer_id_input and rating_input:
            try:
                listing_id = int(listing_id_input)
                buyer_id = int(buyer_id_input)
                rating = float(rating_input)
                buy_book(listing_id, buyer_id, rating)
                st.success("Book purchased successfully!")
            except ValueError:
                st.error("Please enter valid numbers for Listing ID, Buyer ID, and Rating.")
        else:
            st.error("Please fill out all fields before purchasing.")

    if st.button("GetHighestSeller"):   
        highest_rated_sellers = get_highest_rated_sellers()
        if highest_rated_sellers:
            for seller in highest_rated_sellers:
                st.write(f"Seller Name: {seller['FirstName']} {seller['LastName']}")
                st.write(f"Average Rating: {seller['AverageRating']:.2f}")
                st.write("---")
        else:
            st.warning("No highest rated sellers found.")
    
    if st.button("Transaction History"):
        try:
            buyer_id = st.session_state['buyer_id']
            transactions = get_transaction_history(buyer_id)
            if transactions:
                st.subheader("Your Transaction History:")
                for transaction in transactions:
                    st.write(f"Listing ID: {transaction['ListingID']}")
                    st.write(f"Book Title: {transaction['BookTitle']}")
                    st.write(f"Seller: {transaction['SellerFirstName']} {transaction['SellerLastName']}")
                    st.write(f"Date: {transaction['DateOfTransaction']}")
                    st.write(f"Amount: {transaction['TransactionAmount']}")
                    st.write("---")
        except Exception as e:
            st.error(f"Error fetching transaction history: {e}")

            
        
                
# Show Upload Book form only for logged-in sellers
if st.session_state['logged_in'] and st.session_state['user_type'] == 'Seller' and not st.session_state['show_details_form']:
    st.subheader("Upload Book")
    
    # Debug information
    #st.write("Debug Info:")
    st.write(f"Seller ID in session: {st.session_state.get('seller_id')}")
    
    with st.form("upload_book_form"):
        title = st.text_input("Title of the book")
        author_fname = st.text_input("Author's first name")
        author_lname = st.text_input("Author's last name")
        category_name = st.text_input("Category Name")
        subcategory = st.text_input("Subcategory")
        book_condition = st.selectbox("Book Condition:", ["old", "used", "new"])
        publisher_name = st.text_input("Publisher Name")
        edition = st.text_input("Edition")
        price = st.number_input("Set the price", min_value=0.0)
        tags_input = st.text_input("Tags (comma-separated)")
        
        submit_book = st.form_submit_button("Upload Book")
        
        if submit_book:
            if not st.session_state.get('seller_id'):
                st.error("Seller ID not found. Please log in again.")
            else:
                tags = [tag.strip() for tag in tags_input.split(",") if tag.strip()]
                seller_id = st.session_state['seller_id']
                
                # Validate all required fields
                if all([title, author_fname, author_lname, category_name, subcategory,
                       book_condition, publisher_name, edition, price]):
                    upload_book(
                        title, author_fname, author_lname,
                        category_name, subcategory, book_condition,
                        publisher_name, edition,
                        seller_id,  # Using seller_id from session state
                        price, tags
                    )
                else:
                    st.error("Please fill in all required fields.")
    st.subheader("Update Book Price")

    # Get the current listings for the seller
    seller_id = st.session_state['seller_id']
    current_listings = get_current_listings_by_seller(seller_id)

    # Display the current listings
    st.write("Current Listings:")
    for listing in current_listings:
        st.write(f"Listing ID: {listing['ListingID']}, Book Title: {listing['BookTitle']}, Price: {listing['Price']}, Status: {listing['Listing_Status']}")

    with st.form("update_book_price_form"):
        listing_id = st.selectbox("Select Listing", [str(l['ListingID']) for l in current_listings])
        new_price = st.number_input("New Price", min_value=0.0)
        submit_price_update = st.form_submit_button("Update Price")

        if submit_price_update:
            update_book_price(listing_id, new_price)

if st.session_state['logged_in']:
    if st.button("Delete user"):
        # Connect to the database
        connection = get_connection()  # Replace with actual connection function
        cursor = connection.cursor()  # Remove dictionary=True if not using MySQL

        try:
            user_name = st.session_state.get('username')
            if user_name:
                # Execute the delete query (DELETE OPERATION)
                cursor.execute("DELETE FROM login WHERE Username = %s", (user_name,))
                
                # Commit the changes
                connection.commit()
                st.success("User deleted successfully.")
            else:
                st.warning("No username found in session.")
        
        except Exception as e:
            st.error(f"An error occurred: {e}")

        finally:
            # Close the connection
            cursor.close()

# Logout button
if st.session_state['logged_in']:
    if st.button("Logout"):
        for key in st.session_state.keys():
            del st.session_state[key]
        st.rerun()