DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS projects;
DROP TABLE IF EXISTS members;
DROP TABLE IF EXISTS tasks;
DROP TABLE IF EXISTS comments;
DROP TABLE IF EXISTS states;

CREATE TABLE users
(
    id int auto_increment primary key,
    name varchar(50) not null,
    mail_address varchar(50) not null,
    hashed_password varchar(256) not null
);

CREATE TABLE projects
(
    id int auto_increment primary key,
    name varchar(50) not null,
    owner_id int not null,
    detail text
);

CREATE TABLE members
(
    id int auto_increment primary key,
    project_id int not null, 
    user_id int not null
);

CREATE TABLE tasks
(
    id int auto_increment primary key,
    project_id int not null,
    title varchar(10) not null,
    create_date timestamp DEFAULT (datetime(CURRENT_TIMESTAMP,'localtime')),
    update_date timestamp not null DEFAULT (datetime('now', 'localtime')),
    deadline date,
    user_id int,
    state_id int,
    detail text
);

Create TABLE comments
(
    id int auto_increment primary key, 
    task_id int not null,
    user_id int not null,
    comment text,
    create_date timestamp not null DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE states
(
    id int auto_increment primary key,
    project_id int not null,
    name varchar(20) not null,
    progress int not null
);
