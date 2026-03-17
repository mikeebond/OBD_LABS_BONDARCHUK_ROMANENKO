# Звіт з нормалізації бази даних (Лабораторна робота 5)
Проєкт Вебзастосунок для ведення особистого бюджету.

## 1. Аналіз початкової (ненормалізованої) схеми
Початкова схема бази даних була спроєктована у попередніх лабораторних роботах. Вона вже частково нормалізована, але має кілька недоліків.

Функціональні залежності (ФЗ) початкової схеми
 Users `user_id` - `name_surname`, `email`, `mobile_number`, `password_hash`, `registration_date`
 Accounts `account_id` - `user_id`, `account_name`, `balance`, `currency`
 Transactions `transaction_id` - `account_id`, `category_id`, `amount`, `transaction_date`, `description`
 Transaction_Tags (`transaction_id`, `tag_id`) - (немає інших атрибутів)

Найвища нормальна форма початкової схеми Схема частково знаходиться у 1NF, але має порушення строгих правил 1NF та потенційні проблеми з 3NF.

## 2. Перехід до Першої нормальної форми (1NF)
[cite_start]Правило 1NF Усі атрибути є атомарними (без повторюваних груп). [cite_start]Якщо таблиця має стовпець, який може містити кілька значень, це порушує 1NF.

Порушення У таблиці `Users` атрибут `name_surname` містить відразу два факти ім'я та прізвище. Це не атомарне значення.
Рішення Розділяємо цей стовпець на два окремих атрибути `first_name` та `last_name`.

Команда для зміни (ALTER TABLE)
```sql
ALTER TABLE users DROP COLUMN name_surname;
ALTER TABLE users ADD COLUMN first_name VARCHAR(50) NOT NULL;
ALTER TABLE users ADD COLUMN last_name VARCHAR(50) NOT NULL;