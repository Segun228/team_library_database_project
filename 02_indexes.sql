-- ============================================
-- БАЗА ДАННЫХ БИБЛИОТЕКИ
-- Часть 2: Индексы
-- ============================================

-- Индексы для таблицы Genre
CREATE INDEX idx_genre_name ON Genre(name);
CREATE INDEX idx_genre_created_at ON Genre(created_at);

-- Индексы для таблицы Publisher
CREATE INDEX idx_publisher_name ON Publisher(name);
CREATE INDEX idx_publisher_contact_email ON Publisher(contact_email);
CREATE INDEX idx_publisher_address ON Publisher(address);

-- Индексы для таблицы Author
CREATE INDEX idx_author_last_name ON Author(last_name);
CREATE INDEX idx_author_first_name ON Author(first_name);
CREATE INDEX idx_author_first_name_last_name ON Author(first_name, last_name);
CREATE INDEX idx_author_country ON Author(country);
CREATE INDEX idx_author_birth_date ON Author(birth_date);
CREATE INDEX idx_author_death_date ON Author(death_date);

-- Индексы для таблицы Composition
CREATE INDEX idx_composition_title ON Composition(title);
CREATE INDEX idx_composition_year_written ON Composition(year_written);
CREATE INDEX idx_composition_language ON Composition(original_language);
CREATE INDEX idx_composition_created_at ON Composition(created_at);

-- Индексы для таблицы Authorship
CREATE INDEX idx_authorship_composition_id ON Authorship(composition_id);
CREATE INDEX idx_authorship_author_id ON Authorship(author_id);
CREATE INDEX idx_authorship_role ON Authorship(role);
CREATE INDEX idx_authorship_composition_id_author_id ON Authorship(composition_id, author_id);

-- Индексы для таблицы Book
CREATE INDEX idx_book_title ON Book(title);
CREATE INDEX idx_book_isbn ON Book(isbn);
CREATE INDEX idx_book_publisher_id ON Book(publisher_id);
CREATE INDEX idx_book_publication_year ON Book(publication_year);
CREATE INDEX idx_book_page_count ON Book(page_count);
CREATE INDEX idx_book_created_at ON Book(created_at);
CREATE INDEX idx_book_title_publisher ON Book(title, publisher_id);

-- Индексы для таблицы Form
CREATE INDEX idx_form_name ON Form(name);
CREATE INDEX idx_form_created_at ON Form(created_at);

-- Индексы для таблицы BookForm
CREATE INDEX idx_bookform_book_id ON BookForm(book_id);
CREATE INDEX idx_bookform_form_id ON BookForm(form_id);
CREATE INDEX idx_bookform_book_id_form_id ON BookForm(book_id, form_id);
CREATE INDEX idx_bookform_created_at ON BookForm(created_at);

-- Индексы для таблицы BookComposition
CREATE INDEX idx_bookcomposition_book_id ON BookComposition(book_id);
CREATE INDEX idx_bookcomposition_composition_id ON BookComposition(composition_id);
CREATE INDEX idx_bookcomposition_book_id_composition_id ON BookComposition(book_id, composition_id);
CREATE INDEX idx_bookcomposition_position ON BookComposition(position_in_book);

-- Индексы для таблицы Tags
CREATE INDEX idx_tags_name ON Tags(name);
CREATE INDEX idx_tags_created_at ON Tags(created_at);

-- Индексы для таблицы BookTag
CREATE INDEX idx_booktag_book_id ON BookTag(book_id);
CREATE INDEX idx_booktag_tag_id ON BookTag(tag_id);
CREATE INDEX idx_booktag_book_id_tag_id ON BookTag(book_id, tag_id);

-- Индексы для таблицы BookGenre
CREATE INDEX idx_bookgenre_book_id ON BookGenre(book_id);
CREATE INDEX idx_bookgenre_genre_id ON BookGenre(genre_id);
CREATE INDEX idx_bookgenre_book_id_genre_id ON BookGenre(book_id, genre_id);

-- Индексы для таблицы CopyStatus
CREATE INDEX idx_copystatus_name ON CopyStatus(name);

-- Индексы для таблицы Copy
CREATE INDEX idx_copy_book_id ON Copy(book_id);
CREATE INDEX idx_copy_status_id ON Copy(copy_status_id);
CREATE INDEX idx_copy_inventory_number ON Copy(inventory_number);
CREATE INDEX idx_copy_acquired_date ON Copy(acquired_date);
CREATE INDEX idx_copy_book_status ON Copy(book_id, copy_status_id);
CREATE INDEX idx_copy_created_at ON Copy(created_at);

-- Индексы для таблицы ReaderStatus
CREATE INDEX idx_readerstatus_name ON ReaderStatus(name);

-- Индексы для таблицы Reader
CREATE INDEX idx_reader_last_name ON Reader(last_name);
CREATE INDEX idx_reader_first_name ON Reader(first_name);
CREATE INDEX idx_reader_full_name ON Reader(last_name, first_name);
CREATE INDEX idx_reader_email ON Reader(email);
CREATE INDEX idx_reader_phone ON Reader(phone);
CREATE INDEX idx_reader_status_id ON Reader(reader_status_id);
CREATE INDEX idx_reader_registration_date ON Reader(registration_date);
CREATE INDEX idx_reader_created_at ON Reader(created_at);

-- Индексы для таблицы Roles
CREATE INDEX idx_roles_name ON Roles(name);

-- Индексы для таблицы EmployeeStatus
CREATE INDEX idx_employeestatus_name ON EmployeeStatus(name);

-- Индексы для таблицы Employees
CREATE INDEX idx_employees_last_name ON Employees(last_name);
CREATE INDEX idx_employees_first_name ON Employees(first_name);
CREATE INDEX idx_employees_full_name ON Employees(last_name, first_name);
CREATE INDEX idx_employees_email ON Employees(email);
CREATE INDEX idx_employees_email_login ON Employees(email, login);
CREATE INDEX idx_employees_role_id ON Employees(role_id);
CREATE INDEX idx_employees_status_id ON Employees(employee_status_id);
CREATE INDEX idx_employees_hire_date ON Employees(hire_date);
CREATE INDEX idx_employees_login ON Employees(login);
CREATE INDEX idx_employees_created_at ON Employees(created_at);

-- Индексы для таблицы Reception
CREATE INDEX idx_reception_operation_type ON Reception(operation_type);
CREATE INDEX idx_reception_copy_id ON Reception(copy_id);
CREATE INDEX idx_reception_reader_id ON Reception(reader_id);
CREATE INDEX idx_reception_employee_id ON Reception(employee_id);
CREATE INDEX idx_reception_copy_id_reader_id_employee_id ON Reception(copy_id, reader_id, employee_id);
CREATE INDEX idx_reception_operation_date ON Reception(operation_date);
CREATE INDEX idx_reception_due_date ON Reception(due_date);
CREATE INDEX idx_reception_fine_amount ON Reception(fine_amount);
CREATE INDEX idx_reception_reader_operation ON Reception(reader_id, operation_type);
CREATE INDEX idx_reception_copy_operation ON Reception(copy_id, operation_type);
CREATE INDEX idx_reception_date_range ON Reception(operation_date, due_date);
CREATE INDEX idx_reception_created_at ON Reception(created_at);
