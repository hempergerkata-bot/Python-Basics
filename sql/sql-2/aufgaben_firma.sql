-- =====================================================================
--  Aufgaben zur Datenbank FIRMA  (Tabellen abteilung, mitarbeiter)
--  Themen: DDL · DML · DQL · JOIN · TCL
-- =====================================================================
--  So arbeiten Sie:
--   1. Terminal in diesem Ordner öffnen:  sqlite3 firma.db
--   2. Ausgangszustand herstellen:        .read firma.sql
--      dann:  PRAGMA foreign_keys = ON;   .headers on   .mode column   .nullvalue NULL
--   3. Diese Datei im Editor öffnen und unter jede Aufgabe Ihre SQL-Befehle schreiben.
--      Jeden Befehl in sqlite3 ausführen (abtippen oder kopieren) und mit "Erwartet" vergleichen.
--   4. Die Aufgaben bauen aufeinander auf - Reihenfolge einhalten!
--      Durcheinander? .read firma.sql und von vorn (oder ab der Stelle) weitermachen.
--
--  Ausgangsdaten:
--   abteilung:   1 IT · 2 HR · 3 Vertrieb · 4 Marketing (hat keine Mitarbeiter)
--   mitarbeiter: Anna, Clara, Eva (IT) · Ben, Greta (HR) · Dirk, Felix, Hakan (Vertrieb)
--                Ida (Azubi, abteilung_id = NULL)
--   Spalten mitarbeiter: id, vorname, nachname, abteilung_id, standort, gehalt, eintritt
-- =====================================================================


-- ===================================================================== DDL
-- Aufgabe 1 (CREATE)
-- Legen Sie die Tabelle projekt an:
--   id (Primärschlüssel), titel (Text bis 40 Zeichen, Pflicht),
--   abteilung_id (Pflicht, Fremdschlüssel auf abteilung),
--   budget (ganze Zahl, darf nicht negativ sein),
--   status (Text bis 10 Zeichen, Standardwert 'geplant').
-- Prüfen mit: .schema projekt

CREATE TABLE projekt (
    id INTEGER PRIMARY KEY,
    titel VARCHAR(40) NOT NULL,
    abteilung_id INTEGER NOT NULL,
    budget INTEGER CHECK (budget >= 0),
    status VARCHAR(10) DEFAULT 'geplant',
    FOREIGN KEY (abteilung_id) REFERENCES abteilung(id)
);

-- Aufgabe 2 (ALTER)
-- Die Tabelle mitarbeiter bekommt eine Spalte telefon (Text bis 20 Zeichen).
ALTER TABLE mitarbeiter
ADD COLUMN telefon VARCHAR(20);


-- ===================================================================== DML
-- Aufgabe 3 (INSERT)
-- Tragen Sie mit EINEM Befehl drei Projekte ein (Spaltenliste angeben, status weglassen):
--   1 'Neues Intranet'  -> IT,        Budget 20000
--   2 'Messeauftritt'   -> Marketing, Budget  8000
--   3 'Recruiting-Tag'  -> HR,        Budget  3000
-- Erwartet: SELECT * FROM projekt;  -> 3 Zeilen, status überall 'geplant'
INSERT INTO projekt (titel, abteilung_id, budget)
VALUES
('Neues Intranet', 1, 20000),
('Messeauftritt', 4, 8000),
('Recruiting-Tag', 2, 3000);



-- Aufgabe 4 (UPDATE)
-- Anna (id 1) bekommt die Telefonnummer '0351 1234-11'.
UPDATE mitarbeiter
SET telefon = '0351 1234-11'
WHERE id = 1;



-- Aufgabe 5 (UPDATE mit zwei Bedingungen)
-- Alle Vertriebsmitarbeiter am Standort Dresden bekommen 100 EUR mehr Gehalt.
-- Erwartet: 2 Zeilen geändert - Dirk 3200, Hakan 4000 (Felix in Leipzig bleibt 2900)


