-- ============================================
-- БАЗА ДАННЫХ БИБЛИОТЕКИ
-- Часть 4: Роли и права доступа
-- ============================================

-- ============================================
-- СОЗДАНИЕ РОЛЕЙ
-- ============================================

-- Роль администратора библиотеки (полный доступ)
DO $$ BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'library_admin') THEN
        CREATE ROLE library_admin WITH LOGIN PASSWORD 'admin_pass_123';
    END IF;
END $$;

-- Роль библиотекаря (работа с книгами и читателями)
DO $$ BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'librarian') THEN
        CREATE ROLE librarian WITH LOGIN PASSWORD 'librarian_pass_123';
    END IF;
END $$;

-- Роль старшего библиотекаря (расширенные права)
DO $$ BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'senior_librarian') THEN
        CREATE ROLE senior_librarian WITH LOGIN PASSWORD 'senior_lib_pass_123';
    END IF;
END $$;

-- Роль читателя (только просмотр каталога)
DO $$ BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'reader_role') THEN
        CREATE ROLE reader_role WITH LOGIN PASSWORD 'reader_pass_123';
    END IF;
END $$;

-- Роль каталогизатора (работа с каталогом)
DO $$ BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'cataloger') THEN
        CREATE ROLE cataloger WITH LOGIN PASSWORD 'cataloger_pass_123';
    END IF;
END $$;

-- Роль аналитика (только чтение для отчетов)
DO $$ BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'analyst') THEN
        CREATE ROLE analyst WITH LOGIN PASSWORD 'analyst_pass_123';
    END IF;
END $$;

-- Роль для резервного копирования
DO $$ BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'backup_role') THEN
        CREATE ROLE backup_role WITH LOGIN PASSWORD 'backup_pass_123';
    END IF;
END $$;

-- Роль для приложения
DO $$ BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'app_user') THEN
        CREATE ROLE app_user WITH LOGIN PASSWORD 'app_pass_123';
    END IF;
END $$;

-- Роль для ввода данных
DO $$ BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'data_entry') THEN
        CREATE ROLE data_entry WITH LOGIN PASSWORD 'data_entry_pass_123';
    END IF;
END $$;

-- Роль супервизора
DO $$ BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'supervisor') THEN
        CREATE ROLE supervisor WITH LOGIN PASSWORD 'supervisor_pass_123';
    END IF;
END $$;

-- Роль гостя (минимальные права)
DO $$ BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'guest') THEN
        CREATE ROLE guest WITH LOGIN PASSWORD 'guest_pass_123';
    END IF;
END $$;

-- Роль менеджера (управление персоналом)
DO $$ BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'manager') THEN
        CREATE ROLE manager WITH LOGIN PASSWORD 'manager_pass_123';
    END IF;
END $$;

-- ============================================
-- ПРАВА ДЛЯ АДМИНИСТРАТОРА (полный доступ)
-- ============================================
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO library_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO library_admin;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO library_admin;

-- ============================================
-- ПРАВА ДЛЯ БИБЛИОТЕКАРЯ
-- ============================================
GRANT SELECT, INSERT, UPDATE ON Genre TO librarian;
GRANT SELECT, INSERT, UPDATE ON Publisher TO librarian;
GRANT SELECT, INSERT, UPDATE ON Author TO librarian;
GRANT SELECT, INSERT, UPDATE ON Composition TO librarian;
GRANT SELECT, INSERT, UPDATE ON Authorship TO librarian;
GRANT SELECT, INSERT, UPDATE ON Book TO librarian;
GRANT SELECT, INSERT, UPDATE ON BookComposition TO librarian;
GRANT SELECT, INSERT, UPDATE ON Tags TO librarian;
GRANT SELECT, INSERT, UPDATE ON BookTag TO librarian;
GRANT SELECT, INSERT, UPDATE ON BookGenre TO librarian;
GRANT SELECT ON CopyStatus TO librarian;
GRANT SELECT, INSERT, UPDATE ON Copy TO librarian;
GRANT SELECT ON ReaderStatus TO librarian;
GRANT SELECT, INSERT, UPDATE ON Reader TO librarian;
GRANT SELECT ON Roles TO librarian;
GRANT SELECT ON EmployeeStatus TO librarian;
GRANT SELECT ON Employees TO librarian;
GRANT SELECT, INSERT, UPDATE ON Reception TO librarian;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO librarian;

