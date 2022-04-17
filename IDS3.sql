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
    c_zamestnance            INT GENERATED BY DEFAULT ON NULL AS IDENTITY,
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
-- Entity s auto-increment PK
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

-- spojení dvou tabulek č.1
-- Kteří zaměstnanci jsou ve vedení firmy (včetně jejich oddělení)?
SELECT Z.jmeno, Z.prijmeni, Z.rodne_c, Z.role, O.nazev_oddeleni
FROM Zamestnanec Z LEFT JOIN ODDELENI O ON Z.kod_oddeleni_zamestnance = O.kod_oddeleni
WHERE  Z.role = 'RED' OR Z.role = 'MAN';

-- spojení dvou tabulek č.2
-- Jaké zaměstnance má finanční oddělení?
SELECT Z.rodne_c, Z.jmeno, Z.prijmeni, Z.role
FROM Zamestnanec Z JOIN ODDELENI O ON Z.kod_oddeleni_zamestnance = O.kod_oddeleni
WHERE O.nazev_oddeleni = 'Finanční oddělení';

-- spojení tří tabulek
-- Jakých událostí se účastní Petr Kubala?
SELECT U.nazev, U.datum_cas_od, U.datum_cas_do, U.popis, U.misto_konani
FROM Zamestnanec Z JOIN Ucast_udalosti UU USING(c_zamestnance) JOIN UDALOST U USING(id_udalosti)
WHERE Z.jmeno = 'Petr' and Z.prijmeni = 'Kubala';

-- dotaz s klauzulí GROUP BY a agregační funkcí č.1
-- Kolik zaměstanců májí jednotlivá oddělení?
SELECT O.nazev_oddeleni, COUNT(Z.c_zamestnance) AS pocet_zamestanancu
FROM Oddeleni O LEFT JOIN Zamestnanec Z ON Z.kod_oddeleni_zamestnance = O.kod_oddeleni
GROUP BY O.kod_oddeleni, O.nazev_oddeleni;

-- dotaz s klauzulí GROUP BY a agregační funkcí č.2
-- Kolika událostí se v dubnu 2022 účastní jednotliví členové vedení?
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
WHERE Z.role in ('MAN', 'RED') ;




-- dotaz obsahující predikát EXISTS
-- Které sekretářky nevytvořili žádnou událost?
SELECT Z.jmeno, Z.prijmeni, Z.rodne_c
FROM Zamestnanec Z
WHERE Z.role = 'SEK' AND NOT EXISTS (  SELECT U.id_udalosti
                                        FROM Udalost U
                                        WHERE U.id_autor = Z.c_zamestnance
                                    );

-- dotaz s predikátem IN s vnořeným selectem
-- Kteří manažeři se v dubnu neúčastní žádných událostí?
SELECT Z.jmeno, Z.prijmeni, Z.rodne_c
FROM Zamestnanec Z
WHERE Z.role = 'MAN'
    AND Z.c_zamestnance NOT IN (  SELECT Z.c_zamestnance
                                    FROM Zamestnanec Z JOIN Ucast_udalosti UU ON Z.c_zamestnance = UU.c_zamestnance
                                        JOIN UDALOST U ON UU.id_udalosti = U.id_udalosti
                                    WHERE U.datum_cas_do BETWEEN TO_DATE('1.4.2022 00:00', 'DD.MM.YYYY HH24:MI') AND TO_DATE('30.4.2022 23:59', 'DD.MM.YYYY HH24:MI')
                                )