-- ============================================
-- БАЗА ДАННЫХ БИБЛИОТЕКИ
-- Часть 2: Индексы
-- ============================================

-- Индексы для таблицы EmployeeStatus
CREATE INDEX idx_employeestatus_name ON EmployeeStatus(name);
CREATE INDEX idx_employeestatus_created_at ON EmployeeStatus(created_at);

-- Индексы для таблицы Roles
CREATE INDEX idx_roles_name ON Roles(name);
CREATE INDEX idx_roles_created_at ON Roles(created_at);

-- Индексы для таблицы Employee
CREATE INDEX idx_employee_last_name ON Employee(last_name);
CREATE INDEX idx_employee_first_name ON Employee(first_name);
CREATE INDEX idx_employee_full_name ON Employee(last_name, first_name, patronymic);
CREATE INDEX idx_employee_email ON Employee(email);
CREATE INDEX idx_employee_phone ON Employee(phone);
CREATE INDEX idx_employee_login ON Employee(login);
CREATE INDEX idx_employee_role ON Employee(role);
CREATE INDEX idx_employee_status_id ON Employee(employee_status_id);
CREATE INDEX idx_employee_hire_date ON Employee(hire_date);
CREATE INDEX idx_employee_birth_date ON Employee(birth_date);
CREATE INDEX idx_employee_created_at ON Employee(created_at);

-- Индексы для таблицы ReaderStatus
CREATE INDEX idx_readerstatus_name ON ReaderStatus(name);
CREATE INDEX idx_readerstatus_created_at ON ReaderStatus(created_at);

-- Индексы для таблицы Reader
CREATE INDEX idx_reader_last_name ON Reader(last_name);
CREATE INDEX idx_reader_first_name ON Reader(first_name);
CREATE INDEX idx_reader_full_name ON Reader(last_name, first_name, patronymic);
CREATE INDEX idx_reader_email ON Reader(email);
CREATE INDEX idx_reader_phone ON Reader(phone);
CREATE INDEX idx_reader_status_id ON Reader(reader_status_id);
CREATE INDEX idx_reader_birth_date ON Reader(birth_date);
CREATE INDEX idx_reader_created_at ON Reader(created_at);

-- Индексы для таблицы CopyStatus
CREATE INDEX idx_copystatus_name ON CopyStatus(name);
CREATE INDEX idx_copystatus_created_at ON CopyStatus(created_at);

-- Индексы для таблицы Publisher
CREATE INDEX idx_publisher_name ON Publisher(name);
CREATE INDEX idx_publisher_contact_email ON Publisher(contact_email);
CREATE INDEX idx_publisher_address ON Publisher(address);
CREATE INDEX idx_publisher_created_at ON Publisher(created_at);

-- Индексы для таблицы Book
CREATE INDEX idx_book_title ON Book(title);
CREATE INDEX idx_book_isbn ON Book(isbn);
CREATE INDEX idx_book_publisher_id ON Book(publisher_id);
CREATE INDEX idx_book_publication_year ON Book(publication_year);
CREATE INDEX idx_book_page_count ON Book(page_count);
CREATE INDEX idx_book_title_publisher ON Book(title, publisher_id);
CREATE INDEX idx_book_created_at ON Book(created_at);

-- Индексы для таблицы Copy
CREATE INDEX idx_copy_book_id ON Copy(book_id);
CREATE INDEX idx_copy_status_id ON Copy(copy_status_id);
CREATE INDEX idx_copy_inventory_number ON Copy(inventory_number);
CREATE INDEX idx_copy_acquired_at ON Copy(acquired_at);
CREATE INDEX idx_copy_book_status ON Copy(book_id, copy_status_id);
CREATE INDEX idx_copy_created_at ON Copy(created_at);

-- Индексы для таблицы Tags
CREATE INDEX idx_tags_name ON Tags(name);
CREATE INDEX idx_tags_created_at ON Tags(created_at);

-- Индексы для таблицы BookTag
CREATE INDEX idx_booktag_book_id ON BookTag(book_id);
CREATE INDEX idx_booktag_tag_id ON BookTag(tag_id);
CREATE INDEX idx_booktag_book_id_tag_id ON BookTag(book_id, tag_id);
CREATE INDEX idx_booktag_created_at ON BookTag(created_at);

