-- IDS Projekt 2021/2022
-- Autoři: Vilém Gottwald (xgottw07), Ondřej Mahdalík (xmahda14)
-- Datum: 1. 5. 2022

-- SET serveroutput ON; -- odkomentovat v případě používání SQL Developeru

DROP TABLE Ucast_udalosti CASCADE CONSTRAINTS PURGE;
DROP TABLE Udalost CASCADE CONSTRAINTS PURGE;
DROP TABLE Zamestnanec CASCADE CONSTRAINTS PURGE;
DROP TABLE Oddeleni CASCADE CONSTRAINTS PURGE;
DROP MATERIALIZED VIEW Udalosti_manazera_FIN;
DROP MATERIALIZED VIEW Aktivita_duben;

---------------------- Vytvoření tabulek ------------------------------
CREATE TABLE Oddeleni
(
    kod_oddeleni   VARCHAR(10) PRIMARY KEY,
    nazev_oddeleni VARCHAR(255) NOT NULL
);

CREATE TABLE Zamestnanec
(
    c_zamestnance            INT DEFAULT NULL,
    rodne_c                  CHAR(10)    NOT NULL,
    jmeno                    VARCHAR(80) NOT NULL,
    prijmeni                 VARCHAR(80) NOT NULL,
    role                     CHAR(3)     NOT NULL,
    id_nadrizeny_reditel     INT,
    kod_oddeleni_zamestnance VARCHAR(10),

    CONSTRAINT PK_zamestnanec
        PRIMARY KEY (c_zamestnance),
    CONSTRAINT FK_nadrizeny_reditel
        FOREIGN KEY (id_nadrizeny_reditel) REFERENCES Zamestnanec (c_zamestnance),
    CONSTRAINT FK_oddeleni
        FOREIGN KEY (kod_oddeleni_zamestnance) REFERENCES Oddeleni (kod_oddeleni),
    CONSTRAINT CHK_format_rc
        CHECK ( (REGEXP_LIKE(rodne_c, '^[0-9]{10}$') AND MOD(rodne_c, 11) = 0) OR
                REGEXP_LIKE(rodne_c, '^[0-9]{6}[1-9]{3}$')),
    CONSTRAINT CHK_role_zamestnance
        CHECK ( (role = 'RED' AND id_nadrizeny_reditel IS NULL AND kod_oddeleni_zamestnance IS NULL) OR
                (role = 'MAN' AND id_nadrizeny_reditel IS NULL AND kod_oddeleni_zamestnance IS NOT NULL) OR
                (role = 'SEK' AND id_nadrizeny_reditel IS NULL AND kod_oddeleni_zamestnance IS NOT NULL) OR
                (role = 'SEK' AND id_nadrizeny_reditel IS NOT NULL AND kod_oddeleni_zamestnance IS NULL))
);

---- Trigger č.1 - auto increment id zaměstnance
DROP SEQUENCE c_zamestanance_SEQ;
CREATE SEQUENCE c_zamestanance_SEQ START WITH 1 INCREMENT BY 1;
CREATE OR REPLACE TRIGGER auto_c_zamestnance
    BEFORE INSERT
    ON Zamestnanec
    FOR EACH ROW
BEGIN
    IF :NEW.c_zamestnance IS NULL THEN
        :NEW.c_zamestnance := c_zamestanance_SEQ.NEXTVAL;
    END IF;
END;

CREATE TABLE Udalost
(
    id_udalosti  INT GENERATED BY DEFAULT ON NULL AS IDENTITY,
    datum_cas_od DATE         NOT NULL,
    datum_cas_do DATE         NOT NULL,
    nazev        VARCHAR(255) NOT NULL,
    misto_konani VARCHAR(255) NOT NULL,
    popis        VARCHAR(500),
    id_autor     INT          NOT NULL,
    CONSTRAINT PK_id_udalosti
        PRIMARY KEY (id_udalosti),
    CONSTRAINT FK_autor
        FOREIGN KEY (id_autor) REFERENCES Zamestnanec (c_zamestnance),
    CONSTRAINT CHK_date
        CHECK (datum_cas_od < datum_cas_do)
);

CREATE TABLE Ucast_udalosti
(
    c_zamestnance INT NOT NULL,
    id_udalosti   INT NOT NULL,
    CONSTRAINT PK_ucast_udalosti
        PRIMARY KEY (c_zamestnance, id_udalosti),
    CONSTRAINT FK_zamestnanec
        FOREIGN KEY (c_zamestnance) REFERENCES Zamestnanec (c_zamestnance),
    CONSTRAINT FK_udalost
        FOREIGN KEY (id_udalosti) REFERENCES Udalost (id_udalosti)
);

