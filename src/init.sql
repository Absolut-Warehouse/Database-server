-- -------------------------
-- Types ENUM
-- -------------------------
CREATE TYPE sexe AS ENUM ('F', 'H', 'N');
CREATE TYPE equipment_model AS ENUM ('scanner', 'forklift', 'sorter');
CREATE TYPE equipment_status AS ENUM ('normal', 'maintenance', 'fault');
CREATE TYPE space_type AS ENUM ('shelf', 'ground', 'box');
CREATE TYPE employee_poste AS ENUM ('Gestionnaire', 'Répartiteur', 'Livreur');
CREATE TYPE item_status AS ENUM ('in_storage', 'outbound', 'delivered', 'picked_up');
CREATE TYPE supplier_type AS ENUM ('medical', 'food', 'househould', 'electronic', 'industry');

-- -------------------------
-- Tables principales
-- -------------------------
CREATE TABLE "user" (
    user_id BIGSERIAL PRIMARY KEY,
    user_nom VARCHAR(50) NOT NULL
        CHECK (LENGTH(user_nom) > 1 AND user_nom ~ '^[A-Za-z0-9]+$'),
    user_prenom VARCHAR(40) NOT NULL
        CHECK (LENGTH(user_prenom) > 1 AND user_prenom ~ '^[A-Za-z0-9]+$'),
    "password" VARCHAR(100) NOT NULL CHECK(LENGTH("password") > 5),
    email VARCHAR(100) UNIQUE NOT NULL CHECK (email ~* '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'),
    user_phone_number VARCHAR(14) NULL CHECK(user_phone_number ~* '^\+?[1-9][0-9]{6,14}$'),
    sexe sexe NULL
);

CREATE TABLE storage_zone (
    zone_id BIGSERIAL PRIMARY KEY,
    zone_name CHAR(2) NOT NULL UNIQUE CHECK(zone_name ~* '^[A-Z][0-9]$'),
    zone_size INT NOT NULL CHECK(zone_size > 0),
    zone_refrigerated BOOLEAN DEFAULT FALSE
);

-- -------------------------
-- Tables dépendantes faibles
-- -------------------------
CREATE TABLE storage_space (
    storage_space_id BIGSERIAL PRIMARY KEY,
    space_code CHAR(4) NOT NULL UNIQUE CHECK(space_code ~ '^[A-Z][0-9]{3}$'),
    space_type SPACE_TYPE NOT NULL,
    max_capacity DECIMAL(10,2) NOT NULL CHECK(max_capacity > 0),
    occupied_capacity DECIMAL(10,2) NOT NULL CHECK(occupied_capacity >= 0 AND occupied_capacity <= max_capacity),
    zone_name CHAR(2) NOT NULL,
    CONSTRAINT fk_zone FOREIGN KEY(zone_name) REFERENCES storage_zone(zone_name) ON DELETE CASCADE
);

CREATE TABLE item (
    item_id BIGSERIAL PRIMARY KEY,
    item_weight DECIMAL(10,3) NOT NULL CHECK(item_weight > 0),
    item_status ITEM_STATUS NOT NULL DEFAULT 'in_storage',
    item_estimated_delivery DATE NULL,
    item_entry_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    item_exit_time TIMESTAMP NULL,
    space_code CHAR(4) NOT NULL,
    CONSTRAINT fk_storage_space FOREIGN KEY(space_code) REFERENCES storage_space(space_code) ON DELETE SET NULL
);


CREATE TABLE package (
    package_id BIGSERIAL PRIMARY KEY,
    package_code VARCHAR(50) NOT NULL UNIQUE,
    package_refrigerated BOOLEAN DEFAULT FALSE,
    package_fragile BOOLEAN DEFAULT FALSE,
    item_id BIGINT NOT NULL UNIQUE REFERENCES item(item_id) ON DELETE CASCADE
);

CREATE TABLE container (
    container_id BIGSERIAL PRIMARY KEY,
    volume DECIMAL(10,2) NOT NULL CHECK(volume > 0),
    description TEXT NULL,
    special_requirement VARCHAR(255) NULL,
    item_id BIGINT NOT NULL UNIQUE REFERENCES item(item_id) ON DELETE CASCADE
);

CREATE TABLE address (
    address_id BIGSERIAL PRIMARY KEY,
    user_email VARCHAR(100) NOT NULL UNIQUE,
    complementary VARCHAR(100) NULL,
    country VARCHAR(30) NULL,
    postal_code VARCHAR(30) NULL,
    city VARCHAR(50) NULL,
    street VARCHAR(30) NULL,
    street_number VARCHAR(10) NULL,
    CONSTRAINT fk_user_email FOREIGN KEY(user_email) REFERENCES "user"(email) ON DELETE CASCADE
);

CREATE TABLE supplier (
    supplier_id BIGSERIAL PRIMARY KEY,
    user_email VARCHAR(100) NOT NULL UNIQUE,
    supplier_name VARCHAR(50) NOT NULL,
    supplier_type SUPPLIER_TYPE NULL,
    CONSTRAINT fk_supplier_user FOREIGN KEY(user_email) REFERENCES "user"(email) ON DELETE CASCADE
);

CREATE TABLE employee (
    employee_id BIGSERIAL PRIMARY KEY,
    user_email VARCHAR(100) NOT NULL UNIQUE,
    position EMPLOYEE_POSTE NOT NULL,
    hire_date DATE NOT NULL,
    CONSTRAINT fk_employee_user FOREIGN KEY(user_email) REFERENCES "user"(email) ON DELETE CASCADE
);

CREATE TABLE terminal (
    terminal_id BIGSERIAL PRIMARY KEY,
    terminal_name VARCHAR(12) NOT NULL UNIQUE CHECK(terminal_name ~ '^[A-Z][0-9]*$'),
    permission_code CHAR(2) NOT NULL CHECK(permission_code ~ '^[RX][WX]$'),
    zone_id BIGINT NOT NULL REFERENCES storage_zone(zone_id) ON DELETE CASCADE
);

CREATE TABLE equipment (
    equipment_id BIGSERIAL PRIMARY KEY,
    equipment_name VARCHAR(50) NOT NULL,
    equipment_type equipment_model NOT NULL,
    status equipment_status NOT NULL,
    purchase_date DATE NULL,
    maintenance_cycle INT NULL CHECK(maintenance_cycle >= 0),
    zone_id BIGINT NOT NULL REFERENCES storage_zone(zone_id) ON DELETE CASCADE
);

CREATE TABLE user_activity (
    user_id BIGINT PRIMARY KEY REFERENCES "user"(user_id) ON DELETE CASCADE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    last_action TIMESTAMP NULL,
    session_token UUID NULL UNIQUE
);

-- -------------------------
-- Tables dépendantes fortes
-- -------------------------
CREATE TABLE "order" (
    order_id BIGINT PRIMARY KEY REFERENCES item(item_id) ON DELETE CASCADE,
    order_priority INT NOT NULL CHECK(order_priority > 0 AND order_priority < 6),
    source_address_id BIGINT NOT NULL REFERENCES address(address_id) ON DELETE CASCADE,
    destination_address_id BIGINT NOT NULL REFERENCES address(address_id) ON DELETE CASCADE,
    CHECK(source_address_id <> destination_address_id)
);


CREATE TABLE works_on (
    terminal_id BIGINT NOT NULL REFERENCES terminal(terminal_id) ON DELETE CASCADE,
    employee_id BIGINT NOT NULL REFERENCES employee(employee_id) ON DELETE CASCADE,
    PRIMARY KEY (terminal_id, employee_id)
);


GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO yuhaohan;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO yuhaohan_thomas;

