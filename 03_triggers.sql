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

-- Функция для автоматического изменения статуса экземпляра при выдаче/возврате
CREATE OR REPLACE FUNCTION update_copy_status_on_reception()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.operation_type = 'borrow' THEN
        UPDATE Copy SET copy_status_id = 2 WHERE id = NEW.copy_id;
    ELSIF NEW.operation_type = 'return' THEN
        UPDATE Copy SET copy_status_id = 1 WHERE id = NEW.copy_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Функция для проверки доступности экземпляра перед выдачей
CREATE OR REPLACE FUNCTION check_copy_availability()
RETURNS TRIGGER AS $$
DECLARE
    current_status INT;
BEGIN
    IF NEW.operation_type = 'borrow' THEN
        SELECT copy_status_id INTO current_status FROM Copy WHERE id = NEW.copy_id;
        IF current_status != 1 THEN
            RAISE EXCEPTION 'Экземпляр книги недоступен для выдачи (текущий статус: %)', current_status;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Функция для автоматического расчета штрафа при просрочке
CREATE OR REPLACE FUNCTION calculate_fine_on_return()
RETURNS TRIGGER AS $$
DECLARE
    days_overdue INT;
    fine_per_day DECIMAL(10,2) := 10.00;
BEGIN
    IF NEW.operation_type = 'return' AND NEW.due_date IS NOT NULL THEN
        days_overdue := NEW.operation_date - NEW.due_date;
        IF days_overdue > 0 THEN
            NEW.fine_amount := days_overdue * fine_per_day;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Функция для валидации email (для таблиц Reader и Employees)
CREATE OR REPLACE FUNCTION validate_email()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.email IS NOT NULL AND NEW.email !~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
        RAISE EXCEPTION 'Некорректный формат email: %', NEW.email;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Функция для валидации contact_email (для таблицы Publisher)
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

-- Функция для проверки года написания произведения
CREATE OR REPLACE FUNCTION check_year_written()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.year_written IS NOT NULL THEN
        IF NEW.year_written < -3000 OR NEW.year_written > EXTRACT(YEAR FROM CURRENT_DATE) + 1 THEN
            RAISE EXCEPTION 'Некорректный год написания: %', NEW.year_written;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Функция для логирования изменений в книгах
CREATE OR REPLACE FUNCTION log_book_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'UPDATE' THEN
        RAISE NOTICE 'Книга % обновлена: % -> %', OLD.id, OLD.title, NEW.title;
    ELSIF TG_OP = 'DELETE' THEN
        RAISE NOTICE 'Книга % удалена: %', OLD.id, OLD.title;
    ELSIF TG_OP = 'INSERT' THEN
        RAISE NOTICE 'Добавлена новая книга: % (ID: %)', NEW.title, NEW.id;
    END IF;
    RETURN COALESCE(NEW, OLD);
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

-- Функция для автоматической установки даты регистрации читателя
CREATE OR REPLACE FUNCTION set_reader_registration_date()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.registration_date IS NULL THEN
        NEW.registration_date := CURRENT_DATE;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Функция для проверки уникальности инвентарного номера в пределах года
CREATE OR REPLACE FUNCTION check_inventory_number_format()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.inventory_number !~ '^[A-Za-z0-9-]+$' THEN
        RAISE EXCEPTION 'Инвентарный номер может содержать только буквы, цифры и дефис';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Функция для проверки телефона (для Reader и Employees)
CREATE OR REPLACE FUNCTION check_phone_format()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.phone IS NOT NULL AND NEW.phone !~ '^\+?[0-9\s\-\(\)]+$' THEN
        RAISE EXCEPTION 'Некорректный формат телефона: %', NEW.phone;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Функция для проверки contact_phone (для Publisher)
CREATE OR REPLACE FUNCTION check_contact_phone_format()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.contact_phone IS NOT NULL AND NEW.contact_phone !~ '^\+?[0-9\s\-\(\)]+$' THEN
        RAISE EXCEPTION 'Некорректный формат телефона: %', NEW.contact_phone;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Функция для предотвращения удаления выданных экземпляров
CREATE OR REPLACE FUNCTION prevent_delete_borrowed_copy()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.copy_status_id = 2 THEN
        RAISE EXCEPTION 'Нельзя удалить выданный экземпляр книги';
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Функция для проверки даты операции
CREATE OR REPLACE FUNCTION check_operation_date()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.operation_date > CURRENT_DATE THEN
        RAISE EXCEPTION 'Дата операции не может быть в будущем';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Функция для автоматической установки due_date
CREATE OR REPLACE FUNCTION set_default_due_date()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.operation_type = 'borrow' AND NEW.due_date IS NULL THEN
        NEW.due_date := NEW.operation_date + INTERVAL '14 days';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- ТРИГГЕРЫ ДЛЯ ОБНОВЛЕНИЯ updated_at
-- ============================================

CREATE TRIGGER trigger_genre_updated_at
    BEFORE UPDATE ON Genre
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_publisher_updated_at
    BEFORE UPDATE ON Publisher
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

