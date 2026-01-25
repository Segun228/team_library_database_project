-- ============================================
-- БАЗА ДАННЫХ БИБЛИОТЕКИ
-- Часть 1: Создание таблиц
-- ============================================

-- 1. EmployeeStatus
CREATE TABLE IF NOT EXISTS EmployeeStatus (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Roles
CREATE TABLE IF NOT EXISTS Roles (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Employee
-- Добавлены обязательные поля согласно требованиям
CREATE TABLE IF NOT EXISTS Employee (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(127) NOT NULL,
    last_name VARCHAR(127) NOT NULL,
    patronymic VARCHAR(127),
    birth_date DATE NOT NULL,
    hire_date DATE NOT NULL,
    employee_status_id INT NOT NULL,
    address TEXT NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(30) NOT NULL,
    login VARCHAR(200) UNIQUE NOT NULL,
    role INT NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (employee_status_id) REFERENCES EmployeeStatus(id),
    FOREIGN KEY (role) REFERENCES Roles(id)
);

-- 4. ReaderStatus
CREATE TABLE IF NOT EXISTS ReaderStatus (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. Reader
-- Добавлены обязательные поля согласно требованиям
CREATE TABLE IF NOT EXISTS Reader (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(127) NOT NULL,
    last_name VARCHAR(127) NOT NULL,
    patronymic VARCHAR(127),
    birth_date DATE NOT NULL,
    reader_status_id INT NOT NULL,
    address TEXT NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(30) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (reader_status_id) REFERENCES ReaderStatus(id)
);

-- 6. CopyStatus
CREATE TABLE IF NOT EXISTS CopyStatus (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 7. Publisher
-- Добавлены обязательные поля согласно требованиям
CREATE TABLE IF NOT EXISTS Publisher (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    address TEXT NOT NULL,
    contact_phone VARCHAR(20) NOT NULL,
    contact_email VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 8. Book
-- Добавлены обязательные поля согласно требованиям
CREATE TABLE IF NOT EXISTS Book (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    publisher_id INT NOT NULL,
    isbn VARCHAR(20) UNIQUE NOT NULL,
    publication_year INTEGER NOT NULL,
    page_count INT NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (publisher_id) REFERENCES Publisher(id)
);

-- 9. Copy
CREATE TABLE IF NOT EXISTS Copy (
    id SERIAL PRIMARY KEY,
    book_id INT NOT NULL,
    copy_status_id INT NOT NULL,
    inventory_number VARCHAR(50) UNIQUE NOT NULL,
    acquired_at DATE NOT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (book_id) REFERENCES Book(id),
    FOREIGN KEY (copy_status_id) REFERENCES CopyStatus(id)
);

-- 10. Tags
CREATE TABLE IF NOT EXISTS Tags (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 11. BookTag
CREATE TABLE IF NOT EXISTS BookTag (
    id SERIAL PRIMARY KEY,
    book_id INT NOT NULL,
    tag_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (book_id) REFERENCES Book(id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES Tags(id) ON DELETE CASCADE,
    UNIQUE(book_id, tag_id)
);

-- 12. Form
CREATE TABLE IF NOT EXISTS Form (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 13. BookForm
CREATE TABLE IF NOT EXISTS BookForm (
    id SERIAL PRIMARY KEY,
    book_id INT NOT NULL,
    form_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (book_id) REFERENCES Book(id) ON DELETE CASCADE,
    FOREIGN KEY (form_id) REFERENCES Form(id) ON DELETE CASCADE,
    UNIQUE(book_id, form_id)
);

-- 14. Genre
CREATE TABLE IF NOT EXISTS Genre (
    id SERIAL PRIMARY KEY,
    name VARCHAR(400) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 15. BookGenre
CREATE TABLE IF NOT EXISTS BookGenre (
    id SERIAL PRIMARY KEY,
    book_id INT NOT NULL,
    genre_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (book_id) REFERENCES Book(id) ON DELETE CASCADE,
    FOREIGN KEY (genre_id) REFERENCES Genre(id) ON DELETE CASCADE,
    UNIQUE(book_id, genre_id)
);

-- 16. Author
CREATE TABLE IF NOT EXISTS Author (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    patronymic VARCHAR(255),
    birth_date DATE,
    death_date DATE,
    country VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 17. Composition
CREATE TABLE IF NOT EXISTS Composition (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    language VARCHAR(50),
    original_language VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 18. Authorship
CREATE TABLE IF NOT EXISTS Authorship (
    id SERIAL PRIMARY KEY,
    composition_id INT NOT NULL,
    author_id INT NOT NULL,
    role VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (composition_id) REFERENCES Composition(id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES Author(id) ON DELETE CASCADE,
    UNIQUE(composition_id, author_id, role)
);

-- 19. BookComposition
-- Убрали ON DELETE CASCADE для composition_id: нельзя удалять произведение, если книга осталась
CREATE TABLE IF NOT EXISTS BookComposition (
    id SERIAL PRIMARY KEY,
    composition_id INT NOT NULL,
    book_id INT NOT NULL,
    position_in_book INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (composition_id) REFERENCES Composition(id) ON DELETE RESTRICT,
    FOREIGN KEY (book_id) REFERENCES Book(id) ON DELETE CASCADE,
    UNIQUE(composition_id, book_id)
);

-- 20. Loan
-- Изменены внешние ключи: ON DELETE SET NULL для сохранения истории выдачи
-- (нельзя терять информацию о выданных книгах при удалении записей)
CREATE TABLE IF NOT EXISTS Loan (
    id SERIAL PRIMARY KEY,
    copy_id INT,
    reader_id INT,
    employee_id INT,
    due_date DATE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (copy_id) REFERENCES Copy(id) ON DELETE SET NULL,
    FOREIGN KEY (reader_id) REFERENCES Reader(id) ON DELETE SET NULL,
    FOREIGN KEY (employee_id) REFERENCES Employee(id) ON DELETE SET NULL
);

-- 21. BookReturn (переименовано из Return, так как Return - ключевое слово PostgreSQL)
CREATE TABLE IF NOT EXISTS BookReturn (
    id SERIAL PRIMARY KEY,
    loan_id INT NOT NULL,
    employee_id INT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (loan_id) REFERENCES Loan(id) ON DELETE RESTRICT,
    FOREIGN KEY (employee_id) REFERENCES Employee(id) ON DELETE SET NULL,
    UNIQUE(loan_id)
);

-- 22. FineReason
CREATE TABLE IF NOT EXISTS FineReason (
    id SERIAL PRIMARY KEY,
    name VARCHAR(300) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 23. Fine
-- Убран UNIQUE(loan_id): может быть несколько штрафов за одну выдачу
CREATE TABLE IF NOT EXISTS Fine (
    id SERIAL PRIMARY KEY,
    loan_id INT NOT NULL,
    notes TEXT,
    reason_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (loan_id) REFERENCES Loan(id) ON DELETE RESTRICT,
    FOREIGN KEY (reason_id) REFERENCES FineReason(id) ON DELETE RESTRICT
);
