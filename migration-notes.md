# Звіт з міграцій (Лабораторна робота 6)
**Проєкт:** Вебзастосунок для ведення особистого бюджету.
**Інструмент:** Prisma ORM

У цьому файлі задокументовано кроки еволюції схеми бази даних за допомогою інструменту Prisma Migrate.

## Міграція 1: Додавання нової таблиці (`add-notes-table`)
**Опис:** Створено нову модель `notes` для збереження особистих нотаток користувача, а також додано зв'язок один-до-багатьох між `users` та `notes`.
**Код "Після" (фрагмент schema.prisma):**
` ` `prisma
model notes {
  note_id    Int     @id @default(autoincrement())
  user_id    Int?
  title      String  @db.VarChar(100)
  content    String?
  users      users?  @relation(fields: [user_id], references: [user_id], onDelete: NoAction, onUpdate: NoAction)
}

model users {
  // ... інші поля ...
  notes             notes[]
}
` ` `

## Міграція 2: Додавання поля до існуючої таблиці (`add-is-active-to-users`)
**Опис:** До моделі `users` додано булеве поле `is_active`, щоб відстежувати статус акаунта (активний/заблокований) зі значенням за замовчуванням `true`.
**Код "До":**
` ` `prisma
model users {
  user_id           Int       @id @default(autoincrement())
  first_name        String    @db.VarChar(50)
  // ...
}
` ` `
**Код "Після":**
` ` `prisma
model users {
  user_id           Int       @id @default(autoincrement())
  first_name        String    @db.VarChar(50)
  // ...
  is_active         Boolean   @default(true)
}
` ` `

## Міграція 3: Видалення поля (`drop-mobile-number`)
**Опис:** Видалено поле `mobile_number` з таблиці `users`, оскільки авторизація та комунікація в застосунку відбуватиметься виключно через email.
**Код "До":**
` ` `prisma
model users {
  // ...
  email             String    @unique @db.VarChar(100)
  mobile_number     String?   @db.VarChar(20)
  password_hash     String    @db.VarChar(255)
  // ...
}
` ` `
**Код "Після":**
` ` `prisma
model users {
  // ...
  email             String    @unique @db.VarChar(100)
  password_hash     String    @db.VarChar(255)
  // ...
}
` ` `