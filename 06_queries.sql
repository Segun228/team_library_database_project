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

-- Количество книг по каждому жанру
SELECT g.name, COUNT(bg.book_id) AS book_count
FROM Genre g
LEFT JOIN BookGenre bg ON g.id = bg.genre_id
GROUP BY g.name
ORDER BY book_count DESC;

-- Список самых популярных авторов (по количеству книг в библиотеке)
SELECT a.first_name, a.last_name, a.patronymic, COUNT(DISTINCT b.id) AS book_count
FROM Author a
JOIN Authorship au ON a.id = au.author_id
JOIN Composition c ON au.composition_id = c.id
JOIN BookComposition bc ON c.id = bc.composition_id
JOIN Book b ON bc.book_id = b.id
GROUP BY a.id, a.first_name, a.last_name, a.patronymic
ORDER BY book_count DESC;

-- Количество экземпляров книг, сгруппированное по статусу копии
SELECT cs.name, COUNT(c.id) AS copy_count
FROM CopyStatus cs
LEFT JOIN Copy c ON cs.id = c.copy_status_id
GROUP BY cs.name, cs.id
ORDER BY copy_count DESC;

-- Поиск книги по ISBN
SELECT * FROM Book WHERE isbn = '978-5-699-12345-1';

-- Получение информации о читателе по email
SELECT * FROM Reader WHERE email = 'ivan.petrov@mail.ru';

-- Список всех доступных (не выданных) книг
SELECT DISTINCT b.*
FROM Book b
JOIN Copy c ON b.id = c.book_id
JOIN CopyStatus cs ON c.copy_status_id = cs.id
WHERE cs.name = 'Доступен';

-- Список текущих выдач (книги на руках у читателей)
SELECT 
    l.id AS loan_id,
    r.first_name || ' ' || r.last_name AS reader_name,
    b.title AS book_title,
    c.inventory_number,
    l.due_date,
    CASE 
        WHEN l.due_date < CURRENT_DATE THEN 'Просрочено'
        WHEN l.due_date = CURRENT_DATE THEN 'Сегодня'
        ELSE 'В срок'
    END AS status
FROM Loan l
JOIN Reader r ON l.reader_id = r.id
JOIN Copy c ON l.copy_id = c.id
JOIN Book b ON c.book_id = b.id
WHERE NOT EXISTS (
    SELECT 1 FROM BookReturn ret WHERE ret.loan_id = l.id
)
ORDER BY l.due_date;

-- Список книг с указанием их жанров
SELECT b.title, g.name AS genre_name
FROM Book b
JOIN BookGenre bg ON b.id = bg.book_id
JOIN Genre g ON bg.genre_id = g.id
WHERE b.publication_year > 2000
ORDER BY b.title;

-- Запрос для определения количества книг у каждого автора и ранжирования авторов
SELECT 
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

-- Список читателей, которые взяли книги определённого жанра
SELECT DISTINCT 
    r.first_name, 
    r.last_name, 
    r.patronymic,
    g.name AS genre_name
FROM Reader r
JOIN Loan l ON r.id = l.reader_id
JOIN Copy c ON l.copy_id = c.id
JOIN Book b ON c.book_id = b.id
JOIN BookGenre bg ON b.id = bg.book_id
JOIN Genre g ON bg.genre_id = g.id
WHERE g.name = 'Фантастика'
AND NOT EXISTS (SELECT 1 FROM BookReturn ret WHERE ret.loan_id = l.id)
ORDER BY r.last_name;

-- Вывод списка выдач с указанием количества операций для каждой книги
SELECT 
    l.id,
    b.title,
    l.due_date,
    COUNT(l.id) OVER (PARTITION BY b.id) AS total_loans_for_book
FROM Loan l
JOIN Copy c ON l.copy_id = c.id
JOIN Book b ON c.book_id = b.id
ORDER BY b.title, l.due_date;

-- Вывод количества книг по каждому издателю и выбор только тех издателей, у которых больше 5 книг
SELECT p.name, COUNT(b.id) AS book_count
FROM Publisher p
LEFT JOIN Book b ON p.id = b.publisher_id
GROUP BY p.id, p.name
HAVING COUNT(b.id) > 5
ORDER BY book_count DESC;

