-- ============================================
-- БАЗА ДАННЫХ БИБЛИОТЕКИ
-- Часть 1: Создание таблиц
-- ============================================

-- 1. Genre
CREATE TABLE IF NOT EXISTS Genre (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Publisher
CREATE TABLE IF NOT EXISTS Publisher (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    address TEXT,
    contact_phone VARCHAR(20),
    contact_email VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Author
CREATE TABLE IF NOT EXISTS Author (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    birth_date DATE,
    death_date DATE,
    country VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. Composition
CREATE TABLE IF NOT EXISTS Composition (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    original_language VARCHAR(50),
    year_written INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. Authorship
CREATE TABLE IF NOT EXISTS Authorship (
    id SERIAL PRIMARY KEY,
    composition_id INT NOT NULL,
    author_id INT NOT NULL,
    role VARCHAR(50) DEFAULT 'main',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (composition_id) REFERENCES Composition(id),
    FOREIGN KEY (author_id) REFERENCES Author(id),
    UNIQUE(composition_id, author_id, role)
);

-- 6. Book
CREATE TABLE IF NOT EXISTS Book (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    isbn VARCHAR(20) UNIQUE,
    publisher_id INT,
    publication_year INTEGER,
    page_count INT,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (publisher_id) REFERENCES Publisher(id)
);

-- 7. BookComposition
CREATE TABLE IF NOT EXISTS BookComposition (
    id SERIAL PRIMARY KEY,
    book_id INT NOT NULL,
    composition_id INT NOT NULL,
    position_in_book INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (book_id) REFERENCES Book(id),
    FOREIGN KEY (composition_id) REFERENCES Composition(id),
    UNIQUE(book_id, composition_id)
);

-- 8. Tags
CREATE TABLE IF NOT EXISTS Tags (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 9. BookTag
CREATE TABLE IF NOT EXISTS BookTag (
    id SERIAL PRIMARY KEY,
    book_id INT NOT NULL,
    tag_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (book_id) REFERENCES Book(id),
    FOREIGN KEY (tag_id) REFERENCES Tags(id),
    UNIQUE(book_id, tag_id)
);

-- 10. BookGenre
CREATE TABLE IF NOT EXISTS BookGenre (
    id SERIAL PRIMARY KEY,
    book_id INT NOT NULL,
    genre_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (book_id) REFERENCES Book(id),
    FOREIGN KEY (genre_id) REFERENCES Genre(id),
    UNIQUE(book_id, genre_id)
);

-- 11. CopyStatus
CREATE TABLE IF NOT EXISTS CopyStatus (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 12. Copy
CREATE TABLE IF NOT EXISTS Copy (
    id SERIAL PRIMARY KEY,
    book_id INT NOT NULL,
    copy_status_id INT DEFAULT 1,
    inventory_number VARCHAR(50) UNIQUE NOT NULL,
    acquired_date DATE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (book_id) REFERENCES Book(id),
    FOREIGN KEY (copy_status_id) REFERENCES CopyStatus(id)
);

-- 13. ReaderStatus
CREATE TABLE IF NOT EXISTS ReaderStatus (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 14. Reader
CREATE TABLE IF NOT EXISTS Reader (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(20),
    registration_date DATE DEFAULT CURRENT_DATE,
    reader_status_id INT DEFAULT 1,
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (reader_status_id) REFERENCES ReaderStatus(id)
);

-- 15. Roles
CREATE TABLE IF NOT EXISTS Roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 16. EmployeeStatus
CREATE TABLE IF NOT EXISTS EmployeeStatus (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 17. Employees
CREATE TABLE IF NOT EXISTS Employees (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(20),
    hire_date DATE,
    role_id INT,
    employee_status_id INT DEFAULT 1,
    login VARCHAR(100) UNIQUE,
    password_hash VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES Roles(id),
    FOREIGN KEY (employee_status_id) REFERENCES EmployeeStatus(id)
);

-- 18. Reception
CREATE TABLE IF NOT EXISTS Reception (
    id SERIAL PRIMARY KEY,
    operation_type VARCHAR(10) NOT NULL CHECK (operation_type IN ('borrow', 'return')),
    copy_id INT NOT NULL,
    reader_id INT NOT NULL,
    employee_id INT NOT NULL,
    operation_date DATE NOT NULL,
    due_date DATE,
    fine_amount DECIMAL(10,2) DEFAULT 0.00,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (copy_id) REFERENCES Copy(id),
    FOREIGN KEY (reader_id) REFERENCES Reader(id),
    FOREIGN KEY (employee_id) REFERENCES Employees(id)
);
