# Online Book Store Database System - SQL Project

## 📚 Project Overview

This repository contains a complete SQL-based database system for an Online Book Store. The project models the core functionality of an e-commerce platform for books, including user management, product catalog, order processing, inventory management, and sales analysis. It demonstrates robust database design principles and advanced SQL querying techniques to manage and analyze bookstore operations effectively.

## 🎯 Key Features

The database supports the following functionalities:
- **User Management**: Customer registration, authentication, and profile management.
- **Product Catalog**: Browse books by title, author, genre, and publisher.
- **Inventory Management**: Track book stock levels and manage restocking.
- **Shopping Cart**: Add, update, and remove items from a virtual cart.
- **Order Processing**: Complete purchase transactions and order history.
- **Payment Processing**: Record payment details and transaction status.
- **Review System**: Customers can leave ratings and reviews for books.
- **Sales Analysis**: Generate reports on bestsellers, revenue, and customer behavior.

## 🗂️ Database Schema Design

The database is designed with normalization principles to ensure data integrity and minimize redundancy. The schema consists of the following tables:

### Core Tables:
- **`Customers`**: Stores customer information (CustomerID, Name, Email, PasswordHash, Address, Phone).
- **`Authors`**: Contains details about book authors (AuthorID, Name, Biography).
- **`Publishers`**: Contains publisher information (PublisherID, Name, Address).
- **`Books`**: Main product table (BookID, Title, AuthorID, PublisherID, ISBN, Genre, Price, PublishedDate).
- **`Inventory`**: Tracks stock levels for each book (InventoryID, BookID, QuantityInStock).
- **`Orders`**: Records order headers (OrderID, CustomerID, OrderDate, TotalAmount, Status).
- **`OrderItems`**: Records line items for each order (OrderItemID, OrderID, BookID, Quantity, Price).
- **`Payments`**: Stores payment information (PaymentID, OrderID, PaymentDate, Amount, PaymentMethod).
- **`Reviews`**: Contains customer ratings and reviews (ReviewID, BookID, CustomerID, Rating, Comment, ReviewDate).
- **`ShoppingCart`**: Temporary storage for cart items (CartID, CustomerID, BookID, Quantity, AddedDate).

## 🔍 SQL Techniques Demonstrated

### Database Design:
- Primary Keys and Foreign Keys for relational integrity
- Appropriate data types and constraints (NOT NULL, UNIQUE, CHECK)
- Indexing on frequently queried columns for performance

### Advanced Querying:
- **Complex JOIN Operations**: Combining multiple tables for comprehensive reports
- **Subqueries and Correlated Subqueries**: For advanced filtering and calculations
- **Common Table Expressions (CTEs)**: Simplifying complex queries and recursive operations
- **Window Functions**: `RANK()`, `ROW_NUMBER()`, and `NTILE()` for analytical queries
- **Aggregate Functions**: `SUM()`, `COUNT()`, `AVG()` with `GROUP BY` and `HAVING` clauses
- **Conditional Logic**: `CASE` statements for custom field calculations
- **Date/Time Functions**: Handling and grouping by temporal data

### Programmatic SQL:
- **Stored Procedures**: For common operations like placing orders or updating inventory
- **Triggers**: Automatically updating inventory after orders are placed
- **Views**: Creating simplified perspectives of complex data for reporting
- **Transactions**: Ensuring data consistency during order processing

## 📊 Sample Analysis Queries

The project includes queries to solve real-world business problems:

1.  **Sales Reporting**:
    - Monthly sales revenue reports
    - Best-selling books and genres
    - Customer lifetime value analysis

2.  **Inventory Management**:
    - Identifying low-stock items needing restocking
    - Slow-moving inventory analysis

3.  **Customer Analysis**:
    - Most valuable customers
    - Customer purchase history and preferences

4.  **Product Analysis**:
    - Highest rated books
    - Price analysis across genres

5.  **Operational Efficiency**:
    - Order fulfillment status tracking
    - Payment success rates by method

## 🚀 How to Use This Project

### Prerequisites
- A SQL database management system (MySQL, PostgreSQL, SQL Server, etc.)
- Basic knowledge of SQL and database concepts

### Installation & Setup
1.  **Clone the repository**:
    ```bash
    git clone https://github.com/tanvirhasan010/Online-Book-Store-Project-in-SQL.git
    cd Online-Book-Store-Project-in-SQL
    ```

2.  **Database Setup**:
    - Execute the `schema_creation.sql` script to create the database and tables.
    - Run the `sample_data.sql` script to populate the database with sample data.

3.  **Explore the Queries**:
    - Navigate to the `/queries` directory to find SQL files for various functionalities.
    - Run these queries in your database environment to see the results.

### Repository Structure
```
├── schema_creation.sql          # Database and table creation scripts
├── sample_data.sql              # Sample data insertion
├── queries/
│   ├── customer_queries.sql     # Customer-related queries
│   ├── product_queries.sql      # Book and inventory queries
│   ├── order_queries.sql        # Order processing queries
│   ├── payment_queries.sql      # Payment-related queries
│   └── analysis_queries.sql     # Business analysis reports
├── stored_procedures.sql        # SQL procedures for common tasks
├── triggers.sql                 # Database triggers
├── views.sql                    # Pre-defined views
└── README.md                    # This file
```

## 📋 Future Enhancements
- Integration with a frontend application (e.g., PHP, Python Django, Node.js)
- Implementation of full-text search for better book discovery
- Advanced analytics with predictive modeling for inventory demand
- Customer recommendation system based on purchase history
- API development for mobile application integration

## 🤝 Contributing
Contributions to enhance this project are welcome! Please feel free to:
- Fork the repository
- Create a feature branch
- Submit a pull request with detailed comments

## 📄 License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author
** Md Tanvir Hasan**
- GitHub: [@tanvirhasan010](https://github.com/tanvirhasan010)

## 🙏 Acknowledgments
- Inspired by real-world e-commerce database systems
- Thanks to the SQL community for best practices and resources


