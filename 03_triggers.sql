-- ============================================
-- БАЗА ДАННЫХ БИБЛИОТЕКИ
-- Часть 3: Триггеры и функции
-- ============================================

-- ============================================
-- ФУНКЦИИ
-- ============================================

-- Функция для автоматического обновления updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Функция для автоматического изменения статуса экземпляра при выдаче
CREATE OR REPLACE FUNCTION update_copy_status_on_loan()
RETURNS TRIGGER AS $$
BEGIN
    -- При выдаче меняем статус на "выдан" (id=2)
    UPDATE Copy SET copy_status_id = 2 WHERE id = NEW.copy_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Функция для автоматического изменения статуса экземпляра при возврате
CREATE OR REPLACE FUNCTION update_copy_status_on_return()
RETURNS TRIGGER AS $$
BEGIN
    -- При возврате меняем статус на "доступен" (id=1)
    UPDATE Copy SET copy_status_id = 1 WHERE id = (SELECT copy_id FROM Loan WHERE id = NEW.loan_id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Функция для проверки доступности экземпляра перед выдачей
CREATE OR REPLACE FUNCTION check_copy_availability()
RETURNS TRIGGER AS $$
DECLARE
    current_status INT;
BEGIN
    SELECT copy_status_id INTO current_status FROM Copy WHERE id = NEW.copy_id;
    IF current_status != 1 THEN
        RAISE EXCEPTION 'Экземпляр книги недоступен для выдачи (текущий статус: %)', current_status;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Функция для автоматического создания штрафа при просрочке возврата
CREATE OR REPLACE FUNCTION create_fine_on_overdue()
RETURNS TRIGGER AS $$
DECLARE
    loan_due_date DATE;
    days_overdue INT;
    overdue_reason_id INT;
BEGIN
    -- Получаем дату возврата из Loan
    SELECT due_date INTO loan_due_date FROM Loan WHERE id = NEW.loan_id;
    
    IF loan_due_date IS NOT NULL THEN
        days_overdue := CURRENT_DATE - loan_due_date;
        IF days_overdue > 0 THEN
            -- Получаем ID причины "Просрочка возврата"
            SELECT id INTO overdue_reason_id FROM FineReason WHERE name = 'Просрочка возврата';
            -- Если причины нет, пропускаем создание штрафа (причины должны быть предопределены)
            IF overdue_reason_id IS NULL THEN
                RETURN NEW;
            END IF;
            
            -- Создаем штраф только если его еще нет
            IF NOT EXISTS (SELECT 1 FROM Fine WHERE loan_id = NEW.loan_id) THEN
                INSERT INTO Fine (loan_id, reason_id, notes)
                VALUES (NEW.loan_id, overdue_reason_id, 
                        'Просрочка возврата на ' || days_overdue || ' дней');
            END IF;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Функция для валидации email
CREATE OR REPLACE FUNCTION validate_email()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.email IS NOT NULL AND NEW.email !~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
        RAISE EXCEPTION 'Некорректный формат email: %', NEW.email;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Функция для валидации contact_email
CREATE OR REPLACE FUNCTION validate_contact_email()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.contact_email IS NOT NULL AND NEW.contact_email !~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
        RAISE EXCEPTION 'Некорректный формат email: %', NEW.contact_email;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Функция для проверки даты смерти автора
CREATE OR REPLACE FUNCTION check_author_dates()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.death_date IS NOT NULL AND NEW.birth_date IS NOT NULL THEN
        IF NEW.death_date < NEW.birth_date THEN
            RAISE EXCEPTION 'Дата смерти не может быть раньше даты рождения';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Функция для проверки года публикации
CREATE OR REPLACE FUNCTION check_publication_year()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.publication_year IS NOT NULL THEN
        IF NEW.publication_year < 1450 OR NEW.publication_year > EXTRACT(YEAR FROM CURRENT_DATE) + 1 THEN
            RAISE EXCEPTION 'Некорректный год публикации: %', NEW.publication_year;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Функция для проверки количества страниц
CREATE OR REPLACE FUNCTION check_page_count()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.page_count IS NOT NULL AND NEW.page_count <= 0 THEN
        RAISE EXCEPTION 'Количество страниц должно быть положительным числом';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Функция для проверки телефона
CREATE OR REPLACE FUNCTION check_phone_format()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.phone IS NOT NULL AND NEW.phone !~ '^\+?[0-9\s\-\(\)]+$' THEN
        RAISE EXCEPTION 'Некорректный формат телефона: %', NEW.phone;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Функция для проверки contact_phone
CREATE OR REPLACE FUNCTION check_contact_phone_format()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.contact_phone IS NOT NULL AND NEW.contact_phone !~ '^\+?[0-9\s\-\(\)]+$' THEN
        RAISE EXCEPTION 'Некорректный формат телефона: %', NEW.contact_phone;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Функция для проверки даты выдачи
CREATE OR REPLACE FUNCTION check_loan_dates()
RETURNS TRIGGER AS $$
BEGIN
    -- Проверяем только что due_date не раньше даты создания выдачи
    -- Разрешаем исторические выдачи (с датами в прошлом) для тестовых данных
    -- Но не позволяем due_date быть раньше created_at
    IF NEW.due_date IS NOT NULL THEN
        IF NEW.created_at IS NOT NULL AND NEW.due_date < DATE(NEW.created_at) THEN
            RAISE EXCEPTION 'Дата возврата не может быть раньше даты выдачи';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Функция для предотвращения двойного возврата
CREATE OR REPLACE FUNCTION prevent_double_return()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM Return WHERE loan_id = NEW.loan_id) THEN
        RAISE EXCEPTION 'Книга уже была возвращена';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- ТРИГГЕРЫ ДЛЯ ОБНОВЛЕНИЯ updated_at