----------------------- Naplnění tabulek ukázkovými daty ------------------
-- Odddělení
INSERT INTO Oddeleni (kod_oddeleni, nazev_oddeleni)
VALUES ('FIN', 'Finanční oddělení');

INSERT INTO Oddeleni (kod_oddeleni, nazev_oddeleni)
VALUES ('HR', 'Oddělení lidských zdrojů');

INSERT INTO Oddeleni (kod_oddeleni, nazev_oddeleni)
VALUES ('MRK', 'Marketingové oddělení');

INSERT INTO Oddeleni (kod_oddeleni, nazev_oddeleni)
VALUES ('NZO', 'Nově zakládané oddělení');

-- Zaměstnanci
INSERT INTO Zamestnanec (rodne_c, jmeno, prijmeni, role)
VALUES (7902173675, 'Jan', 'Pajtl', 'RED');

INSERT INTO Zamestnanec (rodne_c, jmeno, prijmeni, role, kod_oddeleni_zamestnance)
VALUES (8406087415, 'Petr', 'Kubala', 'MAN', 'FIN');

INSERT INTO Zamestnanec (rodne_c, jmeno, prijmeni, role, kod_oddeleni_zamestnance)
VALUES (8959156349, 'Tereza', 'Doubravová', 'MAN', 'HR');

INSERT INTO Zamestnanec (rodne_c, jmeno, prijmeni, role, kod_oddeleni_zamestnance)
VALUES (7656217701, 'Soňa', 'Peštová', 'SEK', 'FIN');

INSERT INTO Zamestnanec (rodne_c, jmeno, prijmeni, role, id_nadrizeny_reditel)
VALUES (9258087894, 'Eva', 'Modrá', 'SEK', 1);

INSERT INTO Zamestnanec (rodne_c, jmeno, prijmeni, role, kod_oddeleni_zamestnance)
VALUES (6553157160, 'Anna', 'Zoufalá', 'SEK', 'FIN');

INSERT INTO Zamestnanec (rodne_c, jmeno, prijmeni, role, kod_oddeleni_zamestnance)
VALUES (7008116137, 'Tomáš', 'Prativa', 'MAN', 'MRK');

-- Události
INSERT INTO Udalost (datum_cas_od, datum_cas_do, nazev, misto_konani, popis, id_autor)
VALUES (TO_DATE('5.4.2022 10:00', 'DD.MM.YYYY HH24:MI'), TO_DATE('5.4.2022 12:00', 'DD.MM.YYYY HH24:MI'),
        'Schůzka s obchodními partnery', 'Vstupní hala',
        'Každoroční setkání s obchodními partnery ze zahraniční pobočky. Dresscode: business formal', 3);

INSERT INTO Udalost (datum_cas_od, datum_cas_do, nazev, misto_konani, popis, id_autor)
VALUES (TO_DATE('22.4.2022 14:00', 'DD.MM.YYYY HH24:MI'), TO_DATE('22.4.2022 18:00', 'DD.MM.YYYY HH24:MI'),
        'Návštěva dodavatelů', 'Areál firmy', 'Provedení firmou, jednání v konferenčce, poté raut ve vstupní hale.', 5);

INSERT INTO Udalost (datum_cas_od, datum_cas_do, nazev, misto_konani, id_autor)
VALUES (TO_DATE('3.4.2022 12:00', 'DD.MM.YYYY HH24:MI'), TO_DATE('3.4.2022 16:00', 'DD.MM.YYYY HH24:MI'),
        'Porada ohledně marketingu', 'Konferenční sál', 4);

INSERT INTO Udalost (datum_cas_od, datum_cas_do, nazev, misto_konani, id_autor)
VALUES (TO_DATE('12.4.2022 9:00', 'DD.MM.YYYY HH24:MI'), TO_DATE('28.4.2022 9:30', 'DD.MM.YYYY HH24:MI'),
        'Schůze vedení', 'Konferenční sál', 1);

-- Účasti na událostech
INSERT INTO Ucast_udalosti (c_zamestnance, id_udalosti)
VALUES (3, 1);

INSERT INTO Ucast_udalosti (c_zamestnance, id_udalosti)
VALUES (2, 2);

