-- ============================================================
--  Pro-Link Database Schema
--  Run this in phpMyAdmin or via MySQL CLI:
--    mysql -u root -p < prolink.sql
-- ============================================================

CREATE DATABASE IF NOT EXISTS prolink;
USE prolink;

-- ─── Departments ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS departments (
    id      VARCHAR(50)  PRIMARY KEY,
    name    VARCHAR(100) NOT NULL
);

-- ─── Persons (shared table for all roles) ───────────────────
CREATE TABLE IF NOT EXISTS persons (
    id       VARCHAR(50)  PRIMARY KEY,
    name     VARCHAR(100) NOT NULL,
    email    VARCHAR(150) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role     ENUM('admin','mentor','intern') NOT NULL,
    image    VARCHAR(255) DEFAULT 'assets/admin.png'
);

-- ─── Mentors (extends persons) ───────────────────────────────
CREATE TABLE IF NOT EXISTS mentors (
    id            VARCHAR(50) PRIMARY KEY,
    department_id VARCHAR(50),
    FOREIGN KEY (id)            REFERENCES persons(id)     ON DELETE CASCADE,
    FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE SET NULL
);

-- ─── Interns (extends persons) ──────────────────────────────
CREATE TABLE IF NOT EXISTS interns (
    id            VARCHAR(50) PRIMARY KEY,
    department_id VARCHAR(50),
    status        ENUM('Pending','Approved','Rejected') DEFAULT 'Pending',
    mentor_id     VARCHAR(50) DEFAULT '',
    FOREIGN KEY (id)            REFERENCES persons(id)     ON DELETE CASCADE,
    FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE SET NULL
);

-- ─── Attendance ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS attendances (
    id         VARCHAR(100) PRIMARY KEY,
    intern_id  VARCHAR(50)  NOT NULL,
    date       VARCHAR(20)  NOT NULL,
    is_present TINYINT(1)   NOT NULL DEFAULT 0,
    FOREIGN KEY (intern_id) REFERENCES persons(id) ON DELETE CASCADE
);

-- ─── Evaluations (marks) ────────────────────────────────────
CREATE TABLE IF NOT EXISTS evaluations (
    id        VARCHAR(100) PRIMARY KEY,
    intern_id VARCHAR(50)  NOT NULL,
    skill     VARCHAR(100) NOT NULL,
    mark      INT          NOT NULL,
    FOREIGN KEY (intern_id) REFERENCES persons(id) ON DELETE CASCADE
);

-- ─── Training Files ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS training_files (
    id        VARCHAR(100) PRIMARY KEY,
    title     VARCHAR(255) NOT NULL,
    file_url  TEXT         NOT NULL,
    mentor_id VARCHAR(50)  NOT NULL,
    intern_id VARCHAR(50)  NOT NULL,
    FOREIGN KEY (mentor_id) REFERENCES persons(id) ON DELETE CASCADE
);

-- ─── Policies ───────────────────────────────────────────────  ← ADDED
CREATE TABLE IF NOT EXISTS policies (
    id        VARCHAR(100) PRIMARY KEY,
    title     VARCHAR(255) NOT NULL,
    description VARCHAR(255)         NOT NULL
);

-- ─── Schedules ──────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS schedules (
    id          VARCHAR(100) PRIMARY KEY,
    intern_id   VARCHAR(50)  NOT NULL,
    intern_name VARCHAR(100) NOT NULL,
    day         VARCHAR(20)  NOT NULL,
    time        VARCHAR(20)  NOT NULL,
    type        VARCHAR(50)  NOT NULL,
    FOREIGN KEY (intern_id) REFERENCES persons(id) ON DELETE CASCADE  -- ← ADDED
);

-- ─── Seed Data ──────────────────────────────────────────────
INSERT IGNORE INTO departments VALUES
    ('dept1', 'IT'),
    ('dept2', 'HR'),
    ('dept3', 'Finance');

-- Admin
INSERT IGNORE INTO persons VALUES
    ('admin1', 'Admin', 'admin@prolink.dz', 'admin123', 'admin', 'assets/admin.png');

-- Mentor
INSERT IGNORE INTO persons VALUES
    ('mentor1', 'Sara Mentor', 'sara@prolink.dz', 'sara123', 'mentor', 'assets/admin.png');
INSERT IGNORE INTO mentors VALUES ('mentor1', 'dept1');

-- Sample intern (Pending – must be approved before login)
INSERT IGNORE INTO persons VALUES
    ('intern1', 'Ali Intern', 'ali@prolink.dz', 'ali123', 'intern', 'assets/student1.png');
INSERT IGNORE INTO interns VALUES ('intern1', 'dept1', 'Approved', 'mentor1');