-- Список книг с указанием количества их экземпляров и статусом доступности
WITH book_copies AS (
    SELECT 
        book_id, 
        COUNT(*) AS total_copies,
        SUM(CASE WHEN cs.name = 'Доступен' THEN 1 ELSE 0 END) AS available_copies
    FROM Copy c
    JOIN CopyStatus cs ON c.copy_status_id = cs.id
    GROUP BY book_id
)
SELECT b.title, bc.total_copies, bc.available_copies
FROM Book b
JOIN book_copies bc ON b.id = bc.book_id
ORDER BY bc.available_copies DESC;

-- Определение количества тегов у каждой книги
SELECT b.title, COUNT(bt.tag_id) AS tag_count
FROM Book b
LEFT JOIN BookTag bt ON b.id = bt.book_id
GROUP BY b.id, b.title
ORDER BY tag_count DESC;

-- Ранжирование книг по количеству экземпляров
SELECT 
    b.title, 
    c.inventory_number,
    RANK() OVER (PARTITION BY b.id ORDER BY c.inventory_number) AS copy_rank
FROM Book b
JOIN Copy c ON b.id = c.book_id
ORDER BY b.title, copy_rank;

-- Поиск читателей, которые взяли книги, опубликованные после определённого года
SELECT DISTINCT r.first_name, r.last_name, r.patronymic
FROM Reader r
JOIN Loan l ON r.id = l.reader_id
JOIN Copy c ON l.copy_id = c.id
JOIN Book b ON c.book_id = b.id
WHERE b.publication_year > (SELECT AVG(publication_year) FROM Book WHERE publication_year IS NOT NULL);

-- Жанры, у которых количество книг превышает среднее значение по всем жанрам
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
SELECT gbc.name, gbc.book_count
FROM genre_book_count gbc
CROSS JOIN average_book_count abc
WHERE gbc.book_count > abc.avg_count
ORDER BY gbc.book_count DESC;

-- Список всех выданных книг с информацией о читателях и сотрудниках
SELECT 
    b.title AS book_title,
    r.first_name || ' ' || r.last_name AS reader_name,
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

-- Статистика по штрафам
SELECT 
    fr.name AS reason,
    COUNT(f.id) AS fine_count
FROM FineReason fr
LEFT JOIN Fine f ON fr.id = f.reason_id
GROUP BY fr.id, fr.name
ORDER BY fine_count DESC;

-- Список книг с их формами изданий
SELECT 
    b.title,
    STRING_AGG(f.name, ', ') AS forms
FROM Book b
JOIN BookForm bf ON b.id = bf.book_id
JOIN Form f ON bf.form_id = f.id
GROUP BY b.id, b.title
ORDER BY b.title;

-- Топ-10 самых читаемых книг (по количеству выдач)
SELECT 
    b.title,
    COUNT(l.id) AS loan_count
FROM Book b
JOIN Copy c ON b.id = c.book_id
JOIN Loan l ON c.id = l.copy_id
GROUP BY b.id, b.title
ORDER BY loan_count DESC
LIMIT 10;

-- Читатели с просроченными книгами
SELECT 
    r.first_name || ' ' || r.last_name AS reader_name,
    r.email,
    r.phone,
    b.title AS book_title,
    l.due_date,
    CURRENT_DATE - l.due_date AS days_overdue
FROM Loan l
JOIN Reader r ON l.reader_id = r.id
JOIN Copy c ON l.copy_id = c.id
JOIN Book b ON c.book_id = b.id
WHERE l.due_date < CURRENT_DATE
AND NOT EXISTS (SELECT 1 FROM BookReturn ret WHERE ret.loan_id = l.id)
ORDER BY days_overdue DESC;

-- Количество произведений у каждого автора
SELECT 
    a.first_name || ' ' || a.last_name AS author_name,
    COUNT(DISTINCT c.id) AS composition_count
FROM Author a
JOIN Authorship au ON a.id = au.author_id
JOIN Composition c ON au.composition_id = c.id
GROUP BY a.id, a.first_name, a.last_name
ORDER BY composition_count DESC;

-- Список сотрудников с их ролями и статусами
SELECT 
    e.first_name || ' ' || e.last_name AS employee_name,
    r.name AS role_name,
    es.name AS status_name,
    e.hire_date
FROM Employee e
LEFT JOIN Roles r ON e.role = r.id
LEFT JOIN EmployeeStatus es ON e.employee_status_id = es.id
ORDER BY e.hire_date DESC;

-- Статистика по читателям по статусам
SELECT 
    rs.name AS reader_status,
    COUNT(r.id) AS reader_count
FROM ReaderStatus rs
LEFT JOIN Reader r ON rs.id = r.reader_status_id
GROUP BY rs.id, rs.name
ORDER BY reader_count DESC;
