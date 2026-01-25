-- ============================================
-- БАЗА ДАННЫХ БИБЛИОТЕКИ
-- Часть 6: Запросы (CRUD и аналитика)
-- ============================================

-- ============================================
-- CRUD-ОПЕРАЦИИ
-- ============================================

-- Создание нового жанра
INSERT INTO Genre (name, description)
VALUES ('Фантастика', 'Книги о вымышленных мирах и технологиях');

-- Чтение информации о жанре по ID
SELECT * FROM Genre WHERE id = 1;

-- Обновление описания жанра
UPDATE Genre
SET description = 'Книги о вымышленных мирах, технологиях и будущем'
WHERE id = 1;

-- Создание нового автора
INSERT INTO Author (first_name, last_name, patronymic, birth_date, country)
VALUES ('Иван', 'Иванов', 'Петрович', '1970-01-01', 'Россия');

-- Получение списка всех авторов
SELECT * FROM Author;

-- Обновление информации об авторе
UPDATE Author
SET country = 'Беларусь'
WHERE id = 1;

-- Создание новой выдачи книги
INSERT INTO Loan (copy_id, reader_id, employee_id, due_date, notes)
VALUES (1, 1, 2, CURRENT_DATE + INTERVAL '14 days', 'Выдача по абонементу');

-- Возврат книги
INSERT INTO BookReturn (loan_id, employee_id, notes)
VALUES (1, 2, 'Возврат в срок');

-- ============================================
-- АНАЛИТИЧЕСКИЕ ЗАПРОСЫ
-- ============================================
-- ВНИМАНИЕ: Аналитические запросы оформлены как представления (VIEW)
-- в файле 07_views.sql. Здесь приведены примеры использования представлений.

-- Использование представлений:
-- SELECT * FROM v_books_by_genre;
-- SELECT * FROM v_popular_authors;
-- SELECT * FROM v_current_loans;
-- SELECT * FROM v_readers_with_overdue_books;

-- Примеры запросов к представлениям:

-- Количество книг по каждому жанру (используя представление)
SELECT * FROM v_books_by_genre;

-- Список самых популярных авторов (используя представление)
SELECT * FROM v_popular_authors;

-- Количество экземпляров книг, сгруппированное по статусу копии (используя представление)
SELECT * FROM v_copies_by_status;

-- Поиск книги по ISBN
SELECT * FROM Book WHERE isbn = '978-5-699-12345-1';

-- Получение информации о читателе по email
SELECT * FROM Reader WHERE email = 'ivan.petrov@mail.ru';

-- Список всех доступных (не выданных) книг (используя представление)
SELECT * FROM v_available_books;

-- Список текущих выдач (книги на руках у читателей) (используя представление)
SELECT * FROM v_current_loans;

-- Список книг с указанием их жанров (используя представление)
SELECT * FROM v_books_with_genres;

-- Ранжирование авторов по количеству книг (используя представление)
SELECT * FROM v_authors_ranking;

-- Список читателей, которые взяли книги определённого жанра (используя представление)
SELECT * FROM v_readers_by_genre WHERE genre_name = 'Фантастика';

-- Вывод списка выдач с указанием количества операций для каждой книги (используя представление)
SELECT * FROM v_loans_with_book_statistics;

-- Вывод количества книг по каждому издателю (используя представление)
SELECT * FROM v_publishers_with_many_books;

-- Список книг с указанием количества их экземпляров и статусом доступности (используя представление)
SELECT * FROM v_books_availability;

-- Определение количества тегов у каждой книги (используя представление)
SELECT * FROM v_books_tag_count;

-- Ранжирование книг по количеству экземпляров (используя представление)
SELECT * FROM v_books_by_copy_count;

-- Поиск читателей, которые взяли книги, опубликованные после среднего года (используя представление)
SELECT * FROM v_readers_with_recent_books;

-- Жанры, у которых количество книг превышает среднее значение (используя представление)
SELECT * FROM v_genres_above_average;

-- Список всех выданных книг с информацией о читателях и сотрудниках (используя представление)
SELECT * FROM v_all_loans_info;

-- Статистика по штрафам (используя представление)
SELECT * FROM v_fines_statistics;

-- Список книг с их формами изданий (используя представление)
SELECT * FROM v_books_with_forms;

-- Топ-10 самых читаемых книг (используя представление)
SELECT * FROM v_top_books_by_loans;

-- Читатели с просроченными книгами (используя представление)
SELECT * FROM v_readers_with_overdue_books;

-- Количество произведений у каждого автора (используя представление)
SELECT * FROM v_authors_composition_count;

-- Список сотрудников с их ролями и статусами (используя представление)
SELECT * FROM v_employees_with_roles;

-- Статистика по читателям по статусам (используя представление)
SELECT * FROM v_readers_by_status;
