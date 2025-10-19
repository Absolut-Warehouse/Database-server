-- -------------------------
-- USERS
-- -------------------------
INSERT INTO "user" (user_nom, user_prenom, "password", email, user_phone_number, sexe) VALUES
('Dupont', 'Jean', 'motdepasse1', 'jean.dupont@email.com', '+33611223344', 'H'),
('Martin', 'Claire', 'securepass2', 'claire.martin@email.com', '+33655667788', 'F'),
('Durand', 'Alex', '12345678', 'alex.durand@email.com', NULL, 'N'),
('Lemoine', 'Sophie', 'abcdefghi', 'sophie.lemoine@email.com', '+33777889900', 'F'),
('Nguyen', 'Minh', 'minhpass123', 'minh.nguyen@email.com', '+33700112233', 'H'),
('Moreau', 'Isabelle', 'passisabelle', 'isabelle.moreau@email.com', '+33600011223', 'F'),
('Petit', 'Luc', 'lucpass123', 'luc.petit@email.com', '+33699887766', 'H'),
('Leroy', 'Nina', 'ninapass456', 'nina.leroy@email.com', NULL, 'F'),
('Roux', 'Marc', 'marcpass789', 'marc.roux@email.com', '+33711223344', 'H'),
('Garcia', 'Emma', 'emma@secure1', 'emma.garcia@email.com', '+33644556677', 'F');

-- -------------------------
-- USER ACTIVITY
-- -------------------------
INSERT INTO user_activity (user_id, created_at, last_login, last_action, session_token)
SELECT u.user_id, 
       ua.created_at::timestamp, 
       ua.last_login::timestamp, 
       ua.last_action::timestamp, 
       gen_random_uuid()
FROM (
    VALUES
    ('jean.dupont@email.com', '2025-10-01 08:30:00', '2025-10-17 10:45:00', '2025-10-17 11:00:00'),
    ('claire.martin@email.com', '2025-09-15 09:00:00', '2025-10-16 14:10:00', '2025-10-16 14:30:00'),
    ('alex.durand@email.com', '2025-08-20 11:15:00', NULL, NULL),
    ('sophie.lemoine@email.com', '2025-10-10 15:45:00', '2025-10-17 16:00:00', '2025-10-17 16:30:00'),
    ('minh.nguyen@email.com', '2025-10-05 13:20:00', '2025-10-18 08:00:00', '2025-10-18 08:10:00')
) AS ua(email, created_at, last_login, last_action)
JOIN "user" u ON u.email = ua.email;


-- -------------------------
-- STORAGE ZONES
-- -------------------------
INSERT INTO storage_zone (zone_name, zone_size, zone_refrigerated) VALUES
('A1', 1000, TRUE),
('B2', 2000, FALSE),
('C3', 1500, FALSE),
('D4', 500, TRUE),
('E5', 3000, FALSE);

-- -------------------------
-- STORAGE SPACES
-- -------------------------
INSERT INTO storage_space (space_code, space_type, max_capacity, occupied_capacity, zone_name) VALUES
('A001', 'shelf', 100.00, 45.00, 'A1'),
('A002', 'ground', 150.00, 60.00, 'A1'),
('B101', 'box', 50.00, 10.00, 'B2'),
('B102', 'shelf', 200.00, 150.00, 'B2'),
('C201', 'ground', 500.00, 300.00, 'C3'),
('C202', 'box', 80.00, 20.00, 'C3'),
('D301', 'shelf', 100.00, 0.00, 'D4'),
('E401', 'box', 70.00, 25.00, 'E5'),
('E402', 'ground', 1000.00, 800.00, 'E5'),
('E403', 'shelf', 120.00, 50.00, 'E5');

