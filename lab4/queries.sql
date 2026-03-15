-- ==========================================
-- 1. АГРЕГАТНІ ФУНКЦІЇ ТА GROUP BY 
-- ==========================================

-- 1.1. Загальна кількість фінансових цілей та сумарна сума, яку потрібно зібрати всім користувачам (COUNT, SUM)
SELECT 
    COUNT(goal_id) AS total_goals, 
    SUM(target_amount) AS total_money_needed 
FROM goals;

-- 1.2. Середня, мінімальна та максимальна сума транзакції для кожної категорії витрат і доходів (AVG, MIN, MAX, GROUP BY)
SELECT 
    category_id, 
    ROUND(AVG(amount), 2) AS avg_transaction, 
    MIN(amount) AS min_transaction, 
    MAX(amount) AS max_transaction 
FROM transactions
GROUP BY category_id;

-- 1.3. Підрахунок кількость транзакцій по кожному рахунку, але лише для тих рахунків, де більше 1 транзакції (COUNT, GROUP BY, HAVING)
SELECT 
    account_id, 
    COUNT(transaction_id) AS transaction_count 
FROM transactions
GROUP BY account_id
HAVING COUNT(transaction_id)  1;

-- 1.4. Сумарний ліміт бюджетів для кожного користувача (SUM, GROUP BY)
SELECT 
    user_id, 
    SUM(limit_amount) AS total_budget_limit 
FROM budgets
GROUP BY user_id;


-- ==========================================
-- 2. ЗАПИТИ З РІЗНИМИ ТИПАМИ JOIN 
-- ==========================================

-- 2.1. INNER JOIN Виведення всіх транзакцій разом із назвою рахунку та іменем категорії
SELECT 
    t.transaction_date, 
    a.account_name, 
    c.category_name, 
    t.amount 
FROM transactions t
INNER JOIN accounts a ON t.account_id = a.account_id
INNER JOIN categories c ON t.category_id = c.category_id;

-- 2.2. LEFT JOIN Виведення всіх категорій та сум витратдоходів по них (навіть якщо по категорії ще не було транзакцій)
SELECT 
    c.category_name, 
    COALESCE(SUM(t.amount), 0) AS total_amount 
FROM categories c
LEFT JOIN transactions t ON c.category_id = t.category_id
GROUP BY c.category_name;

-- 2.3. RIGHT JOIN Виведення всіх тегів та відповідних їм транзакцій (навіть якщо тег ще ніде не використовувався)
SELECT 
    tg.tag_name, 
    tt.transaction_id 
FROM transaction_tags tt
RIGHT JOIN tags tg ON tt.tag_id = tg.tag_id;


-- ==========================================
-- 3. ЗАПИТИ З ПІДЗАПИТАМИ 
-- ==========================================

-- 3.1. Підзапит у WHERE Знайти всі транзакції, сума яких більша за середню суму всіх транзакцій у системі
SELECT 
    transaction_id, 
    amount, 
    description 
FROM transactions 
WHERE amount  (SELECT AVG(amount) FROM transactions);

-- 3.2. Підзапит у SELECT Вивести імена всіх користувачів та їхній загальний поточний баланс з усіх рахунків
SELECT 
    name_surname, 
    (SELECT COALESCE(SUM(balance), 0) FROM accounts WHERE accounts.user_id = users.user_id) AS total_balance 
FROM users;

-- 3.3. Підзапит із використанням IN Знайти всіх користувачів, які встановили хоча б одну фінансову ціль
SELECT 
    name_surname, 
    email 
FROM users 
WHERE user_id IN (SELECT DISTINCT user_id FROM goals);