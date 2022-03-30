BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE Udalost_zamestnance';
   EXECUTE IMMEDIATE 'DROP TABLE Udalost';
   EXECUTE IMMEDIATE 'DROP TABLE Oddeleni';
   EXECUTE IMMEDIATE 'DROP TABLE Zamestnanec';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE != -942 THEN
         RAISE;
      END IF;
END;

CREATE TABLE Oddeleni (
    kod_oddeleni VARCHAR(10) PRIMARY KEY,
    nazev_oddeleni VARCHAR(100)
);

CREATE TABLE Zamestnanec(
    c_zamestnance INT PRIMARY KEY,
    rodne_c       CHAR(10), -- kontola formatu HERE!
    jmeno         VARCHAR(50),
    prijmeni      VARCHAR(50),
    role          VARCHAR(10),
    nadrizeny_reditel INT,
    oddeleni_manazera INT,
    CONSTRAINT FK_nadrizeny_reditel
        FOREIGN KEY (nadrizeny_reditel) REFERENCES Zamestnanec(c_zamestnance),
    CONSTRAINT FK_oddeleni_manazera
        FOREIGN KEY (oddeleni_manazera) REFERENCES Zamestnanec(c_zamestnance),
    CONSTRAINT CHK_role CHECK (role IN ('REDITEL', 'MANAZER', 'SEKRETARKA')),
    CONSTRAINT CHK_vazby_role CHECK ( (role = 'REDITEL' AND nadrizeny_reditel IS NULL AND oddeleni_manazera IS NULL) OR
                                (role = 'MANAZER' AND nadrizeny_reditel IS NULL AND oddeleni_manazera IS NULL) OR
                                (role = 'SEKRETARKA' AND nadrizeny_reditel IS NULL AND oddeleni_manazera IS NOT NULL) OR
                                (role = 'SEKRETARKA' AND nadrizeny_reditel IS NOT NULL AND oddeleni_manazera IS NULL))
);


CREATE TABLE Udalost (
    id_udalosti INT PRIMARY KEY,
    datum_cas_od TIMESTAMP WITH LOCAL TIME ZONE,
    datum_cas_do TIMESTAMP WITH LOCAL TIME ZONE,
    nazev VARCHAR(100),
    misto_konani VARCHAR(100),
    popis VARCHAR(500),
    autor INT,
    CONSTRAINT FK_autor
        FOREIGN KEY (autor) REFERENCES Zamestnanec(c_zamestnance)
);

CREATE TABLE Udalost_zamestnance (
    c_zamestnance INT,
    id_udalosti INT,
    CONSTRAINT PK_udalost_zamestance
        PRIMARY KEY (c_zamestnance, id_udalosti),
    CONSTRAINT FK_zamestnanec
        FOREIGN KEY (c_zamestnance) REFERENCES Zamestnanec(c_zamestnance),
    CONSTRAINT FK_udalost
        FOREIGN KEY (id_udalosti) REFERENCES Udalost(id_udalosti)
);