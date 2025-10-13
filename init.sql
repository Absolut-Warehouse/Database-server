-- Différents Type défini pour les contraintes de nos colonnes dans certaines tables

CREATE TYPE SEXE AS ENUM ('F', 'H', 'N');
CREATE TYPE EQUIPMENT_MODEL AS ENUM ('scanner', 'forklift', 'sorter');
CREATE TYPE EQUIPMENT_STATUS AS ENUM ('normal', 'maintenance', 'fault');
CREATE TYPE SPACE_TYPE AS ENUM ('shelf', 'ground', 'box');
CREATE TYPE EMPLOYEE_POSTE AS ENUM ('Gestionnaire', 'Répartiteur', 'Livreur');
CREATE TYPE ITEM_STATUS AS ENUM ('in_storage', 'outbound', 'delivered', 'picked_up');
CREATE TYPE SUPPLIER_TYPE AS ENUM ('medical', 'food', 'househould', 'electronic', 'industry');


-- Tables simple

CREATE TABLE "user" (
	user_id INT PRIMARY KEY, 
	user_nom VARCHAR(50)  NOT NULL CHECK (LENGTH(user_nom) > 1), 
	user_prenom VARCHAR(40) NOT NULL CHECK (LENGTH(user_prenom) > 1), 
	"password" VARCHAR(100) NOT NULL CHECK(LENGTH("password") > 5),
	email VARCHAR(100) NOT NULL CHECK (email ~* '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'),
	user_phone_number VARCHAR(14) NULL CHECK(user_phone_number ~* '^\+?[1-9][0-9]{6,14}$'),
	sexe SEXE NULL
	);

CREATE TABLE storage_zone (
	zone_id INT PRIMARY KEY,
	zone_name CHAR(2) NOT NULL UNIQUE CHECK(zone_name ~* '^[A-Z]+[0-9]$'),
	zone_size INT NOT NULL CHECK(zone_size > 0),
	zone_refrigirerated BOOLEAN NULL
);


-- Tables dépendance faible

CREATE TABLE storage_space (
	storage_space_id INT PRIMARY KEY,
	space_code CHAR(4) NOT NULL UNIQUE CHECK( space_code ~ '^[A-Z][0-9]{3}$'),
	space_type SPACE_TYPE NOT NULL,
	max_capacity DECIMAL(10,2) NOT NULL CHECK(max_capacity >0),
	occupied_capacity DECIMAL(10,2) NOT NULL CHECK(occupied_capacity >= 0 AND occupied_capacity <= max_capacity ),
	zone_id INT NOT NULL,
	CONSTRAINT fk_zone FOREIGN KEY(zone_id) REFERENCES storage_zone(zone_id) ON DELETE CASCADE
);

CREATE TABLE item(
	item_id INT PRIMARY KEY,
	item_weight DECIMAL(10,3) NOT NULL CHECK(item_weight > 0),
	item_status ITEM_STATUS NOT NULL DEFAULT 'in_storage',
	item_estimated_delivery DATE NULL,
	item_entry_time DATE NULL,
	item_exit_time DATE NULL,
	storage_space_id INT NULL,
	CONSTRAINT fk_storage_space FOREIGN KEY(storage_space_id) REFERENCES storage_space(storage_space_id)
);

CREATE TABLE package (
	package_id INT PRIMARY KEY,
	package_code VARCHAR(50) UNIQUE NOT NULL,
	package_refregirated BOOLEAN DEFAULT false,
	package_fragile BOOLEAN DEFAULT false,

	item_id INT NOT NULL UNIQUE,
	CONSTRAINT fk_item FOREIGN KEY(item_id) REFERENCES item(item_id) ON DELETE CASCADE
);

CREATE TABLE container (
	container_id INT PRIMARY KEY,
	volume DECIMAL(10,2) NOT NULL CHECK( volume>0),
	description TEXT NULL,
	special_requirement VARCHAR(255) NULL,
	item_id INT NOT NULL UNIQUE,
	CONSTRAINT fk_item FOREIGN KEY(item_id) REFERENCES item(item_id) ON DELETE CASCADE
	);

CREATE TABLE address (
	address_id INT PRIMARY KEY,
	complementary VARCHAR(100) NULL,
	country VARCHAR(30) NOT NULL,
	postal_code VARCHAR(30) NOT NULL,
	city VARCHAR(50) NOT NULL,
	street VARCHAR(30) NOT NULL,
	street_number VARCHAR(10) NOT NULL,

	user_id INT NOT NULL,
	CONSTRAINT fk_user FOREIGN KEY(user_id) REFERENCES "user"(user_id) ON DELETE CASCADE
);

CREATE TABLE supplier(
	supplier_id INT PRIMARY KEY,
	supplier_name VARCHAR(20) NOT NULL,
	supplier_type SUPPLIER_TYPE NULL,

	user_id INT NOT NULL UNIQUE,
	CONSTRAINT fk_user FOREIGN KEY(user_id) REFERENCES "user"(user_id) ON DELETE CASCADE
);

CREATE TABLE employee (
	employee_id INT PRIMARY KEY,
	position EMPLOYEE_POSTE NOT NULL,
	hire_date DATE NOT NULL,

	user_id INT NOT NULL UNIQUE,
	CONSTRAINT fk_user FOREIGN KEY(user_id) REFERENCES "user"(user_id) ON DELETE CASCADE
);

CREATE TABLE terminal(
	terminal_id INT PRIMARY KEY,
	permission CHAR(2) NOT NULL CHECK(permission ~ '^[RX][WX]$'),
	terminal_name VARCHAR(12) NOT NULL UNIQUE CHECK(terminal_name ~ '^[A-Z][0-9]*$'),
	zone_id INT NOT NULL,
	CONSTRAINT fk_storage_zone FOREIGN KEY(zone_id) REFERENCES storage_zone(zone_id)
);

CREATE TABLE equipment (
	equipment_id INT PRIMARY KEY,
	equipment_name VARCHAR(50) NOT NULL,
	equipment_type EQUIPMENT_MODEL NOT NULL,
	status EQUIPMENT_STATUS NOT NULL,
	purchase_date DATE NULL,
	maintenance_cycle INT NULL CHECK( maintenance_cycle >= 0 ),
	zone_id INT NOT NULL,
	CONSTRAINT fk_storage_zone FOREIGN KEY(zone_id) REFERENCES storage_zone(zone_id)
);


-- Tables dépendance forte


CREATE TABLE "order"(
	order_id INT PRIMARY KEY,
	order_priority INT NOT NULL CHECK( order_priority > 0 AND order_priority < 6),
	source_address_id INT NOT NULL CHECK(source_address_id <> destination_address_id),
	destination_address_id INT NOT NULL,
	CONSTRAINT fk_source_address FOREIGN KEY(source_address_id) REFERENCES address(address_id) ON DELETE CASCADE,
	CONSTRAINT fk_destination_address FOREIGN KEY(destination_address_id) REFERENCES address(address_id) ON DELETE CASCADE
);

CREATE TABLE works_on (
    terminal_id INT NOT NULL,
    employee_id INT NOT NULL,
    CONSTRAINT fk_terminal FOREIGN KEY (terminal_id) REFERENCES terminal(terminal_id) ON DELETE CASCADE,
    CONSTRAINT fk_employee FOREIGN KEY (employee_id) REFERENCES employee(employee_id) ON DELETE CASCADE,
    PRIMARY KEY (terminal_id, employee_id)
);