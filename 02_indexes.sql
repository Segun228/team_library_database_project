-- ============================================
-- БАЗА ДАННЫХ БИБЛИОТЕКИ
-- Часть 2: Индексы
-- ============================================

-- Индексы для таблицы EmployeeStatus
CREATE INDEX idx_employeestatus_created_at ON EmployeeStatus(created_at);

-- Индексы для таблицы Roles
CREATE INDEX idx_roles_created_at ON Roles(created_at);

-- Индексы для таблицы Employee
CREATE INDEX idx_employee_full_name ON Employee(last_name, first_name, patronymic);
CREATE INDEX idx_employee_role_status ON Employee(role, employee_status_id);
CREATE INDEX idx_employee_hire_date ON Employee(hire_date);
CREATE INDEX idx_employee_created_at ON Employee(created_at);

-- Индексы для таблицы ReaderStatus
CREATE INDEX idx_readerstatus_created_at ON ReaderStatus(created_at);

-- Индексы для таблицы Reader
CREATE INDEX idx_reader_full_name ON Reader(last_name, first_name, patronymic);
CREATE INDEX idx_reader_status_id ON Reader(reader_status_id);
CREATE INDEX idx_reader_created_at ON Reader(created_at);

-- Индексы для таблицы CopyStatus
CREATE INDEX idx_copystatus_created_at ON CopyStatus(created_at);

-- Индексы для таблицы Publisher
CREATE INDEX idx_publisher_name ON Publisher(name);
CREATE INDEX idx_publisher_contact_email ON Publisher(contact_email);
CREATE INDEX idx_publisher_address ON Publisher(address);
CREATE INDEX idx_publisher_created_at ON Publisher(created_at);

-- Индексы для таблицы Book
CREATE INDEX idx_book_title_publisher ON Book(title, publisher_id);
CREATE INDEX idx_book_publisher_year ON Book(publisher_id, publication_year);
CREATE INDEX idx_book_created_at ON Book(created_at);

-- Индексы для таблицы Copy
CREATE INDEX idx_copy_book_status ON Copy(book_id, copy_status_id);
CREATE INDEX idx_copy_acquired_at ON Copy(acquired_at);
CREATE INDEX idx_copy_created_at ON Copy(created_at);

-- Индексы для таблицы Tags
CREATE INDEX idx_tags_created_at ON Tags(created_at);

-- Индексы для таблицы BookTag
CREATE INDEX idx_booktag_created_at ON BookTag(created_at);

-- Индексы для таблицы Form
CREATE INDEX idx_form_created_at ON Form(created_at);

-- Индексы для таблицы BookForm
CREATE INDEX idx_bookform_created_at ON BookForm(created_at);

-- Индексы для таблицы Genre
CREATE INDEX idx_genre_created_at ON Genre(created_at);

-- Индексы для таблицы BookGenre
CREATE INDEX idx_bookgenre_created_at ON BookGenre(created_at);

-- Индексы для таблицы Author
CREATE INDEX idx_author_full_name ON Author(last_name, first_name, patronymic);
CREATE INDEX idx_author_country_birth ON Author(country, birth_date);
CREATE INDEX idx_author_created_at ON Author(created_at);

-- Индексы для таблицы Composition
CREATE INDEX idx_composition_title ON Composition(title);
CREATE INDEX idx_composition_language ON Composition(language);
CREATE INDEX idx_composition_original_language ON Composition(original_language);
CREATE INDEX idx_composition_created_at ON Composition(created_at);

-- Индексы для таблицы Authorship
CREATE INDEX idx_authorship_created_at ON Authorship(created_at);

-- Индексы для таблицы BookComposition
CREATE INDEX idx_bookcomposition_position ON BookComposition(position_in_book);
CREATE INDEX idx_bookcomposition_created_at ON BookComposition(created_at);

-- Индексы для таблицы Loan
CREATE INDEX idx_loan_copy_id ON Loan(copy_id);
CREATE INDEX idx_loan_reader_id ON Loan(reader_id);
CREATE INDEX idx_loan_employee_id ON Loan(employee_id);
CREATE INDEX idx_loan_due_date ON Loan(due_date);
CREATE INDEX idx_loan_copy_reader ON Loan(copy_id, reader_id);
CREATE INDEX idx_loan_reader_employee ON Loan(reader_id, employee_id);
CREATE INDEX idx_loan_created_at ON Loan(created_at);

CREATE INDEX idx_bookreturn_employee_id ON BookReturn(employee_id);
CREATE INDEX idx_bookreturn_created_at ON BookReturn(created_at);

-- Индексы для таблицы FineReason
CREATE INDEX idx_finereason_created_at ON FineReason(created_at);

-- Индексы для таблицы Fine
CREATE INDEX idx_fine_loan_id ON Fine(loan_id);
CREATE INDEX idx_fine_reason_id ON Fine(reason_id);
CREATE INDEX idx_fine_created_at ON Fine(created_at);