INSERT INTO Ucast_udalosti (c_zamestnance, id_udalosti)
VALUES (1, 3);

INSERT INTO Ucast_udalosti (c_zamestnance, id_udalosti)
VALUES (2, 3);

INSERT INTO Ucast_udalosti (c_zamestnance, id_udalosti)
VALUES (1, 4);

INSERT INTO Ucast_udalosti (c_zamestnance, id_udalosti)
VALUES (2, 4);

INSERT INTO Ucast_udalosti (c_zamestnance, id_udalosti)
VALUES (3, 4);

----------- Vytvoření pokročilých objektů schématu databáze ---------------------------

---- Triggery: - 1. umístěn za příkazem vytvoření tabulky uživatele
--          - 2. a 3. umístěny na konci souboru (pro jejich demonstraci jsou použity neidempotentní operace)

---- Procedura č.1 ----
-- Kolik událostí v průměru vytvořil zaměstnanec daného oddělení (včetně samotného manažera)
CREATE OR REPLACE PROCEDURE pocet_udalosti_na_zamestnance(kod_oddeleni VARCHAR)
AS
    c_manazera           Zamestnanec.c_zamestnance%TYPE;
    p_udalosti           INT;
    p_zamestnancu        INT;
    pocet_na_zamestnance FLOAT;
BEGIN
    SELECT c_zamestnance
    INTO c_manazera
    FROM Zamestnanec
    WHERE role = 'MAN'
      AND kod_oddeleni_zamestnance = kod_oddeleni;

    SELECT COUNT(*)
    INTO p_zamestnancu
    FROM Zamestnanec
    WHERE kod_oddeleni_zamestnance = kod_oddeleni;

    SELECT COUNT(*)
    INTO p_udalosti
    FROM Ucast_udalosti
    WHERE c_zamestnance = c_manazera;

    pocet_na_zamestnance := p_udalosti / p_zamestnancu;
    DBMS_OUTPUT.PUT_LINE('Kód oddělení: ' || kod_oddeleni || CHR(10) ||
                         'Počet událostí na zaměstnance: ' || pocet_na_zamestnance);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        BEGIN
            DBMS_OUTPUT.put_line('Kód oddělení: ' || kod_oddeleni || CHR(10) ||
                                 'Oddělení nemá manažera, tedy ani žádné události.');
        END;
END;
-- Demonstrace procedury č.1
BEGIN
    pocet_udalosti_na_zamestnance('FIN');
    pocet_udalosti_na_zamestnance('NZO'); -- vyvolání výjimky
END;

---- Procedura č.2 ----
-- Detaily zadané události včetně zůčastněných zaměstanců a jejich počtu
CREATE OR REPLACE PROCEDURE detaily_udalosti(id_udalosti_p INT) AS
    detail_udalosti udalost%ROWTYPE;
    ucastnik        zamestnanec%ROWTYPE;
    id_ucastnika    Zamestnanec.c_zamestnance%TYPE;
    pocet_ucastniku INT := 0;
    nazev_odd_p     VARCHAR(255);
    output          VARCHAR(1000);
    CURSOR ucastnik_cur (id_udalosti_cur INT) IS
        SELECT c_zamestnance
        FROM Ucast_udalosti
        WHERE id_udalosti = id_udalosti_cur;
BEGIN
    SELECT *
    INTO detail_udalosti
    FROM Udalost
    WHERE Udalost.id_udalosti = id_udalosti_p;
    output := 'Název: ' || detail_udalosti.nazev || CHR(10) ||
              'Od: ' || TO_CHAR(detail_udalosti.datum_cas_od, 'DD.MM.YYYY HH24:MI') || CHR(10) ||
              'Do: ' || TO_CHAR(detail_udalosti.datum_cas_do, 'DD.MM.YYYY HH24:MI') || CHR(10) ||
              'Místo konání: ' || detail_udalosti.misto_konani || CHR(10) ||
              'Popis: ' || detail_udalosti.popis || CHR(10);

    OPEN ucastnik_cur(id_udalosti_p);
    LOOP
        FETCH ucastnik_cur INTO id_ucastnika;
        EXIT WHEN ucastnik_cur%NOTFOUND;

        pocet_ucastniku := pocet_ucastniku + 1;
        IF pocet_ucastniku = 1 THEN
            output := output || 'Účastní se:' || CHR(10);
        END IF;

        SELECT *
        INTO ucastnik
        FROM ZAMESTNANEC
        WHERE c_zamestnance = id_ucastnika;

        IF ucastnik.role = 'RED' THEN
            output := output || '- ' || ucastnik.jmeno || ' ' || ucastnik.prijmeni || ', ředitel' || CHR(10);
        ELSE
            SELECT nazev_oddeleni
            INTO nazev_odd_p
            FROM Oddeleni
            WHERE ucastnik.kod_oddeleni_zamestnance = Oddeleni.kod_oddeleni;

            output := output || '- ' || ucastnik.jmeno || ' ' || ucastnik.prijmeni || ', ' || nazev_odd_p ||
                      ' - manažer' || CHR(10);
        END IF;
    END LOOP;
    CLOSE ucastnik_cur;
    output := output || 'Celkem účastníků: ' || pocet_ucastniku;
    DBMS_OUTPUT.PUT_LINE(output);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        BEGIN
            DBMS_OUTPUT.put_line('CHYBA: Událost s daným identifikátorem neexistuje.');
        END;