CREATE TRIGGER trigger_book_updated_at
    BEFORE UPDATE ON Book
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_form_updated_at
    BEFORE UPDATE ON Form
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_bookform_updated_at
    BEFORE UPDATE ON BookForm
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_bookcomposition_updated_at
    BEFORE UPDATE ON BookComposition
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_tags_updated_at
    BEFORE UPDATE ON Tags
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_booktag_updated_at
    BEFORE UPDATE ON BookTag
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_bookgenre_updated_at
    BEFORE UPDATE ON BookGenre
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_copystatus_updated_at
    BEFORE UPDATE ON CopyStatus
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_copy_updated_at
    BEFORE UPDATE ON Copy
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_readerstatus_updated_at
    BEFORE UPDATE ON ReaderStatus
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_reader_updated_at
    BEFORE UPDATE ON Reader
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_roles_updated_at
    BEFORE UPDATE ON Roles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_employeestatus_updated_at
    BEFORE UPDATE ON EmployeeStatus
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_employees_updated_at
    BEFORE UPDATE ON Employees
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_reception_updated_at
    BEFORE UPDATE ON Reception
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================
-- ТРИГГЕРЫ ДЛЯ БИЗНЕС-ЛОГИКИ
-- ============================================

-- Триггер изменения статуса экземпляра при выдаче/возврате
CREATE TRIGGER trigger_update_copy_status
    AFTER INSERT ON Reception
    FOR EACH ROW EXECUTE FUNCTION update_copy_status_on_reception();

-- Триггер проверки доступности экземпляра
CREATE TRIGGER trigger_check_copy_availability
    BEFORE INSERT ON Reception
    FOR EACH ROW EXECUTE FUNCTION check_copy_availability();

-- Триггер расчета штрафа
CREATE TRIGGER trigger_calculate_fine
    BEFORE INSERT ON Reception
    FOR EACH ROW EXECUTE FUNCTION calculate_fine_on_return();

-- Триггер установки due_date по умолчанию
CREATE TRIGGER trigger_set_due_date
    BEFORE INSERT ON Reception
    FOR EACH ROW EXECUTE FUNCTION set_default_due_date();

-- Триггер проверки даты операции
CREATE TRIGGER trigger_check_operation_date
    BEFORE INSERT OR UPDATE ON Reception
    FOR EACH ROW EXECUTE FUNCTION check_operation_date();

-- ============================================
-- ТРИГГЕРЫ ВАЛИДАЦИИ
-- ============================================

-- Триггеры валидации email
CREATE TRIGGER trigger_validate_reader_email
    BEFORE INSERT OR UPDATE ON Reader
    FOR EACH ROW EXECUTE FUNCTION validate_email();

CREATE TRIGGER trigger_validate_employee_email
    BEFORE INSERT OR UPDATE ON Employees
    FOR EACH ROW EXECUTE FUNCTION validate_email();

CREATE TRIGGER trigger_validate_publisher_email
    BEFORE INSERT OR UPDATE ON Publisher
    FOR EACH ROW EXECUTE FUNCTION validate_contact_email();

-- Триггеры валидации телефона
CREATE TRIGGER trigger_validate_reader_phone
    BEFORE INSERT OR UPDATE ON Reader
    FOR EACH ROW EXECUTE FUNCTION check_phone_format();

CREATE TRIGGER trigger_validate_employee_phone
    BEFORE INSERT OR UPDATE ON Employees
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

-- Триггер проверки года написания
CREATE TRIGGER trigger_check_year_written
    BEFORE INSERT OR UPDATE ON Composition
    FOR EACH ROW EXECUTE FUNCTION check_year_written();

-- Триггер проверки количества страниц
CREATE TRIGGER trigger_check_page_count
    BEFORE INSERT OR UPDATE ON Book
    FOR EACH ROW EXECUTE FUNCTION check_page_count();

-- Триггер проверки инвентарного номера
CREATE TRIGGER trigger_check_inventory_number
    BEFORE INSERT OR UPDATE ON Copy
    FOR EACH ROW EXECUTE FUNCTION check_inventory_number_format();

-- Триггер установки даты регистрации читателя
CREATE TRIGGER trigger_set_registration_date
    BEFORE INSERT ON Reader
    FOR EACH ROW EXECUTE FUNCTION set_reader_registration_date();

-- Триггер предотвращения удаления выданных экземпляров
CREATE TRIGGER trigger_prevent_delete_borrowed
    BEFORE DELETE ON Copy
    FOR EACH ROW EXECUTE FUNCTION prevent_delete_borrowed_copy();

-- ============================================
-- ТРИГГЕРЫ ЛОГИРОВАНИЯ
-- ============================================

CREATE TRIGGER trigger_log_book_insert
    AFTER INSERT ON Book
    FOR EACH ROW EXECUTE FUNCTION log_book_changes();

CREATE TRIGGER trigger_log_book_update
    AFTER UPDATE ON Book
    FOR EACH ROW EXECUTE FUNCTION log_book_changes();

CREATE TRIGGER trigger_log_book_delete
    AFTER DELETE ON Book
    FOR EACH ROW EXECUTE FUNCTION log_book_changes();