-- ============================================
-- ПРАВА ДЛЯ СТАРШЕГО БИБЛИОТЕКАРЯ
-- ============================================
GRANT SELECT, INSERT, UPDATE, DELETE ON Genre TO senior_librarian;
GRANT SELECT, INSERT, UPDATE, DELETE ON Publisher TO senior_librarian;
GRANT SELECT, INSERT, UPDATE, DELETE ON Author TO senior_librarian;
GRANT SELECT, INSERT, UPDATE, DELETE ON Composition TO senior_librarian;
GRANT SELECT, INSERT, UPDATE, DELETE ON Authorship TO senior_librarian;
GRANT SELECT, INSERT, UPDATE, DELETE ON Book TO senior_librarian;
GRANT SELECT, INSERT, UPDATE, DELETE ON BookComposition TO senior_librarian;
GRANT SELECT, INSERT, UPDATE, DELETE ON Tags TO senior_librarian;
GRANT SELECT, INSERT, UPDATE, DELETE ON BookTag TO senior_librarian;
GRANT SELECT, INSERT, UPDATE, DELETE ON BookGenre TO senior_librarian;
GRANT SELECT, INSERT, UPDATE ON CopyStatus TO senior_librarian;
GRANT SELECT, INSERT, UPDATE, DELETE ON Copy TO senior_librarian;
GRANT SELECT, INSERT, UPDATE ON ReaderStatus TO senior_librarian;
GRANT SELECT, INSERT, UPDATE, DELETE ON Reader TO senior_librarian;
GRANT SELECT ON Roles TO senior_librarian;
GRANT SELECT ON EmployeeStatus TO senior_librarian;
GRANT SELECT ON Employees TO senior_librarian;
GRANT SELECT, INSERT, UPDATE, DELETE ON Reception TO senior_librarian;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO senior_librarian;

-- ============================================
-- ПРАВА ДЛЯ ЧИТАТЕЛЯ (только просмотр каталога)
-- ============================================
GRANT SELECT ON Genre TO reader_role;
GRANT SELECT ON Publisher TO reader_role;
GRANT SELECT ON Author TO reader_role;
GRANT SELECT ON Composition TO reader_role;
GRANT SELECT ON Authorship TO reader_role;
GRANT SELECT ON Book TO reader_role;
GRANT SELECT ON BookComposition TO reader_role;
GRANT SELECT ON Tags TO reader_role;
GRANT SELECT ON BookTag TO reader_role;
GRANT SELECT ON BookGenre TO reader_role;
GRANT SELECT ON CopyStatus TO reader_role;

-- ============================================
-- ПРАВА ДЛЯ КАТАЛОГИЗАТОРА
-- ============================================
GRANT SELECT, INSERT, UPDATE ON Genre TO cataloger;
GRANT SELECT, INSERT, UPDATE ON Publisher TO cataloger;
GRANT SELECT, INSERT, UPDATE ON Author TO cataloger;
GRANT SELECT, INSERT, UPDATE ON Composition TO cataloger;
GRANT SELECT, INSERT, UPDATE ON Authorship TO cataloger;
GRANT SELECT, INSERT, UPDATE ON Book TO cataloger;
GRANT SELECT, INSERT, UPDATE ON BookComposition TO cataloger;
GRANT SELECT, INSERT, UPDATE ON Tags TO cataloger;
GRANT SELECT, INSERT, UPDATE ON BookTag TO cataloger;
GRANT SELECT, INSERT, UPDATE ON BookGenre TO cataloger;
GRANT SELECT ON CopyStatus TO cataloger;
GRANT SELECT, INSERT, UPDATE ON Copy TO cataloger;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO cataloger;

-- ============================================
-- ПРАВА ДЛЯ АНАЛИТИКА (только чтение)
-- ============================================
GRANT SELECT ON ALL TABLES IN SCHEMA public TO analyst;

-- ============================================
-- ПРАВА ДЛЯ РЕЗЕРВНОГО КОПИРОВАНИЯ
-- ============================================
GRANT SELECT ON ALL TABLES IN SCHEMA public TO backup_role;

-- ============================================
-- ПРАВА ДЛЯ ПРИЛОЖЕНИЯ
-- ============================================
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO app_user;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO app_user;

-- ============================================
-- ПРАВА ДЛЯ ВВОДА ДАННЫХ
-- ============================================
GRANT SELECT, INSERT ON Genre TO data_entry;
GRANT SELECT, INSERT ON Publisher TO data_entry;
GRANT SELECT, INSERT ON Author TO data_entry;
GRANT SELECT, INSERT ON Composition TO data_entry;
GRANT SELECT, INSERT ON Authorship TO data_entry;
GRANT SELECT, INSERT ON Book TO data_entry;
GRANT SELECT, INSERT ON BookComposition TO data_entry;
GRANT SELECT, INSERT ON Tags TO data_entry;
GRANT SELECT, INSERT ON BookTag TO data_entry;
GRANT SELECT, INSERT ON BookGenre TO data_entry;
GRANT SELECT, INSERT ON Copy TO data_entry;
GRANT SELECT, INSERT ON Reader TO data_entry;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO data_entry;

-- ============================================
-- ПРАВА ДЛЯ СУПЕРВИЗОРА
-- ============================================
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO supervisor;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO supervisor;
GRANT DELETE ON Reception TO supervisor;

-- ============================================
-- ПРАВА ДЛЯ ГОСТЯ (минимальные)
-- ============================================
GRANT SELECT ON Genre TO guest;
GRANT SELECT ON Author TO guest;
GRANT SELECT ON Book TO guest;
GRANT SELECT ON Tags TO guest;

-- ============================================
-- ПРАВА ДЛЯ МЕНЕДЖЕРА
-- ============================================
GRANT SELECT ON ALL TABLES IN SCHEMA public TO manager;
GRANT SELECT, INSERT, UPDATE ON Employees TO manager;
GRANT SELECT, INSERT, UPDATE ON Roles TO manager;
GRANT SELECT, INSERT, UPDATE ON EmployeeStatus TO manager;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO manager;