-- -------------------------
-- ITEMS
-- -------------------------
INSERT INTO item (item_weight, item_status, item_estimated_delivery, item_entry_time, item_exit_time, space_code)
VALUES
(5.25, 'in_storage', NULL, '2025-10-10', NULL, 'A001'),
(10.00, 'outbound', '2025-10-20', '2025-10-12', NULL, 'A002'),
(1.10, 'delivered', '2025-10-15', '2025-10-05', '2025-10-14', NULL),
(3.75, 'picked_up', '2025-10-17', '2025-10-10', '2025-10-17', NULL),
(2.50, 'in_storage', NULL, '2025-10-15', NULL, 'B101'),
(0.95, 'in_storage', NULL, '2025-10-10', NULL, 'B102'),
(15.00, 'in_storage', NULL, '2025-10-01', NULL, 'B102'),
(8.30, 'outbound', '2025-10-22', '2025-10-18', NULL, 'C202'),
(20.00, 'in_storage', NULL, '2025-10-03', NULL, 'B102'),
(7.00, 'picked_up', '2025-10-16', '2025-10-12', '2025-10-16', NULL),
(4.20, 'in_storage', NULL, '2025-10-05', NULL, 'D301'),
(3.80, 'outbound', '2025-10-25', '2025-10-18', NULL, 'E401'),
(6.50, 'in_storage', NULL, '2025-10-14', NULL, 'E402'),
(2.20, 'delivered', '2025-10-12', '2025-10-10', '2025-10-11', NULL),
(1.60, 'in_storage', NULL, '2025-10-15', NULL, 'A001'),
(12.00, 'in_storage', NULL, '2025-10-15', NULL, 'A002'),
(9.30, 'picked_up', '2025-10-17', '2025-10-13', '2025-10-17', NULL),
(2.90, 'in_storage', NULL, '2025-10-14', NULL, 'B101'),
(5.60, 'in_storage', NULL, '2025-10-16', NULL, 'B102'),
(0.80, 'in_storage', NULL, '2025-10-17', NULL, 'C202');

-- -------------------------
-- PACKAGE
-- -------------------------
-- INSERT dynamique dans package sans hardcoder les item_id
INSERT INTO package (package_code, package_refrigerated, package_fragile, item_id)
SELECT pkg.package_code,
       pkg.package_refrigerated,
       pkg.package_fragile,
       i.item_id
FROM (
    VALUES
    ('PKG001', FALSE, TRUE, 'A001'),
    ('PKG002', TRUE, FALSE, 'A002'),
    ('PKG003', FALSE, FALSE, 'B101'),
    ('PKG004', TRUE, TRUE, 'B102')
) AS pkg(package_code, package_refrigerated, package_fragile, space_code)
JOIN (
    SELECT DISTINCT ON (space_code) * 
    FROM item
    WHERE item_status = 'in_storage'
) i ON i.space_code = pkg.space_code;


-- -------------------------
-- CONTAINER
-- -------------------------
INSERT INTO container (volume, description, special_requirement, item_id)
SELECT 
    c.volume, 
    c.description, 
    c.special_requirement, 
    i.item_id
FROM (
    VALUES
    (50.00, 'Container étanche', 'Keep dry', 'A001'),
    (100.00, 'Conteneur renforcé', 'Heavy weight', 'A002'),
    (75.00, NULL, NULL, 'A003'),
    (60.00, 'Conteneur isolé', 'Refrigerated', 'B101'),
    (80.00, 'Standard box', NULL, 'B102')
) AS c(volume, description, special_requirement, ref_space_code)
JOIN item i ON i.space_code = c.ref_space_code
WHERE i.item_status = 'in_storage';  -- filtrage pour ne prendre que les items encore en stockage


-- -------------------------
-- ADDRESS
-- -------------------------
INSERT INTO address (user_email, complementary, country, postal_code, city, street, street_number) VALUES
('jean.dupont@email.com', 'Appt 4B', 'France', '75001', 'Paris', 'Rue de Rivoli', '10'),
('claire.martin@email.com', NULL, 'France', '69001', 'Lyon', 'Rue de la République', '5'),
('alex.durand@email.com', NULL, 'France', '13001', 'Marseille', 'La Canebière', '3A'),
('sophie.lemoine@email.com', NULL, 'France', '31000', 'Toulouse', 'Rue Alsace Lorraine', '12B'),
('minh.nguyen@email.com', 'Bât A', 'France', '44000', 'Nantes', 'Cours des 50 Otages', '8'),
('isabelle.moreau@email.com', 'Etage 3', 'France', '67000', 'Strasbourg', 'Rue des Frères', '18'),
('luc.petit@email.com', NULL, 'France', '06000', 'Nice', 'Avenue Jean Médecin', '21B'),
('nina.leroy@email.com', 'Appt 9', 'France', '80000', 'Amiens', 'Rue des Jacobins', '7'),
('marc.roux@email.com', NULL, 'France', '21000', 'Dijon', 'Rue de la Liberté', '4A'),
('emma.garcia@email.com', 'Bât B', 'France', '34000', 'Montpellier', 'Boulevard du Jeu de Paume', '5');

