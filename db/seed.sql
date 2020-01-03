DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS projects;
DROP TABLE IF EXISTS members;
DROP TABLE IF EXISTS tasks;
DROP TABLE IF EXISTS comments;
DROP TABLE IF EXISTS states;

CREATE TABLE users
(
    id integer primary key,
    name varchar(50) not null,
    mail_address varchar(50) not null,
    hashed_password varchar(256) not null
);

CREATE TABLE projects
(
    id integer primary key,
    name varchar(50) not null,
    user_id integer not null,
    detail text
);

CREATE TABLE members
(
    id integer primary key,
    project_id integer not null, 
    user_id integer not null
);

CREATE TABLE tasks
(
    id integer primary key,
    project_id integer not null,
    title varchar(10) not null,
    create_date timestamp DEFAULT (datetime(CURRENT_TIMESTAMP,'localtime')),
    update_date timestamp not null DEFAULT (datetime('now', 'localtime')),
    deadline date,
    user_id integer,
    state_id integer,
    detail text
);

Create TABLE comments
(
    id integer primary key, 
    task_id integer not null,
    user_id integer not null,
    comment text,
    create_date timestamp not null DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE states
(
    id integer primary key,
    project_id integer not null,
    name varchar(20) not null,
    progress integer not null
);
