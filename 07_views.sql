-- ============================================
-- БАЗА ДАННЫХ БИБЛИОТЕКИ
-- Часть 7: Представления (Views) для аналитических запросов
-- ============================================

-- ============================================
-- ПРЕДСТАВЛЕНИЯ ДЛЯ АНАЛИТИКИ
-- ============================================

-- 1. Количество книг по каждому жанру
CREATE OR REPLACE VIEW v_books_by_genre AS
SELECT 
    g.id AS genre_id,
    g.name AS genre_name,
    COUNT(bg.book_id) AS book_count
FROM Genre g
LEFT JOIN BookGenre bg ON g.id = bg.genre_id
GROUP BY g.id, g.name
ORDER BY book_count DESC;

-- 2. Список самых популярных авторов (по количеству книг в библиотеке)
CREATE OR REPLACE VIEW v_popular_authors AS
SELECT 
    a.id AS author_id,
    a.first_name, 
    a.last_name, 
    a.patronymic,
    COUNT(DISTINCT b.id) AS book_count
FROM Author a
JOIN Authorship au ON a.id = au.author_id
JOIN Composition c ON au.composition_id = c.id
JOIN BookComposition bc ON c.id = bc.composition_id
JOIN Book b ON bc.book_id = b.id
GROUP BY a.id, a.first_name, a.last_name, a.patronymic
ORDER BY book_count DESC;

-- 3. Количество экземпляров книг, сгруппированное по статусу копии
CREATE OR REPLACE VIEW v_copies_by_status AS
SELECT 
    cs.id AS status_id,
    cs.name AS status_name,
    COUNT(c.id) AS copy_count
FROM CopyStatus cs
LEFT JOIN Copy c ON cs.id = c.copy_status_id
GROUP BY cs.id, cs.name
ORDER BY copy_count DESC;

-- 4. Список всех доступных (не выданных) книг
CREATE OR REPLACE VIEW v_available_books AS
SELECT DISTINCT 
    b.id,
    b.title,
    b.isbn,
    b.publication_year,
    b.page_count,
    b.description,
    p.name AS publisher_name
FROM Book b
JOIN Copy c ON b.id = c.book_id
JOIN CopyStatus cs ON c.copy_status_id = cs.id
LEFT JOIN Publisher p ON b.publisher_id = p.id
WHERE cs.name = 'Доступен'
ORDER BY b.title;

-- 5. Список текущих выдач (книги на руках у читателей)
CREATE OR REPLACE VIEW v_current_loans AS
SELECT 
    l.id AS loan_id,
    r.id AS reader_id,
    r.first_name || ' ' || r.last_name AS reader_name,
    b.id AS book_id,
    b.title AS book_title,
    c.inventory_number,
    l.due_date,
    CASE 
        WHEN l.due_date < CURRENT_DATE THEN 'Просрочено'
        WHEN l.due_date = CURRENT_DATE THEN 'Сегодня'
        ELSE 'В срок'
    END AS status,
    CURRENT_DATE - l.due_date AS days_overdue
FROM Loan l
JOIN Reader r ON l.reader_id = r.id
JOIN Copy c ON l.copy_id = c.id
JOIN Book b ON c.book_id = b.id
WHERE NOT EXISTS (
    SELECT 1 FROM BookReturn ret WHERE ret.loan_id = l.id
)
ORDER BY l.due_date;

-- 6. Список книг с указанием их жанров
CREATE OR REPLACE VIEW v_books_with_genres AS
SELECT 
    b.id AS book_id,
    b.title,
    STRING_AGG(g.name, ', ' ORDER BY g.name) AS genres
FROM Book b
JOIN BookGenre bg ON b.id = bg.book_id
JOIN Genre g ON bg.genre_id = g.id
WHERE b.publication_year > 2000
GROUP BY b.id, b.title
ORDER BY b.title;

-- 7. Ранжирование авторов по количеству книг
CREATE OR REPLACE VIEW v_authors_ranking AS
SELECT 
    a.id AS author_id,
    a.first_name, 
    a.last_name, 
    a.patronymic,
    COUNT(DISTINCT b.id) AS book_count,
    RANK() OVER (ORDER BY COUNT(DISTINCT b.id) DESC) AS rank_by_book_count
FROM Author a
JOIN Authorship au ON a.id = au.author_id
JOIN Composition c ON au.composition_id = c.id
JOIN BookComposition bc ON c.id = bc.composition_id
JOIN Book b ON bc.book_id = b.id
GROUP BY a.id, a.first_name, a.last_name, a.patronymic
ORDER BY rank_by_book_count;

-- 8. Список читателей, которые взяли книги определённого жанра
CREATE OR REPLACE VIEW v_readers_by_genre AS
SELECT DISTINCT 
    r.id AS reader_id,
    r.first_name, 
    r.last_name, 
    r.patronymic,
    g.id AS genre_id,
    g.name AS genre_name