-- Индексы для таблицы Form
CREATE INDEX idx_form_name ON Form(name);
CREATE INDEX idx_form_created_at ON Form(created_at);

-- Индексы для таблицы BookForm
CREATE INDEX idx_bookform_book_id ON BookForm(book_id);
CREATE INDEX idx_bookform_form_id ON BookForm(form_id);
CREATE INDEX idx_bookform_book_id_form_id ON BookForm(book_id, form_id);
CREATE INDEX idx_bookform_created_at ON BookForm(created_at);

-- Индексы для таблицы Genre
CREATE INDEX idx_genre_name ON Genre(name);
CREATE INDEX idx_genre_created_at ON Genre(created_at);

-- Индексы для таблицы BookGenre
CREATE INDEX idx_bookgenre_book_id ON BookGenre(book_id);
CREATE INDEX idx_bookgenre_genre_id ON BookGenre(genre_id);
CREATE INDEX idx_bookgenre_book_id_genre_id ON BookGenre(book_id, genre_id);
CREATE INDEX idx_bookgenre_created_at ON BookGenre(created_at);

-- Индексы для таблицы Author
CREATE INDEX idx_author_last_name ON Author(last_name);
CREATE INDEX idx_author_first_name ON Author(first_name);
CREATE INDEX idx_author_full_name ON Author(last_name, first_name, patronymic);
CREATE INDEX idx_author_country ON Author(country);
CREATE INDEX idx_author_birth_date ON Author(birth_date);
CREATE INDEX idx_author_death_date ON Author(death_date);
CREATE INDEX idx_author_created_at ON Author(created_at);

-- Индексы для таблицы Composition
CREATE INDEX idx_composition_title ON Composition(title);
CREATE INDEX idx_composition_language ON Composition(language);
CREATE INDEX idx_composition_original_language ON Composition(original_language);
CREATE INDEX idx_composition_created_at ON Composition(created_at);

-- Индексы для таблицы Authorship
CREATE INDEX idx_authorship_composition_id ON Authorship(composition_id);
CREATE INDEX idx_authorship_author_id ON Authorship(author_id);
CREATE INDEX idx_authorship_role ON Authorship(role);
CREATE INDEX idx_authorship_composition_id_author_id ON Authorship(composition_id, author_id);
CREATE INDEX idx_authorship_created_at ON Authorship(created_at);

-- Индексы для таблицы BookComposition
CREATE INDEX idx_bookcomposition_composition_id ON BookComposition(composition_id);
CREATE INDEX idx_bookcomposition_book_id ON BookComposition(book_id);
CREATE INDEX idx_bookcomposition_position ON BookComposition(position_in_book);
CREATE INDEX idx_bookcomposition_composition_book ON BookComposition(composition_id, book_id);
CREATE INDEX idx_bookcomposition_created_at ON BookComposition(created_at);

-- Индексы для таблицы Loan
CREATE INDEX idx_loan_copy_id ON Loan(copy_id);
CREATE INDEX idx_loan_reader_id ON Loan(reader_id);
CREATE INDEX idx_loan_employee_id ON Loan(employee_id);
CREATE INDEX idx_loan_due_date ON Loan(due_date);
CREATE INDEX idx_loan_copy_reader ON Loan(copy_id, reader_id);
CREATE INDEX idx_loan_reader_employee ON Loan(reader_id, employee_id);
CREATE INDEX idx_loan_created_at ON Loan(created_at);

-- Индексы для таблицы Return
CREATE INDEX idx_return_loan_id ON Return(loan_id);
CREATE INDEX idx_return_employee_id ON Return(employee_id);
CREATE INDEX idx_return_created_at ON Return(created_at);

-- Индексы для таблицы FineReason
CREATE INDEX idx_finereason_name ON FineReason(name);
CREATE INDEX idx_finereason_created_at ON FineReason(created_at);

-- Индексы для таблицы Fine
CREATE INDEX idx_fine_loan_id ON Fine(loan_id);
CREATE INDEX idx_fine_reason_id ON Fine(reason_id);
CREATE INDEX idx_fine_created_at ON Fine(created_at);