END;
-- Demonstrace procedury č.2
BEGIN
    detaily_udalosti(4);
    detaily_udalosti(6); -- vyvolání výjimky
END;

-- EXPLAIN PLAN + index (optimalizace)
-- Kolika událostí se v dubnu 2022 účastní jednotliví členové vedení?
EXPLAIN PLAN FOR
SELECT O.nazev_oddeleni, COUNT(Z.c_zamestnance) AS pocet_zamestanancu
FROM Oddeleni O LEFT JOIN Zamestnanec Z ON Z.kod_oddeleni_zamestnance = O.kod_oddeleni
GROUP BY O.kod_oddeleni, O.nazev_oddeleni;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- Pridani indexu pro optimalizaci
CREATE INDEX oddeleni_k_n ON Oddeleni(kod_oddeleni, nazev_oddeleni);

-- Zopakování EXPLAIN PLAN
EXPLAIN PLAN FOR
SELECT O.nazev_oddeleni, COUNT(Z.c_zamestnance) AS pocet_zamestanancu
FROM Oddeleni O LEFT JOIN Zamestnanec Z ON Z.kod_oddeleni_zamestnance = O.kod_oddeleni
GROUP BY O.kod_oddeleni, O.nazev_oddeleni;


SELECT * FROM TABLE (DBMS_XPLAN.DISPLAY);

---- Definice přístupových práv pro druhého člena týmu ----
GRANT ALL ON Oddeleni TO XMAHDA14;
GRANT ALL ON Ucast_udalosti TO XMAHDA14;
GRANT ALL ON Zamestnanec TO XMAHDA14;
GRANT ALL ON Udalost TO XMAHDA14;

GRANT EXECUTE ON pocet_udalosti_na_zamestnance TO XMAHDA14;
GRANT EXECUTE ON detaily_udalosti TO XMAHDA14;

---- Materializovaný pohled vytvořený druhým členem týmu ----
--!! Následující část spouští XMAHDA14 !!--
-- Zobrazuje události manažera finančního oddělení
CREATE MATERIALIZED VIEW Udalosti_manazera_FIN AS
SELECT * FROM XGOTTW07.Udalost U
WHERE U.id_autor IN (SELECT Z.c_zamestnance
                     FROM XGOTTW07.Zamestnanec Z
                     WHERE Z.kod_oddeleni_zamestnance = 'FIN');
-- Demonstrace materializovaného pohledu Udalosti_manazera_FIN
SELECT *
FROM Udalosti_manazera_FIN;

-- Přidání nové položky do tabulky Udalost
INSERT INTO XGOTTW07.Udalost (datum_cas_od, datum_cas_do, nazev, misto_konani, id_autor)
VALUES (TO_DATE('29.4.2022 15:00', 'DD.MM.YYYY HH24:MI'), TO_DATE('29.4.2022 22:00', 'DD.MM.YYYY HH24:MI'),
        'Teambuilding', 'Externi prostory', 4);

-- Upráva položky v tabluce Udalost
UPDATE XGOTTW07.Udalost
SET datum_cas_od = TO_DATE('29.4.2022 15:00', 'DD.MM.YYYY HH24:MI'),
    datum_cas_do = TO_DATE('29.4.2022 22:00', 'DD.MM.YYYY HH24:MI')
WHERE id_udalosti = 3;