FROM Reader r
JOIN Loan l ON r.id = l.reader_id
JOIN Copy c ON l.copy_id = c.id
JOIN Book b ON c.book_id = b.id
JOIN BookGenre bg ON b.id = bg.book_id
JOIN Genre g ON bg.genre_id = g.id
WHERE NOT EXISTS (SELECT 1 FROM BookReturn ret WHERE ret.loan_id = l.id)
ORDER BY r.last_name, g.name;

-- 9. Вывод списка выдач с указанием количества операций для каждой книги
CREATE OR REPLACE VIEW v_loans_with_book_statistics AS
SELECT 
    l.id AS loan_id,
    b.id AS book_id,
    b.title,
    l.due_date,
    COUNT(l.id) OVER (PARTITION BY b.id) AS total_loans_for_book
FROM Loan l
JOIN Copy c ON l.copy_id = c.id
JOIN Book b ON c.book_id = b.id
ORDER BY b.title, l.due_date;

-- 10. Вывод количества книг по каждому издателю (только издатели с более чем 5 книгами)
CREATE OR REPLACE VIEW v_publishers_with_many_books AS
SELECT 
    p.id AS publisher_id,
    p.name AS publisher_name,
    COUNT(b.id) AS book_count
FROM Publisher p
LEFT JOIN Book b ON p.id = b.publisher_id
GROUP BY p.id, p.name
HAVING COUNT(b.id) > 5
ORDER BY book_count DESC;

-- 11. Список книг с указанием количества их экземпляров и статусом доступности
CREATE OR REPLACE VIEW v_books_availability AS
WITH book_copies AS (
    SELECT 
        book_id, 
        COUNT(*) AS total_copies,
        SUM(CASE WHEN cs.name = 'Доступен' THEN 1 ELSE 0 END) AS available_copies
    FROM Copy c
    JOIN CopyStatus cs ON c.copy_status_id = cs.id
    GROUP BY book_id
)
SELECT 
    b.id AS book_id,
    b.title,
    bc.total_copies,
    bc.available_copies,
    bc.total_copies - bc.available_copies AS issued_copies
FROM Book b
JOIN book_copies bc ON b.id = bc.book_id
ORDER BY bc.available_copies DESC;

-- 12. Определение количества тегов у каждой книги
CREATE OR REPLACE VIEW v_books_tag_count AS
SELECT 
    b.id AS book_id,
    b.title,
    COUNT(bt.tag_id) AS tag_count
FROM Book b
LEFT JOIN BookTag bt ON b.id = bt.book_id
GROUP BY b.id, b.title
ORDER BY tag_count DESC;

-- 13. Ранжирование книг по количеству экземпляров
CREATE OR REPLACE VIEW v_books_by_copy_count AS
SELECT 
    b.id AS book_id,
    b.title, 
    c.id AS copy_id,
    c.inventory_number,
    RANK() OVER (PARTITION BY b.id ORDER BY c.inventory_number) AS copy_rank
FROM Book b
JOIN Copy c ON b.id = c.book_id
ORDER BY b.title, copy_rank;

-- 14. Поиск читателей, которые взяли книги, опубликованные после среднего года публикации
CREATE OR REPLACE VIEW v_readers_with_recent_books AS
SELECT DISTINCT 
    r.id AS reader_id,
    r.first_name, 
    r.last_name, 
    r.patronymic,
    AVG(b.publication_year) AS avg_publication_year
FROM Reader r
JOIN Loan l ON r.id = l.reader_id
JOIN Copy c ON l.copy_id = c.id
JOIN Book b ON c.book_id = b.id
WHERE b.publication_year > (SELECT AVG(publication_year) FROM Book WHERE publication_year IS NOT NULL)
GROUP BY r.id, r.first_name, r.last_name, r.patronymic
ORDER BY r.last_name;

-- 15. Жанры, у которых количество книг превышает среднее значение по всем жанрам
CREATE OR REPLACE VIEW v_genres_above_average AS
WITH genre_book_count AS (
    SELECT g.id, g.name, COUNT(bg.book_id) AS book_count
    FROM Genre g
    LEFT JOIN BookGenre bg ON g.id = bg.genre_id
    GROUP BY g.id, g.name
),
average_book_count AS (
    SELECT AVG(book_count) AS avg_count
    FROM genre_book_count
)
SELECT 
    gbc.id AS genre_id,
    gbc.name AS genre_name,
    gbc.book_count,
    abc.avg_count AS average_count
FROM genre_book_count gbc
CROSS JOIN average_book_count abc
WHERE gbc.book_count > abc.avg_count
ORDER BY gbc.book_count DESC;

-- 16. Список всех выданных книг с информацией о читателях и сотрудниках
CREATE OR REPLACE VIEW v_all_loans_info AS
SELECT 
    l.id AS loan_id,
    b.id AS book_id,
    b.title AS book_title,
    r.id AS reader_id,
    r.first_name || ' ' || r.last_name AS reader_name,
    e.id AS employee_id,
    e.first_name || ' ' || e.last_name AS employee_name,
    l.due_date,
    CASE 
        WHEN EXISTS (SELECT 1 FROM BookReturn ret WHERE ret.loan_id = l.id) THEN 'Возвращена'
        WHEN l.due_date < CURRENT_DATE THEN 'Просрочена'
        ELSE 'На руках'
    END AS status
