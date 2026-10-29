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



-- Aufgabe 7 (Constraint testen)
-- Versuchen Sie, ein Projekt 'Geisterprojekt' für die Abteilung 99 einzutragen.
-- Welche Fehlermeldung erscheint - und warum?
-- Erwartet: FOREIGN KEY constraint failed



-- ===================================================================== DQL
-- Aufgabe 8
-- Vorname, Nachname und Gehalt aller Mitarbeiter mit mehr als 3500 EUR,
-- höchstes Gehalt zuerst, bei Gleichstand alphabetisch nach Nachname.
-- Erwartet: Eva Adler 4200 · Anna Berger 4200 · Hakan Yilmaz 4000



-- Aufgabe 9
-- An welchen Standorten arbeitet die Firma? Jeden Standort nur einmal, alphabetisch.
-- Erwartet: Dresden, Leipzig



-- Aufgabe 10
-- Wer ist noch keiner Abteilung zugeordnet?
-- Erwartet: Ida Lang      (Tipp: = NULL funktioniert nicht!)



-- ===================================================================== JOIN
-- Aufgabe 11 (INNER JOIN)
-- Vorname, Nachname und Abteilungsname aller Mitarbeiter, die eine Abteilung haben.
-- Sortiert nach Abteilungsname, dann Nachname. Verwenden Sie Aliase (m, a).
-- Erwartet: 8 Zeilen, beginnt mit Ben Hoffmann HR, Ida fehlt



-- Aufgabe 12 (LEFT JOIN)
-- Vorname und Abteilungsname ALLER Mitarbeiter, sortiert nach id.
-- Erwartet: 9 Zeilen, letzte Zeile: Ida | NULL



-- Aufgabe 13 (RIGHT JOIN)
-- Schreiben Sie die Abfrage mit FROM mitarbeiter m RIGHT JOIN abteilung a ...
-- Gesucht: Abteilungsname und Vorname, ALLE Abteilungen sollen erscheinen.
-- Sortiert nach a.id, dann Vorname.
-- Erwartet: 9 Zeilen, letzte Zeile: Marketing | NULL
-- Zusatzfrage: Wie lautet dieselbe Abfrage als LEFT JOIN?



-- Aufgabe 14 (Partnerlose finden)
-- Welche Abteilung hat keine Mitarbeiter?   (LEFT JOIN + WHERE ... IS NULL)
-- Erwartet: Marketing



-- Aufgabe 15 (JOIN mit der neuen Tabelle)
-- Titel, Abteilungsname und Budget aller Projekte, alphabetisch nach Titel.
-- Erwartet: Messeauftritt | Marketing | 8000 · Neues Intranet | IT | 20000



-- Aufgabe 16 (drei Tabellen)
-- Wer arbeitet in der Abteilung, die das Projekt 'Neues Intranet' betreut?
-- Verbinden Sie projekt -> abteilung -> mitarbeiter. Vorname und Nachname, nach Vorname.
-- Erwartet: Anna Berger · Clara Winter · Eva Adler



-- Aufgabe 17
-- Welche Abteilungen haben (noch) kein Projekt? Alphabetisch.
-- Erwartet: HR, Vertrieb



-- ===================================================================== TCL
-- Aufgabe 18 (COMMIT)
-- Buchen Sie in EINER Transaktion 5000 EUR Budget vom 'Neuen Intranet' zum 'Messeauftritt' um
-- und schreiben Sie die Änderung fest.
-- Erwartet: Neues Intranet 15000 · Messeauftritt 13000



-- Aufgabe 19 (ROLLBACK)
-- Öffnen Sie eine Transaktion, löschen Sie ALLE Projekte, zählen Sie nach,
-- und nehmen Sie das Löschen zurück. Zählen Sie erneut.
-- Erwartet: erst 0, nach dem ROLLBACK wieder 2



-- Aufgabe 20 (SAVEPOINT)
-- In einer Transaktion: Projekt 1 auf status 'aktiv' setzen, dann einen SAVEPOINT vor_messe,
-- dann Projekt 2 auf 'aktiv'. Nehmen Sie nur die zweite Änderung zurück und schreiben Sie fest.
-- Erwartet: Neues Intranet aktiv · Messeauftritt geplant



-- Aufgabe 21 (ganz oder gar nicht)
-- In einer Transaktion: Messeauftritt +20000, dann Neues Intranet -20000.
-- Was passiert beim zweiten Befehl? Beenden Sie die Transaktion so, dass KEINE der beiden
-- Änderungen gilt.
-- Erwartet: CHECK constraint failed, danach unverändert 15000 / 13000
