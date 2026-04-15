-- Student Management System — PostgreSQL schema
CREATE TABLE IF NOT EXISTS students (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  age INT NOT NULL CHECK (age > 0 AND age < 150),
  student_class TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_students_student_class ON students (student_class);