UPDATE mitarbeiter
SET gehalt = gehalt + 100
WHERE abteilung_id = 3 AND standort = 'Dresden';
-- Aufgabe 6 (DELETE)
-- Der Recruiting-Tag fällt aus. Löschen Sie das Projekt.
-- Erwartet: SELECT COUNT(*) FROM projekt;  -> 2
DELETE FROM projekt
WHERE projektname = 'Recruiting-Tag';


-- Aufgabe 7 (Constraint testen)
-- Versuchen Sie, ein Projekt 'Geisterprojekt' für die Abteilung 99 einzutragen.
-- Welche Fehlermeldung erscheint - und warum?
-- Erwartet: FOREIGN KEY constraint failed
-- Aufgabe 7
-- Erwartet: FOREIGN KEY constraint failed

INSERT INTO projekt (projektname, abteilung_id)
VALUES ('Geisterprojekt', 99);


-- ===================================================================== DQL
-- Aufgabe 8
-- Vorname, Nachname und Gehalt aller Mitarbeiter mit mehr als 3500 EUR,
-- höchstes Gehalt zuerst, bei Gleichstand alphabetisch nach Nachname.
-- Erwartet: Eva Adler 4200 · Anna Berger 4200 · Hakan Yilmaz 4000
SELECT vorname, nachname, gehalt
FROM mitarbeiter
WHERE gehalt > 3500
ORDER BY gehalt DESC, nachname ASC;


-- Aufgabe 9
-- An welchen Standorten arbeitet die Firma? Jeden Standort nur einmal, alphabetisch.
-- Erwartet: Dresden, Leipzig

SELECT DISTINCT standort
FROM mitarbeiter
ORDER BY standort ASC;




-- Aufgabe 10
-- Wer ist noch keiner Abteilung zugeordnet?
-- Erwartet: Ida Lang      (Tipp: = NULL funktioniert nicht!)
Mitarbeiter ohne Abteilung
SELECT vorname, nachname
FROM mitarbeiter
WHERE abteilung_id IS NULL;



-- ===================================================================== JOIN
-- Aufgabe 11 (INNER JOIN)
-- Vorname, Nachname und Abteilungsname aller Mitarbeiter, die eine Abteilung haben.
-- Sortiert nach Abteilungsname, dann Nachname. Verwenden Sie Aliase (m, a).
-- Erwartet: 8 Zeilen, beginnt mit Ben Hoffmann HR, Ida fehlt
SELECT m.vorname, m.nachname, a.name AS abteilungsname
FROM mitarbeiter m
INNER JOIN abteilung a ON m.abteilung_id = a.id
ORDER BY a.name, m.nachname;



-- Aufgabe 12 (LEFT JOIN)
-- Vorname und Abteilungsname ALLER Mitarbeiter, sortiert nach id.
-- Erwartet: 9 Zeilen, letzte Zeile: Ida | NULL
SELECT m.vorname, a.name AS abteilungsname
FROM mitarbeiter m
LEFT JOIN abteilung a ON m.abteilung_id = a.id
ORDER BY m.id;


-- Aufgabe 13 (RIGHT JOIN)
-- Schreiben Sie die Abfrage mit FROM mitarbeiter m RIGHT JOIN abteilung a ...
-- Gesucht: Abteilungsname und Vorname, ALLE Abteilungen sollen erscheinen.
-- Sortiert nach a.id, dann Vorname.
-- Erwartet: 9 Zeilen, letzte Zeile: Marketing | NULL
-- Zusatzfrage: Wie lautet dieselbe Abfrage als LEFT JOIN?
SELECT a.name AS abteilungsname, m.vorname
FROM mitarbeiter m
RIGHT JOIN abteilung a ON m.abteilung_id = a.id
ORDER BY a.id, m.vorname;



-- Aufgabe 14 (Partnerlose finden)
-- Welche Abteilung hat keine Mitarbeiter?   (LEFT JOIN + WHERE ... IS NULL)
-- Erwartet: Marketing
SELECT a.name AS abteilungsname, m.vorname
FROM abteilung a
LEFT JOIN mitarbeiter m ON a.id = m.abteilung_id
ORDER BY a.id, m.vorname;



