DROP TABLE Ucast_udalosti CASCADE CONSTRAINTS PURGE;
DROP TABLE Udalost CASCADE CONSTRAINTS PURGE;
DROP TABLE Zamestnanec CASCADE CONSTRAINTS PURGE;
DROP TABLE Oddeleni CASCADE CONSTRAINTS PURGE;

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

-- trigger č.1 - auto increment id zaměstnance
DROP SEQUENCE c_zamestanance_SEQ;
CREATE SEQUENCE c_zamestanance_SEQ START WITH 1 INCREMENT BY 1;
CREATE OR REPLACE TRIGGER auto_c_zamestnance
    BEFORE INSERT ON Zamestnanec
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

-- Oddeleni
INSERT INTO Oddeleni (kod_oddeleni, nazev_oddeleni)
VALUES ('FIN', 'Finanční oddělení');

INSERT INTO Oddeleni (kod_oddeleni, nazev_oddeleni)
VALUES ('HR', 'Oddělení lidských zdrojů');

INSERT INTO Oddeleni (kod_oddeleni, nazev_oddeleni)
VALUES ('MRK', 'Marketingové oddělení');

INSERT INTO Oddeleni (kod_oddeleni, nazev_oddeleni)
VALUES ('NZO', 'Nově zakládané oddělení');

-- Uzivatele
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

-- Udalosti
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

-- Ucastnici udalosti
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

-- ================= pokročilé objekty schématu databáze ===========================

-- !! PŘED ODEVZDÁNÍM ODKOMENTOVAT !! - na demu říkal ať to do skriptu dáme, ale v datagripu to nefunguje
-- SET serveroutput ON;

-- triggery: - 1. umístěn za příkazem vytvoření tabulky uživatele
--          - 2. a 3. umístěny na konci souboru (pro jejich testování jsou použity neidempotentní operace)

-- procedura č.1
-- Kolik událostí v průměru vytvořil zaměstnanec daného oddělení (včetně samotného manažera)
CREATE OR REPLACE PROCEDURE pocet_udalosti_na_zamestnance (kod_oddeleni VARCHAR)
AS
    c_manazera              Zamestnanec.c_zamestnance%TYPE;
    p_udalosti              INT;
    p_zamestnancu           INT;
    pocet_na_zamestnance    FLOAT;
BEGIN
    SELECT c_zamestnance
    INTO c_manazera
    FROM Zamestnanec
    WHERE role = 'MAN' AND kod_oddeleni_zamestnance = kod_oddeleni;

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

    EXCEPTION WHEN NO_DATA_FOUND THEN
    BEGIN
    DBMS_OUTPUT.put_line('Kód oddělení: ' || kod_oddeleni || CHR(10) ||
                         'Oddělení nemá manažera, tedy ani žádné události.');
    END;
END;
-- test procedury č.1
BEGIN
    pocet_udalosti_na_zamestnance('FIN');
    pocet_udalosti_na_zamestnance('NZO'); -- vyvolá výjimku
END;