FROM Loan l
JOIN Copy c ON l.copy_id = c.id
JOIN Book b ON c.book_id = b.id
JOIN Reader r ON l.reader_id = r.id
JOIN Employee e ON l.employee_id = e.id
ORDER BY l.due_date;

-- 17. Статистика по штрафам
CREATE OR REPLACE VIEW v_fines_statistics AS
SELECT 
    fr.id AS reason_id,
    fr.name AS reason,
    COUNT(f.id) AS fine_count
FROM FineReason fr
LEFT JOIN Fine f ON fr.id = f.reason_id
GROUP BY fr.id, fr.name
ORDER BY fine_count DESC;

-- 18. Список книг с их формами изданий
CREATE OR REPLACE VIEW v_books_with_forms AS
SELECT 
    b.id AS book_id,
    b.title,
    STRING_AGG(f.name, ', ' ORDER BY f.name) AS forms
FROM Book b
JOIN BookForm bf ON b.id = bf.book_id
JOIN Form f ON bf.form_id = f.id
GROUP BY b.id, b.title
ORDER BY b.title;

-- 19. Топ-10 самых читаемых книг (по количеству выдач)
CREATE OR REPLACE VIEW v_top_books_by_loans AS
SELECT 
    b.id AS book_id,
    b.title,
    COUNT(l.id) AS loan_count
FROM Book b
JOIN Copy c ON b.id = c.book_id
JOIN Loan l ON c.id = l.copy_id
GROUP BY b.id, b.title
ORDER BY loan_count DESC
LIMIT 10;

-- 20. Читатели с просроченными книгами
CREATE OR REPLACE VIEW v_readers_with_overdue_books AS
SELECT 
    r.id AS reader_id,
    r.first_name || ' ' || r.last_name AS reader_name,
    r.email,
    r.phone,
    b.id AS book_id,
    b.title AS book_title,
    l.id AS loan_id,
    l.due_date,
    CURRENT_DATE - l.due_date AS days_overdue
FROM Loan l
JOIN Reader r ON l.reader_id = r.id
JOIN Copy c ON l.copy_id = c.id
JOIN Book b ON c.book_id = b.id
WHERE l.due_date < CURRENT_DATE
AND NOT EXISTS (SELECT 1 FROM BookReturn ret WHERE ret.loan_id = l.id)
ORDER BY days_overdue DESC;

-- 21. Количество произведений у каждого автора
CREATE OR REPLACE VIEW v_authors_composition_count AS
SELECT 
    a.id AS author_id,
    a.first_name || ' ' || a.last_name AS author_name,
    COUNT(DISTINCT c.id) AS composition_count
FROM Author a
JOIN Authorship au ON a.id = au.author_id
JOIN Composition c ON au.composition_id = c.id
GROUP BY a.id, a.first_name, a.last_name
ORDER BY composition_count DESC;

-- 22. Список сотрудников с их ролями и статусами
CREATE OR REPLACE VIEW v_employees_with_roles AS
SELECT 
    e.id AS employee_id,
    e.first_name || ' ' || e.last_name AS employee_name,
    r.id AS role_id,
    r.name AS role_name,
    es.id AS status_id,
    es.name AS status_name,
    e.hire_date
FROM Employee e
LEFT JOIN Roles r ON e.role = r.id
LEFT JOIN EmployeeStatus es ON e.employee_status_id = es.id
ORDER BY e.hire_date DESC;

-- 23. Статистика по читателям по статусам
CREATE OR REPLACE VIEW v_readers_by_status AS
SELECT 
    rs.id AS status_id,
    rs.name AS reader_status,
    COUNT(r.id) AS reader_count
FROM ReaderStatus rs
LEFT JOIN Reader r ON rs.id = r.reader_status_id
GROUP BY rs.id, rs.name
ORDER BY reader_count DESC;

-- ============================================
-- ПРАВА ДОСТУПА К ПРЕДСТАВЛЕНИЯМ
-- ============================================
-- ВНИМАНИЕ: В PostgreSQL представления (VIEW) считаются таблицами для целей GRANT.
-- Права на представления предоставляются через файл 04_roles.sql:
-- - Роли с правом SELECT ON ALL TABLES автоматически получают доступ ко всем представлениям
-- - Для читателя и гостя права предоставляются явно на конкретные представления

-- Предоставляем права читателю на представления каталога
GRANT SELECT ON 
    v_books_by_genre,
    v_available_books,
    v_books_with_genres,
    v_books_with_forms,
    v_top_books_by_loans,
    v_popular_authors,
    v_authors_composition_count
TO reader_role;

-- Предоставляем права гостю на ограниченные представления
GRANT SELECT ON 
    v_books_by_genre,
    v_popular_authors,
    v_top_books_by_loans
TO guest;
