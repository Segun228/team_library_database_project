-- CRUD-операции
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
INSERT INTO Author (first_name, last_name, birth_date, country)
VALUES ('Иван', 'Иванов', '1970-01-01', 'Россия');

-- Получение списка всех авторов
SELECT * FROM Author;

-- Обновление информации об авторе
UPDATE Author
SET country = 'Беларусь'
WHERE id = 1;

-- Аналитические запросы

-- Количество книг по каждому жанру
SELECT g.name, COUNT(bg.book_id) AS book_count
FROM Genre g
JOIN BookGenre bg ON g.id = bg.genre_id
GROUP BY g.name
ORDER BY book_count DESC;

-- Список самых популярных авторов (по количеству книг в библиотеке)
SELECT a.first_name, a.last_name, COUNT(b.id) AS book_count
FROM Author a
JOIN Authorship au ON a.id = au.author_id
JOIN Composition c ON au.composition_id = c.id
JOIN BookComposition bc ON c.id = bc.composition_id
JOIN Book b ON bc.book_id = b.id
GROUP BY a.first_name, a.last_name
ORDER BY book_count DESC;

-- Количество экземпляров книг, сгруппированное по статусу копии
SELECT cs.name, COUNT(c.id) AS copy_count
FROM CopyStatus cs
JOIN Copy c ON cs.id = c.copy_status_id
GROUP BY cs.name;

-- Поиск книги по ISBN
SELECT * FROM Book WHERE isbn = '1234567890';

-- Получение информации о читателе по email
SELECT * FROM Reader WHERE email = 'reader@example.com';

-- Список всех доступных (не выданных) книг
SELECT b.*
FROM Book b
JOIN Copy c ON b.id = c.book_id
JOIN CopyStatus cs ON c.copy_status_id = cs.id
WHERE cs.name = 'доступна';

-- Список книг, которые читатель с определённым ID взял в библиотеке
SELECT b.title, r.due_date
FROM Reception r
JOIN Copy c ON r.copy_id = c.id
JOIN Book b ON c.book_id = b.id
WHERE r.reader_id = 1 AND r.operation_type = 'borrow';

-- Добавление новой записи о выдаче книги
INSERT INTO Reception (operation_type, copy_id, reader_id, employee_id, operation_date, due_date)
VALUES ('borrow', 1, 1, 1, CURRENT_DATE, CURRENT_DATE + INTERVAL '14 days');

-- Обновление информации о возврате книги
UPDATE Reception
SET operation_type = 'return', operation_date = CURRENT_DATE
WHERE id = 1;


-- Cписок книг с указанием их жанров
SELECT b.title, g.name AS genre_name
FROM Book b
JOIN BookGenre bg ON b.id = bg.book_id
JOIN Genre g ON bg.genre_id = g.id
WHERE b.publication_year > 2000
ORDER BY b.title;

-- Запрос для определения количества книг у каждого автора и ранжирования авторов по этому количеству
SELECT a.first_name, a.last_name, COUNT(b.id) AS book_count,
       RANK() OVER (ORDER BY COUNT(b.id) DESC) AS rank_by_book_count
FROM Author a
JOIN Authorship au ON a.id = au.author_id
JOIN Composition c ON au.composition_id = c.id
JOIN BookComposition bc ON c.id = bc.composition_id
JOIN Book b ON bc.book_id = b.id
GROUP BY a.first_name, a.last_name
ORDER BY rank_by_book_count;

-- Cписок читателей, которые взяли книги определённого жанра
SELECT DISTINCT r.first_name, r.last_name, g.name AS genre_name
FROM Reader r
JOIN Reception re ON r.id = re.reader_id
JOIN Copy c ON re.copy_id = c.id
JOIN Book b ON c.book_id = b.id
JOIN BookGenre bg ON b.id = bg.book_id
JOIN Genre g ON bg.genre_id = g.id
WHERE g.name = 'Фантастика' AND re.operation_type = 'borrow'
ORDER BY r.last_name;

-- Вывод списка операций с указанием количества операций для каждой книги
SELECT re.id, b.title, re.operation_type, re.operation_date,
       COUNT(re.id) OVER (PARTITION BY b.id) AS total_operations_for_book
FROM Reception re
JOIN Copy c ON re.copy_id = c.id
JOIN Book b ON c.book_id = b.id
ORDER BY b.title, re.operation_date;

-- Вывод количества книг по каждому издателю и выбор только тех издателей, у которых больше 5 книг в библиотеке
SELECT p.name, COUNT(b.id) AS book_count
FROM Publisher p
JOIN Book b ON p.id = b.publisher_id
GROUP BY p.name
HAVING COUNT(b.id) > 5
ORDER BY book_count DESC;

-- Список книг с указанием количества их экземпляров и статусом доступности
WITH book_copies AS (
    SELECT book_id, COUNT(*) AS total_copies,
           SUM(CASE WHEN cs.name = 'доступна' THEN 1 ELSE 0 END) AS available_copies
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
GROUP BY b.title
ORDER BY tag_count DESC;


-- Ранжирование книг по количеству экземпляров
SELECT b.title, c.inventory_number,
       RANK() OVER (PARTITION BY b.id ORDER BY c.inventory_number) AS copy_rank
FROM Book b
JOIN Copy c ON b.id = c.book_id
ORDER BY b.title, copy_rank;

-- Поиск читателей, которые взяли книги, опубликованные после определённого года
SELECT DISTINCT r.first_name, r.last_name
FROM Reader r
JOIN Reception re ON r.id = re.reader_id
JOIN Copy c ON re.copy_id = c.id
JOIN Book b ON c.book_id = b.id
WHERE b.publication_year > (SELECT AVG(publication_year) FROM Book);

-- Жанрыв, у которых количество книг превышает среднее значение по всем жанрам
WITH genre_book_count AS (
    SELECT g.id, g.name, COUNT(bg.book_id) AS book_count
    FROM Genre g
    JOIN BookGenre bg ON g.id = bg.genre_id
    GROUP BY g.id, g.name
),
average_book_count AS (
    SELECT AVG(book_count) AS avg_count
    FROM genre_book_count
)
SELECT gbc.name, gbc.book_count
FROM genre_book_count gbc
JOIN average_book_count abc ON gbc.book_count > abc.avg_count
ORDER BY gbc.book_count DESC;