-- -------------------------
-- SUPPLIER
-- -------------------------
INSERT INTO supplier (user_email, supplier_name, supplier_type) VALUES
('jean.dupont@email.com', 'MediPlus', 'medical'),
('claire.martin@email.com', 'FoodExpress', 'food'),
('alex.durand@email.com', 'HomeBasics', 'househould'),
('sophie.lemoine@email.com', 'ElectroStore', 'electronic'),
('minh.nguyen@email.com', 'IndusPro', 'industry');

-- -------------------------
-- EMPLOYEE
-- -------------------------
INSERT INTO employee (user_email, position, hire_date) VALUES
('jean.dupont@email.com', 'Gestionnaire', '2023-06-01'),
('claire.martin@email.com', 'Répartiteur', '2024-01-15'),
('alex.durand@email.com', 'Livreur', '2025-03-20'),
('sophie.lemoine@email.com', 'Répartiteur', '2024-11-05'),
('minh.nguyen@email.com', 'Gestionnaire', '2022-09-10');

-- -------------------------
-- TERMINAL
-- -------------------------
INSERT INTO terminal (permission_code, terminal_name, zone_id)
SELECT t.permission_code, t.terminal_name, z.zone_id
FROM (
    VALUES
    ('RW', 'A001', 'A1'),
    ('RX', 'A002', 'B2'),
    ('XW', 'A003', 'C3'),
    ('RX', 'B001', 'D4'),
    ('RW', 'B005', 'E5')
) AS t(permission_code, terminal_name, ref_zone)
JOIN storage_zone z ON z.zone_name = t.ref_zone;

-- -------------------------
-- EQUIPMENT
-- -------------------------
INSERT INTO equipment (equipment_name, equipment_type, status, purchase_date, maintenance_cycle, zone_id)
SELECT e.equipment_name, 
       e.equipment_type::equipment_model, 
       e.status::equipment_status, 
       e.purchase_date::date, 
       e.maintenance_cycle, 
       z.zone_id
FROM (
    VALUES
    ('Scanner 1', 'scanner', 'normal', '2024-05-10', 180, 'A1'),
    ('Forklift 1', 'forklift', 'maintenance', '2023-03-15', 365, 'B2'),
    ('Sorter X', 'sorter', 'fault', '2022-11-01', 90, 'C3'),
    ('Scanner 2', 'scanner', 'normal', '2025-01-20', 180, 'D4'),
    ('Forklift 2', 'forklift', 'normal', '2024-08-05', 365, 'E5')
) AS e(equipment_name, equipment_type, status, purchase_date, maintenance_cycle, zone_name)
JOIN storage_zone z ON z.zone_name = e.zone_name;


-- -------------------------
-- ORDERS
-- -------------------------
INSERT INTO "order" (order_id, order_priority, source_address_id, destination_address_id)
SELECT 
    i.item_id,
    o.order_priority,
    s.address_id,
    d.address_id
FROM (
    VALUES
    ('A001', 2, 'isabelle.moreau@email.com', 'luc.petit@email.com'),
    ('A002', 4, 'luc.petit@email.com', 'nina.leroy@email.com'),
    ('A003', 1, 'nina.leroy@email.com', 'marc.roux@email.com'),
    ('B101', 5, 'marc.roux@email.com', 'emma.garcia@email.com'),
    ('B102', 3, 'emma.garcia@email.com', 'jean.dupont@email.com')
) AS o(ref_space_code, order_priority, source_email, dest_email)
JOIN item i ON i.space_code = o.ref_space_code
JOIN address s ON s.user_email = o.source_email
JOIN address d ON d.user_email = o.dest_email
WHERE s.address_id <> d.address_id;

-- -------------------------
-- WORKS_ON
-- -------------------------
INSERT INTO works_on (terminal_id, employee_id)
SELECT t.terminal_id, e.employee_id
FROM (
    VALUES
    ('A001', 'jean.dupont@email.com'),
    ('A002', 'claire.martin@email.com'),
    ('A003', 'alex.durand@email.com'),
    ('B001', 'sophie.lemoine@email.com'),
    ('B005', 'minh.nguyen@email.com')
) AS w(ref_terminal, ref_email)
JOIN terminal t ON t.terminal_name = w.ref_terminal
JOIN employee e ON e.user_email = w.ref_email;
