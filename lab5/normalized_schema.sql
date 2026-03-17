### 2. Скрипт `normalized_schema.sql`
Цей файл містить оновлені інструкції `CREATE TABLE` для нашого нового дизайну, де схема знаходиться у 3NF[cite: 277]. Збережи його та перевір у pgAdmin[cite: 279].

```sql
-- 1. Видалення старих таблиць (якщо існують), щоб оновити схему
DROP TABLE IF EXISTS transaction_tags CASCADE;
DROP TABLE IF EXISTS transactions CASCADE;
DROP TABLE IF EXISTS goals CASCADE;
DROP TABLE IF EXISTS budgets CASCADE;
DROP TABLE IF EXISTS accounts CASCADE;
DROP TABLE IF EXISTS tags CASCADE;
DROP TABLE IF EXISTS categories CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS currencies CASCADE;

-- 2. Створення нових нормалізованих таблиць (3NF)

-- Таблиця Користувачів (1NF виконано: атомарні first_name та last_name)
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    mobile_number VARCHAR(20),
    password_hash VARCHAR(255) NOT NULL,
    registration_date DATE DEFAULT CURRENT_DATE
);

-- НОВА ТАБЛИЦЯ: Валюти (3NF виконано: усунення транзитивної залежності)
CREATE TABLE currencies (
    currency_code VARCHAR(3) PRIMARY KEY, -- Наприклад 'UAH', 'USD'
    currency_name VARCHAR(50) NOT NULL,
    symbol VARCHAR(5)
);

CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    type VARCHAR(50) NOT NULL CHECK (type IN ('Income', 'Expense'))
);

CREATE TABLE tags (
    tag_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id),
    tag_name VARCHAR(50) NOT NULL
);

-- Таблиця Рахунків оновлена (використовує FK на currencies)
CREATE TABLE accounts (
    account_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id),
    account_name VARCHAR(100) NOT NULL,
    balance NUMERIC(12, 2) DEFAULT 0.00,
    currency_code VARCHAR(3) REFERENCES currencies(currency_code)
);

CREATE TABLE budgets (
    budget_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id),
    category_id INTEGER REFERENCES categories(category_id),
    limit_amount NUMERIC(12, 2) NOT NULL CHECK (limit_amount > 0),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL
);

CREATE TABLE goals (
    goal_id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(user_id),
    goal_name VARCHAR(100) NOT NULL,
    target_amount NUMERIC(12, 2) NOT NULL CHECK (target_amount > 0),
    current_amount NUMERIC(12, 2) DEFAULT 0.00 CHECK (current_amount >= 0),
    deadline DATE
);

CREATE TABLE transactions (
    transaction_id SERIAL PRIMARY KEY,
    account_id INTEGER REFERENCES accounts(account_id),
    category_id INTEGER REFERENCES categories(category_id),
    amount NUMERIC(12, 2) NOT NULL,
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    description TEXT
);

CREATE TABLE transaction_tags (
    transaction_id INTEGER REFERENCES transactions(transaction_id),
    tag_id INTEGER REFERENCES tags(tag_id),
    PRIMARY KEY (transaction_id, tag_id)
);

-- 3. Заповнення базовими даними для перевірки
INSERT INTO currencies (currency_code, currency_name, symbol) VALUES 
('UAH', 'Українська гривня', '₴'),
('USD', 'Долар США', '$');

INSERT INTO users (first_name, last_name, email, mobile_number, password_hash) VALUES
('Михайло', 'Бондарчук', 'mykhailo@example.com', '+380501111111', 'hash123'),
('Іван', 'Романенко', 'ivan@example.com', '+380672222222', 'hash456');

INSERT INTO accounts (user_id, account_name, balance, currency_code) VALUES
(1, 'Картка Монобанк', 5000.00, 'UAH');