-- ============================================

CREATE TRIGGER trigger_employeestatus_updated_at
    BEFORE UPDATE ON EmployeeStatus
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_roles_updated_at
    BEFORE UPDATE ON Roles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_employee_updated_at
    BEFORE UPDATE ON Employee
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_readerstatus_updated_at
    BEFORE UPDATE ON ReaderStatus
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_reader_updated_at
    BEFORE UPDATE ON Reader
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_copystatus_updated_at
    BEFORE UPDATE ON CopyStatus
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_publisher_updated_at
    BEFORE UPDATE ON Publisher
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_book_updated_at
    BEFORE UPDATE ON Book
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_copy_updated_at
    BEFORE UPDATE ON Copy
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_tags_updated_at
    BEFORE UPDATE ON Tags
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_booktag_updated_at
    BEFORE UPDATE ON BookTag
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_form_updated_at
    BEFORE UPDATE ON Form
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_bookform_updated_at
    BEFORE UPDATE ON BookForm
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_genre_updated_at
    BEFORE UPDATE ON Genre
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_bookgenre_updated_at
    BEFORE UPDATE ON BookGenre
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_author_updated_at
    BEFORE UPDATE ON Author
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_composition_updated_at
    BEFORE UPDATE ON Composition
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_authorship_updated_at
    BEFORE UPDATE ON Authorship
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_bookcomposition_updated_at
    BEFORE UPDATE ON BookComposition
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_loan_updated_at
    BEFORE UPDATE ON Loan
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_return_updated_at
    BEFORE UPDATE ON Return
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_finereason_updated_at
    BEFORE UPDATE ON FineReason
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_fine_updated_at
    BEFORE UPDATE ON Fine
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- ТРИГГЕРЫ ДЛЯ БИЗНЕС-ЛОГИКИ
-- ============================================

-- Триггер изменения статуса экземпляра при выдаче
CREATE TRIGGER trigger_update_copy_status_on_loan
    AFTER INSERT ON Loan
    FOR EACH ROW EXECUTE FUNCTION update_copy_status_on_loan();

-- Триггер проверки доступности экземпляра
CREATE TRIGGER trigger_check_copy_availability
    BEFORE INSERT ON Loan
    FOR EACH ROW EXECUTE FUNCTION check_copy_availability();

-- Триггер изменения статуса экземпляра при возврате
CREATE TRIGGER trigger_update_copy_status_on_return
    AFTER INSERT ON Return
    FOR EACH ROW EXECUTE FUNCTION update_copy_status_on_return();

-- Триггер создания штрафа при просрочке
CREATE TRIGGER trigger_create_fine_on_overdue
    AFTER INSERT ON Return
    FOR EACH ROW EXECUTE FUNCTION create_fine_on_overdue();

-- Триггер предотвращения двойного возврата
CREATE TRIGGER trigger_prevent_double_return
    BEFORE INSERT ON Return
    FOR EACH ROW EXECUTE FUNCTION prevent_double_return();

-- Триггер проверки даты выдачи
CREATE TRIGGER trigger_check_loan_dates
    BEFORE INSERT OR UPDATE ON Loan
    FOR EACH ROW EXECUTE FUNCTION check_loan_dates();

-- ============================================
-- ТРИГГЕРЫ ВАЛИДАЦИИ
-- ============================================

-- Триггеры валидации email
CREATE TRIGGER trigger_validate_reader_email
    BEFORE INSERT OR UPDATE ON Reader
    FOR EACH ROW EXECUTE FUNCTION validate_email();

CREATE TRIGGER trigger_validate_employee_email
    BEFORE INSERT OR UPDATE ON Employee
    FOR EACH ROW EXECUTE FUNCTION validate_email();

CREATE TRIGGER trigger_validate_publisher_email
    BEFORE INSERT OR UPDATE ON Publisher
    FOR EACH ROW EXECUTE FUNCTION validate_contact_email();

-- Триггеры валидации телефона
CREATE TRIGGER trigger_validate_reader_phone
    BEFORE INSERT OR UPDATE ON Reader
    FOR EACH ROW EXECUTE FUNCTION check_phone_format();

CREATE TRIGGER trigger_validate_employee_phone
    BEFORE INSERT OR UPDATE ON Employee
    FOR EACH ROW EXECUTE FUNCTION check_phone_format();

CREATE TRIGGER trigger_validate_publisher_phone
    BEFORE INSERT OR UPDATE ON Publisher
    FOR EACH ROW EXECUTE FUNCTION check_contact_phone_format();

-- Триггер проверки дат автора
CREATE TRIGGER trigger_check_author_dates
    BEFORE INSERT OR UPDATE ON Author
    FOR EACH ROW EXECUTE FUNCTION check_author_dates();

-- Триггер проверки года публикации
CREATE TRIGGER trigger_check_publication_year
    BEFORE INSERT OR UPDATE ON Book
    FOR EACH ROW EXECUTE FUNCTION check_publication_year();

-- Триггер проверки количества страниц
CREATE TRIGGER trigger_check_page_count
    BEFORE INSERT OR UPDATE ON Book
    FOR EACH ROW EXECUTE FUNCTION check_page_count();