-- Opětovný výpis položek (provedené změny se v materializovaném pohledu neprojeví)
SELECT *
FROM Udalosti_manazera_FIN;
-- Výpis položek z databáze - změny provedeny byly
SELECT *
FROM XGOTTW07.Udalost U
WHERE U.id_autor IN (SELECT Z.c_zamestnance
                     FROM XGOTTW07.Zamestnanec Z
                     WHERE Z.kod_oddeleni_zamestnance = 'FIN');

-- Druhý materializovaný pohled
-- Zobrazuje, kolika událostí se v dubnu 2022 účastní jednotliví členové vedení?
CREATE MATERIALIZED VIEW Aktivita_duben AS
WITH Pocty_udalosti AS
    (
        SELECT Z.c_zamestnance, COUNT(U.ID_AUTOR) pocet_udalosti
        FROM Zamestnanec Z JOIN Ucast_udalosti UU ON Z.c_zamestnance = UU.c_zamestnance
           JOIN UDALOST U ON UU.id_udalosti = U.id_udalosti
        WHERE U.datum_cas_do BETWEEN TO_DATE('1.4.2022 00:00', 'DD.MM.YYYY HH24:MI') AND TO_DATE('30.4.2022 23:59', 'DD.MM.YYYY HH24:MI')
        GROUP BY Z.c_zamestnance
    )
SELECT Z.jmeno, Z.prijmeni, Z.role, O.nazev_oddeleni,  COALESCE(PU.pocet_udalosti, 0) pocet_udalosti
FROM Zamestnanec Z LEFT JOIN Pocty_udalosti PU ON Z.c_zamestnance = PU.c_zamestnance LEFT JOIN Oddeleni O ON Z.kod_oddeleni_zamestnance = O.kod_oddeleni
WHERE Z.role in ('MAN', 'RED');

-- Demonstrace materializovaného pohledu Aktivita_duben
SELECT *
FROM Aktivita_duben;

-- Pokus o úpravu dat v materializovaném pohledu
UPDATE  Aktivita_duben SET pocet_udalosti = 10 WHERE jmeno = 'Tereza' AND prijmeni = 'Doubravová'; -- vyhodí výjimku, protože materializovaný view nelze upravovat.

--!! Konec části spouštěné XMAHDA14 !!--

---- Pohled zobrazující nepřítomnost ředitele firmy (pouze pro čtení)
CREATE OR REPLACE VIEW Nepritomnost_reditele AS
SELECT U.datum_cas_od, U.datum_cas_do
FROM Udalost U
WHERE U.id_autor IN (SELECT Z.c_zamestnance
                     FROM Zamestnanec Z
                     WHERE Z.role = 'RED'
                        OR Z.id_nadrizeny_reditel = 1)
WITH READ ONLY;
-- Demonstrace pohledu Nepritomnost_reditele
SELECT *
FROM Reditelova_nepritomnost;

---- Trigger č.2 ----
-- On delete cascade - při smazání uživatele se smažou i jeho účasti na událostech
CREATE OR REPLACE TRIGGER udalosti_zamestnance_cascade_delete
    BEFORE DELETE
    ON Zamestnanec
    FOR EACH ROW
BEGIN
    DELETE
    FROM Ucast_udalosti
    WHERE :OLD.c_zamestnance = Ucast_udalosti.c_zamestnance;
END;
-- Demonstrace triggeru č.2
SELECT *
FROM Ucast_udalosti
WHERE c_zamestnance = 2;

DELETE
FROM Zamestnanec
WHERE c_zamestnance = 2;

SELECT *
FROM Ucast_udalosti
WHERE c_zamestnance = 2;

---- Trigger č.3 ----
-- On update cascade - při změně kódu oddělení se změní i kód oddělení u zaměstnanců
CREATE OR REPLACE TRIGGER kod_oddeleni_cascade_update
    AFTER UPDATE OF kod_oddeleni
    ON Oddeleni
    FOR EACH ROW
BEGIN
    UPDATE Zamestnanec
    SET kod_oddeleni_zamestnance = :NEW.kod_oddeleni
    WHERE kod_oddeleni_zamestnance = :OLD.kod_oddeleni;
END;
-- Demonstrace triggeru č.3
SELECT *
FROM Zamestnanec
WHERE kod_oddeleni_zamestnance = 'HR';

UPDATE Oddeleni
SET kod_oddeleni='LZ'
WHERE kod_oddeleni = 'HR';

SELECT *
FROM Zamestnanec
WHERE kod_oddeleni_zamestnance = 'LZ';