-- Aufgabe 15 (JOIN mit der neuen Tabelle)
-- Titel, Abteilungsname und Budget aller Projekte, alphabetisch nach Titel.
-- Erwartet: Messeauftritt | Marketing | 8000 · Neues Intranet | IT | 20000
SELECT p.titel, a.name AS abteilungsname, p.budget
FROM projekt p
INNER JOIN abteilung a ON p.abteilung_id = a.id
ORDER BY p.titel;


-- Aufgabe 16 (drei Tabellen)
-- Wer arbeitet in der Abteilung, die das Projekt 'Neues Intranet' betreut?
-- Verbinden Sie projekt -> abteilung -> mitarbeiter. Vorname und Nachname, nach Vorname.
-- Erwartet: Anna Berger · Clara Winter · Eva Adler
SELECT m.vorname, m.nachname
FROM projekt p
INNER JOIN abteilung a ON p.abteilung_id = a.id
INNER JOIN mitarbeiter m ON m.abteilung_id = a.id
WHERE p.titel = 'Neues Intranet'
ORDER BY m.vorname;

-- Aufgabe 17
-- Welche Abteilungen haben (noch) kein Projekt? Alphabetisch.
-- Erwartet: HR, Vertrieb
SELECT a.name AS abteilungsname
FROM abteilung a
LEFT JOIN projekt p ON a.id = p.abteilung_id
WHERE p.id IS NULL
ORDER BY a.name;


-- ===================================================================== TCL
-- Aufgabe 18 (COMMIT)
-- Buchen Sie in EINER Transaktion 5000 EUR Budget vom 'Neuen Intranet' zum 'Messeauftritt' um
-- und schreiben Sie die Änderung fest.
-- Erwartet: Neues Intranet 15000 · Messeauftritt 13000
BEGIN TRANSACTION;

UPDATE projekt
SET budget = budget - 5000
WHERE titel = 'Neues Intranet';

UPDATE projekt
SET budget = budget + 5000
WHERE titel = 'Messeauftritt';

COMMIT;



-- Aufgabe 19 (ROLLBACK)
-- Öffnen Sie eine Transaktion, löschen Sie ALLE Projekte, zählen Sie nach,
-- und nehmen Sie das Löschen zurück. Zählen Sie erneut.
-- Erwartet: erst 0, nach dem ROLLBACK wieder 2
BEGIN TRANSACTION;

DELETE FROM projekt;

SELECT COUNT(*) FROM projekt;

ROLLBACK;

SELECT COUNT(*) FROM projekt;



-- Aufgabe 20 (SAVEPOINT)
-- In einer Transaktion: Projekt 1 auf status 'aktiv' setzen, dann einen SAVEPOINT vor_messe,
-- dann Projekt 2 auf 'aktiv'. Nehmen Sie nur die zweite Änderung zurück und schreiben Sie fest.
-- Erwartet: Neues Intranet aktiv · Messeauftritt geplant
BEGIN TRANSACTION;

UPDATE projekt
SET status = 'aktiv'
WHERE id = 1;

SAVEPOINT zwischenstand;

UPDATE projekt
SET status = 'aktiv'
WHERE id = 2;

ROLLBACK TO SAVEPOINT zwischenstand;

COMMIT;


-- Aufgabe 21 (ganz oder gar nicht)
-- In einer Transaktion: Messeauftritt +20000, dann Neues Intranet -20000.
-- Was passiert beim zweiten Befehl? Beenden Sie die Transaktion so, dass KEINE der beiden
-- Änderungen gilt.
-- Erwartet: CHECK constraint failed, danach unverändert 15000 / 13000
BEGIN TRANSACTION;

UPDATE projekt
SET budget = budget + 20000
WHERE titel = 'Messeauftritt';

UPDATE projekt
SET budget = budget - 20000
WHERE titel = 'Neues Intranet';

ROLLBACK;