-- procedura č.2
-- Detaily zadané události včetně zůčastněných zaměstanců a jejich počtu
CREATE OR REPLACE PROCEDURE detaily_udalosti (id_udalosti_p INT) AS
    detail_udalosti     Udalost%ROWTYPE;
    ucastnik            Zamestnanec%ROWTYPE;
    id_ucastnika        Zamestnanec.c_zamestnance%TYPE;
    pocet_ucastniku     INT := 0;
    nazev_odd_p         VARCHAR(255);
    output              VARCHAR(1000);

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
              'Od: ' || TO_CHAR(detail_udalosti.datum_cas_od,'DD.MM.YYYY HH24:MI') || CHR(10) ||
              'Do: ' || TO_CHAR(detail_udalosti.datum_cas_do, 'DD.MM.YYYY HH24:MI') || CHR(10) ||
              'Místo konání: ' || detail_udalosti.misto_konani || CHR(10) ||
              'Popis: ' || detail_udalosti.popis || CHR(10);

    OPEN ucastnik_cur(id_udalosti_p);
	LOOP
		FETCH ucastnik_cur INTO id_ucastnika;
    	EXIT WHEN ucastnik_cur%NOTFOUND;

		pocet_ucastniku := pocet_ucastniku + 1;
		IF pocet_ucastniku = 1 THEN
            output :=  output || 'Účastní se:' || CHR(10);
		END IF;

		SELECT *
		INTO ucastnik
		FROM ZAMESTNANEC
		WHERE c_zamestnance = id_ucastnika;

		IF ucastnik.role = 'RED' THEN
            output := output || '- ' || ucastnik.jmeno ||' '|| ucastnik.prijmeni || ', ředitel' || CHR(10);
		ELSE
            SELECT nazev_oddeleni
            INTO nazev_odd_p
            FROM Oddeleni
            WHERE ucastnik.kod_oddeleni_zamestnance = Oddeleni.kod_oddeleni;

            output := output || '- ' || ucastnik.jmeno ||' '|| ucastnik.prijmeni || ', ' || nazev_odd_p || ' - manažer' || CHR(10);
        END IF;
	END LOOP;
	CLOSE ucastnik_cur;
	output := output || 'Celkem účastníků: ' || pocet_ucastniku;
	DBMS_OUTPUT.PUT_LINE(output);

	EXCEPTION WHEN NO_DATA_FOUND THEN
    BEGIN
        DBMS_OUTPUT.put_line('CHYBA: Údálost s daným identifikátorem neexistuje.');
    END;
END;
-- test procedury č.2
BEGIN
    detaily_udalosti(2);
    detaily_udalosti(6); -- vyvolá výjimku
END;


-- EXPLAIN PLAIN + index (optimalizace)
--TODO

-- definice přístupových práv
GRANT ALL ON Oddeleni       TO XMAHDA14;
GRANT ALL ON Ucast_udalosti TO XMAHDA14;
GRANT ALL ON Zamestnanec    TO XMAHDA14;
GRANT ALL ON Udalost        TO XMAHDA14;

GRANT EXECUTE ON pocet_udalosti_na_zamestnance  TO XMAHDA14;
GRANT EXECUTE ON detaily_udalosti               TO XMAHDA14;

-- materializovaný pohled
-- TODO

-- trigger č.2
-- on delete cascade - při smazíní uživatele se smažou i jeho účasti na událostech
CREATE OR REPLACE TRIGGER udalosti_zamestnance_cascade_delete
BEFORE DELETE ON Zamestnanec
FOR EACH ROW
BEGIN
    DELETE FROM Ucast_udalosti
    WHERE :OLD.c_zamestnance = Ucast_udalosti.c_zamestnance;
END;
-- test funkčnosti triggeru č.2
SELECT * FROM Ucast_udalosti WHERE c_zamestnance = 2;
DELETE FROM Zamestnanec where c_zamestnance = 2;
SELECT * FROM Ucast_udalosti WHERE c_zamestnance = 2;

-- trigger č.3
-- on update cascade - při změně kódu oddělení se změní i kód oddělení zaměstnanců
CREATE OR REPLACE TRIGGER kod_oddeleni_cascade_update
AFTER UPDATE OF kod_oddeleni ON Oddeleni
FOR EACH ROW
BEGIN
    UPDATE Zamestnanec SET kod_oddeleni_zamestnance = :NEW.kod_oddeleni
    WHERE kod_oddeleni_zamestnance = :OLD.kod_oddeleni;
END;
-- test funkčnosti triggeru č.3
SELECT * FROM Zamestnanec WHERE kod_oddeleni_zamestnance = 'HR';
UPDATE Oddeleni SET kod_oddeleni='LZ' WHERE kod_oddeleni = 'HR';
SELECT * FROM Zamestnanec WHERE kod_oddeleni_zamestnance = 'LZ';
