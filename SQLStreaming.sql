USE master;
GO
DROP DATABASE IF EXISTS StreamingGraph;
GO
CREATE DATABASE StreamingGraph
COLLATE Cyrillic_General_CI_AS;
GO
USE StreamingGraph;
GO

CREATE TABLE Streamer
(
    id              INT            NOT NULL PRIMARY KEY,
    login           NVARCHAR(50)   NOT NULL UNIQUE,
    display_name    NVARCHAR(100)  NOT NULL,
    country         NVARCHAR(50)   NOT NULL,
    language        NVARCHAR(20)   NOT NULL,
    followers_count INT            NOT NULL,
    partner_status  NVARCHAR(20)   NOT NULL   
) AS NODE;
GO

CREATE TABLE Platform
(
    id              INT            NOT NULL PRIMARY KEY,
    name            NVARCHAR(50)   NOT NULL UNIQUE,
    website         NVARCHAR(100)  NOT NULL,
    founded_year    INT            NOT NULL,
    headquarters    NVARCHAR(100)  NOT NULL,
    monthly_users_m DECIMAL(6,1)   NOT NULL   
) AS NODE;
GO

CREATE TABLE GameCategory
(
    id              INT            NOT NULL PRIMARY KEY,
    name            NVARCHAR(100)  NOT NULL UNIQUE,
    genre           NVARCHAR(50)   NOT NULL,
    avg_viewers     INT            NOT NULL,
    is_esports      BIT            NOT NULL CONSTRAINT DF_GameCategory_IsEsports DEFAULT 0
) AS NODE;
GO

CREATE TABLE Game
(
    id              INT            NOT NULL PRIMARY KEY,
    title           NVARCHAR(100)  NOT NULL UNIQUE,
    developer       NVARCHAR(100)  NOT NULL,
    release_year    INT            NOT NULL,
    category_id     INT            NOT NULL
) AS NODE;
GO

CREATE TABLE Viewer
(
    id                INT            NOT NULL PRIMARY KEY,
    username          NVARCHAR(50)   NOT NULL UNIQUE,
    country           NVARCHAR(50)   NOT NULL,
    subscription_tier NVARCHAR(10)   NOT NULL,   
    total_watch_h     INT            NOT NULL    
) AS NODE;
GO

CREATE TABLE Streams
(
    start_date          DATE           NOT NULL,
    contract_type       NVARCHAR(30)   NOT NULL,
    avg_viewers         INT            NOT NULL,
    monthly_income_usd  INT            NOT NULL
) AS EDGE;
GO
ALTER TABLE Streams
    ADD CONSTRAINT EC_Streams CONNECTION (Streamer TO Platform);
GO

CREATE TABLE PlaysGame
(
    first_stream_date  DATE         NOT NULL,
    total_hours_played INT          NOT NULL,
    peak_viewers       INT          NOT NULL,
    is_sponsored       BIT          NOT NULL CONSTRAINT DF_PlaysGame_Sponsored DEFAULT 0
) AS EDGE;
GO
ALTER TABLE PlaysGame
    ADD CONSTRAINT EC_PlaysGame CONNECTION (Streamer TO Game);
GO

CREATE TABLE Collaborates
(
    collab_date        DATE         NOT NULL,
    collab_type        NVARCHAR(40) NOT NULL,
    viewers_peak       INT          NOT NULL,
    initiated_by_login NVARCHAR(50) NOT NULL
) AS EDGE;
GO
ALTER TABLE Collaborates
    ADD CONSTRAINT EC_Collaborates CONNECTION (Streamer TO Streamer);
GO

CREATE TABLE Follows
(
    follow_date        DATE         NOT NULL,
    is_subscribed      BIT          NOT NULL CONSTRAINT DF_Follows_Subscribed DEFAULT 0,
    gifted_subs_count  INT          NOT NULL CONSTRAINT DF_Follows_Gifted DEFAULT 0,
    total_donated_usd  DECIMAL(8,2) NOT NULL CONSTRAINT DF_Follows_Donated DEFAULT 0
) AS EDGE;
GO
ALTER TABLE Follows
    ADD CONSTRAINT EC_Follows CONNECTION (Viewer TO Streamer);
GO

CREATE TABLE BelongsTo
(
    assigned_date      DATE         NOT NULL,
    relevance_score    DECIMAL(4,2) NOT NULL,
    is_primary         BIT          NOT NULL CONSTRAINT DF_BelongsTo_Primary DEFAULT 1
) AS EDGE;
GO
ALTER TABLE BelongsTo
    ADD CONSTRAINT EC_BelongsTo CONNECTION (Game TO GameCategory);
GO


INSERT INTO Streamer (id, login, display_name, country, language, followers_count, partner_status)
VALUES
( 1, 'xQc',            N'xQcOW',              N'Канада',           N'EN', 11800000, N'Partner'),
( 2, 'shroud',         N'shroud',             N'США',              N'EN',  9200000, N'Partner'),
( 3, 'Ninja',          N'Ninja',              N'США',              N'EN', 18700000, N'Partner'),
( 4, 'pokimane',       N'pokimane',           N'Канада',           N'EN', 10400000, N'Partner'),
( 5, 'HasanAbi',       N'HasanAbi',           N'США',              N'EN',  2600000, N'Partner'),
( 6, 'summit1g',       N'summit1g',           N'США',              N'EN',  6100000, N'Partner'),
( 7, 'TimTheTatman',   N'TimTheTatman',       N'США',              N'EN',  7200000, N'Partner'),
( 8, 'DrLupo',         N'DrLupo',             N'США',              N'EN',  4700000, N'Partner'),
( 9, 'valkyrae',       N'valkyrae',           N'США',              N'EN',  3800000, N'Partner'),
(10, 'Disguised_Toast',N'DisguisedToast',     N'Канада',           N'EN',  2300000, N'Partner'),
(11, 'Anomaly',        N'Anomaly',            N'Швеция',           N'EN',   990000, N'Partner'),
(12, 'forsen',         N'forsen',             N'Швеция',           N'EN',  1400000, N'Partner');
GO

SELECT * FROM Streamer;
GO

INSERT INTO Platform (id, name, website, founded_year, headquarters, monthly_users_m)
VALUES
(1, N'Twitch',          N'twitch.tv',   2011, N'Сан-Франциско, США',    140.0),
(2, N'YouTube',         N'youtube.com', 2005, N'Сан-Бруно, США',        800.0),
(3, N'Kick',            N'kick.com',    2022, N'Окленд, Новая Зеландия',  50.0),
(4, N'Facebook Gaming', N'fb.gg',       2018, N'Менло-Парк, США',         38.0),
(5, N'Trovo',           N'trovo.live',  2020, N'Шэньчжэнь, Китай',        25.0);
GO

SELECT * FROM Platform;
GO

INSERT INTO GameCategory (id, name, genre, avg_viewers, is_esports)
VALUES
( 1, N'Battle Royale',     N'Шутер',              95000, 1),
( 2, N'FPS',               N'Шутер',             110000, 1),
( 3, N'MOBA',              N'Стратегия',          80000, 1),
( 4, N'Just Chatting',     N'Ток-шоу',           200000, 0),
( 5, N'Survival',          N'Выживание',          45000, 0),
( 6, N'Card Games',        N'Карточные игры',     30000, 0),
( 7, N'MMO RPG',           N'Ролевые',            60000, 0),
( 8, N'Horror',            N'Хоррор',             38000, 0),
( 9, N'Sports Simulation', N'Спорт',              55000, 0),
(10, N'Indie',             N'Инди',               25000, 0),
(11, N'Strategy',          N'Стратегия',          40000, 0),
(12, N'IRL',               N'Реалити-стриминг',   70000, 0);
GO

SELECT * FROM GameCategory;
GO

INSERT INTO Game (id, title, developer, release_year, category_id)
VALUES
( 1, N'Fortnite',             N'Epic Games',             2017, 1),
( 2, N'Counter-Strike 2',     N'Valve',                  2023, 2),
( 3, N'Valorant',             N'Riot Games',             2020, 2),
( 4, N'League of Legends',    N'Riot Games',             2009, 3),
( 5, N'Minecraft',            N'Mojang Studios',         2011, 5),
( 6, N'Apex Legends',         N'Respawn Entertainment',  2019, 1),
( 7, N'World of Warcraft',    N'Blizzard Entertainment', 2004, 7),
( 8, N'Hearthstone',          N'Blizzard Entertainment', 2014, 6),
( 9, N'Among Us',             N'Innersloth',             2018,10),
(10, N'Grand Theft Auto V',   N'Rockstar Games',         2013, 5),
(11, N'Rust',                 N'Facepunch Studios',      2013, 5),
(12, N'Escape from Tarkov',   N'Battlestate Games',      2016, 2),
(13, N'FIFA 24',              N'EA Sports',              2023, 9),
(14, N'Dota 2',               N'Valve',                  2013, 3),
(15, N'Dead by Daylight',     N'Behaviour Interactive',  2016, 8);
GO

SELECT * FROM Game;
GO


INSERT INTO Viewer (id, username, country, subscription_tier, total_watch_h)
VALUES
( 1, N'GamingFan2001',    N'США',          N'Tier2',  4200),
( 2, N'StreamWatcher_RU', N'Россия',       N'Tier1',  1800),
( 3, N'NordicViewer',     N'Норвегия',     N'Tier3',  7600),
( 4, N'CasualGamer_DE',   N'Германия',     N'Free',    320),
( 5, N'EsportsFan_KR',    N'Южная Корея',  N'Tier1',  5100),
( 6, N'TwitchAddict_BR',  N'Бразилия',     N'Tier2',  9200),
( 7, N'LurkerOnly_JP',    N'Япония',       N'Free',    180),
( 8, N'SubGifterPro_CA',  N'Канада',       N'Tier3', 12400),
( 9, N'NewbieChill_FR',   N'Франция',      N'Free',     95),
(10, N'HypeTrainMax_AU',  N'Австралия',    N'Tier1',  3300),
(11, N'ChatSpammer_MX',   N'Мексика',      N'Tier2',  2700),
(12, N'VodReviewer_PL',   N'Польша',       N'Tier1',  1450);
GO

SELECT * FROM Viewer;
GO

INSERT INTO Streams (start_date, contract_type, avg_viewers, monthly_income_usd, $from_id, $to_id)
VALUES
('2016-05-01', N'Exclusive',     58000, 200000,
    (SELECT $node_id FROM Streamer WHERE login='xQc'),
    (SELECT $node_id FROM Platform WHERE name=N'Twitch')),
('2023-03-15', N'Non-exclusive', 42000,  95000,
    (SELECT $node_id FROM Streamer WHERE login='shroud'),
    (SELECT $node_id FROM Platform WHERE name=N'Twitch')),
('2011-06-01', N'Exclusive',     85000, 350000,
    (SELECT $node_id FROM Streamer WHERE login='Ninja'),
    (SELECT $node_id FROM Platform WHERE name=N'Twitch')),
('2022-01-10', N'Exclusive',     38000, 120000,
    (SELECT $node_id FROM Streamer WHERE login='pokimane'),
    (SELECT $node_id FROM Platform WHERE name=N'Twitch')),
('2019-09-25', N'Exclusive',     32000,  80000,
    (SELECT $node_id FROM Streamer WHERE login='HasanAbi'),
    (SELECT $node_id FROM Platform WHERE name=N'Twitch')),
('2012-03-08', N'Exclusive',     28000,  70000,
    (SELECT $node_id FROM Streamer WHERE login='summit1g'),
    (SELECT $node_id FROM Platform WHERE name=N'Twitch')),
('2021-09-01', N'Exclusive',     30000, 180000,
    (SELECT $node_id FROM Streamer WHERE login='TimTheTatman'),
    (SELECT $node_id FROM Platform WHERE name=N'YouTube')),
('2021-08-12', N'Exclusive',     22000, 150000,
    (SELECT $node_id FROM Streamer WHERE login='DrLupo'),
    (SELECT $node_id FROM Platform WHERE name=N'YouTube')),
('2020-10-01', N'Non-exclusive', 45000, 160000,
    (SELECT $node_id FROM Streamer WHERE login='valkyrae'),
    (SELECT $node_id FROM Platform WHERE name=N'YouTube')),
('2023-06-01', N'Trial',         18000,  40000,
    (SELECT $node_id FROM Streamer WHERE login='Disguised_Toast'),
    (SELECT $node_id FROM Platform WHERE name=N'Kick')),
('2015-01-20', N'Non-exclusive', 12000,  25000,
    (SELECT $node_id FROM Streamer WHERE login='Anomaly'),
    (SELECT $node_id FROM Platform WHERE name=N'Twitch')),
('2013-04-12', N'Non-exclusive', 15000,  30000,
    (SELECT $node_id FROM Streamer WHERE login='forsen'),
    (SELECT $node_id FROM Platform WHERE name=N'Twitch'));
GO

SELECT * FROM Streams;
GO


INSERT INTO PlaysGame (first_stream_date, total_hours_played, peak_viewers, is_sponsored, $from_id, $to_id)
VALUES
('2018-07-10', 1200,  72000, 0,
    (SELECT $node_id FROM Streamer WHERE login='xQc'),
    (SELECT $node_id FROM Game WHERE title=N'Grand Theft Auto V')),
('2019-03-22',  380,  45000, 0,
    (SELECT $node_id FROM Streamer WHERE login='xQc'),
    (SELECT $node_id FROM Game WHERE title=N'Minecraft')),
('2020-01-15', 2100, 180000, 1,
    (SELECT $node_id FROM Streamer WHERE login='shroud'),
    (SELECT $node_id FROM Game WHERE title=N'Valorant')),
('2018-02-01',  950,  95000, 1,
    (SELECT $node_id FROM Streamer WHERE login='shroud'),
    (SELECT $node_id FROM Game WHERE title=N'Counter-Strike 2')),
('2017-07-25', 3400, 320000, 1,
    (SELECT $node_id FROM Streamer WHERE login='Ninja'),
    (SELECT $node_id FROM Game WHERE title=N'Fortnite')),
('2022-06-10',  210,  62000, 1,
    (SELECT $node_id FROM Streamer WHERE login='Ninja'),
    (SELECT $node_id FROM Game WHERE title=N'Apex Legends')),
('2021-04-01',  430,  55000, 0,
    (SELECT $node_id FROM Streamer WHERE login='pokimane'),
    (SELECT $node_id FROM Game WHERE title=N'Among Us')),
('2019-11-05',  180,  38000, 0,
    (SELECT $node_id FROM Streamer WHERE login='pokimane'),
    (SELECT $node_id FROM Game WHERE title=N'League of Legends')),
('2020-09-15',  620,  48000, 0,
    (SELECT $node_id FROM Streamer WHERE login='summit1g'),
    (SELECT $node_id FROM Game WHERE title=N'Rust')),
('2016-08-20', 1800,  68000, 0,
    (SELECT $node_id FROM Streamer WHERE login='summit1g'),
    (SELECT $node_id FROM Game WHERE title=N'Counter-Strike 2')),
('2021-01-03',  540,  75000, 0,
    (SELECT $node_id FROM Streamer WHERE login='TimTheTatman'),
    (SELECT $node_id FROM Game WHERE title=N'Fortnite')),
('2019-02-14',  310,  35000, 0,
    (SELECT $node_id FROM Streamer WHERE login='Disguised_Toast'),
    (SELECT $node_id FROM Game WHERE title=N'Hearthstone')),
('2020-10-01',  220,  40000, 0,
    (SELECT $node_id FROM Streamer WHERE login='Disguised_Toast'),
    (SELECT $node_id FROM Game WHERE title=N'Among Us')),
('2014-05-01', 4200,  28000, 0,
    (SELECT $node_id FROM Streamer WHERE login='forsen'),
    (SELECT $node_id FROM Game WHERE title=N'Hearthstone')),
('2022-03-10',  160,  20000, 0,
    (SELECT $node_id FROM Streamer WHERE login='Anomaly'),
    (SELECT $node_id FROM Game WHERE title=N'Counter-Strike 2')),
('2018-09-01',  480,  22000, 0,
    (SELECT $node_id FROM Streamer WHERE login='HasanAbi'),
    (SELECT $node_id FROM Game WHERE title=N'Grand Theft Auto V')),
('2023-01-20',  140,  55000, 1,
    (SELECT $node_id FROM Streamer WHERE login='valkyrae'),
    (SELECT $node_id FROM Game WHERE title=N'Valorant')),
('2017-11-12',  720,  62000, 0,
    (SELECT $node_id FROM Streamer WHERE login='DrLupo'),
    (SELECT $node_id FROM Game WHERE title=N'Fortnite'));
GO

SELECT * FROM PlaysGame;
GO


INSERT INTO Collaborates (collab_date, collab_type, viewers_peak, initiated_by_login, $from_id, $to_id)
VALUES
('2018-08-15', N'Co-stream',   500000, N'Ninja',
    (SELECT $node_id FROM Streamer WHERE login='Ninja'),
    (SELECT $node_id FROM Streamer WHERE login='TimTheTatman')),
('2018-08-15', N'Co-stream',   500000, N'Ninja',
    (SELECT $node_id FROM Streamer WHERE login='TimTheTatman'),
    (SELECT $node_id FROM Streamer WHERE login='Ninja')),
('2020-12-01', N'Tournament',  320000, N'Ninja',
    (SELECT $node_id FROM Streamer WHERE login='Ninja'),
    (SELECT $node_id FROM Streamer WHERE login='DrLupo')),
('2020-12-01', N'Tournament',  320000, N'Ninja',
    (SELECT $node_id FROM Streamer WHERE login='DrLupo'),
    (SELECT $node_id FROM Streamer WHERE login='Ninja')),
('2021-10-05', N'Raid',         85000, N'xQc',
    (SELECT $node_id FROM Streamer WHERE login='xQc'),
    (SELECT $node_id FROM Streamer WHERE login='HasanAbi')),
('2022-03-20', N'Co-stream',   140000, N'pokimane',
    (SELECT $node_id FROM Streamer WHERE login='pokimane'),
    (SELECT $node_id FROM Streamer WHERE login='valkyrae')),
('2022-03-20', N'Co-stream',   140000, N'pokimane',
    (SELECT $node_id FROM Streamer WHERE login='valkyrae'),
    (SELECT $node_id FROM Streamer WHERE login='pokimane')),
('2023-06-11', N'Host',         22000, N'Disguised_Toast',
    (SELECT $node_id FROM Streamer WHERE login='Disguised_Toast'),
    (SELECT $node_id FROM Streamer WHERE login='pokimane')),
('2021-04-18', N'Raid',         55000, N'shroud',
    (SELECT $node_id FROM Streamer WHERE login='shroud'),
    (SELECT $node_id FROM Streamer WHERE login='summit1g')),
('2020-06-07', N'Tournament',   95000, N'TimTheTatman',
    (SELECT $node_id FROM Streamer WHERE login='TimTheTatman'),
    (SELECT $node_id FROM Streamer WHERE login='shroud')),
('2022-11-22', N'Co-stream',    48000, N'forsen',
    (SELECT $node_id FROM Streamer WHERE login='forsen'),
    (SELECT $node_id FROM Streamer WHERE login='Anomaly')),
('2022-11-22', N'Co-stream',    48000, N'forsen',
    (SELECT $node_id FROM Streamer WHERE login='Anomaly'),
    (SELECT $node_id FROM Streamer WHERE login='forsen')),
('2023-02-14', N'Co-stream',    38000, N'HasanAbi',
    (SELECT $node_id FROM Streamer WHERE login='HasanAbi'),
    (SELECT $node_id FROM Streamer WHERE login='xQc')),
('2019-12-31', N'Raid',         62000, N'summit1g',
    (SELECT $node_id FROM Streamer WHERE login='summit1g'),
    (SELECT $node_id FROM Streamer WHERE login='shroud'));
GO

SELECT * FROM Collaborates;
GO


INSERT INTO Follows (follow_date, is_subscribed, gifted_subs_count, total_donated_usd, $from_id, $to_id)
VALUES
('2019-03-10', 1,  5,  250.00,
    (SELECT $node_id FROM Viewer WHERE username=N'GamingFan2001'),
    (SELECT $node_id FROM Streamer WHERE login='Ninja')),
('2020-07-25', 1,  0,   50.00,
    (SELECT $node_id FROM Viewer WHERE username=N'GamingFan2001'),
    (SELECT $node_id FROM Streamer WHERE login='shroud')),
('2021-01-08', 1, 20,  500.00,
    (SELECT $node_id FROM Viewer WHERE username=N'NordicViewer'),
    (SELECT $node_id FROM Streamer WHERE login='xQc')),
('2018-11-14', 0,  0,    0.00,
    (SELECT $node_id FROM Viewer WHERE username=N'CasualGamer_DE'),
    (SELECT $node_id FROM Streamer WHERE login='pokimane')),
('2022-05-03', 1,  3,  120.00,
    (SELECT $node_id FROM Viewer WHERE username=N'EsportsFan_KR'),
    (SELECT $node_id FROM Streamer WHERE login='shroud')),
('2020-09-17', 1, 50, 1200.00,
    (SELECT $node_id FROM Viewer WHERE username=N'SubGifterPro_CA'),
    (SELECT $node_id FROM Streamer WHERE login='xQc')),
('2021-06-30', 1,  8,  300.00,
    (SELECT $node_id FROM Viewer WHERE username=N'TwitchAddict_BR'),
    (SELECT $node_id FROM Streamer WHERE login='Ninja')),
('2023-01-05', 1,  0,   80.00,
    (SELECT $node_id FROM Viewer WHERE username=N'HypeTrainMax_AU'),
    (SELECT $node_id FROM Streamer WHERE login='TimTheTatman')),
('2022-08-19', 0,  0,    0.00,
    (SELECT $node_id FROM Viewer WHERE username=N'LurkerOnly_JP'),
    (SELECT $node_id FROM Streamer WHERE login='valkyrae')),
('2020-03-22', 1,  2,   60.00,
    (SELECT $node_id FROM Viewer WHERE username=N'ChatSpammer_MX'),
    (SELECT $node_id FROM Streamer WHERE login='HasanAbi')),
('2019-07-04', 1, 15,  450.00,
    (SELECT $node_id FROM Viewer WHERE username=N'StreamWatcher_RU'),
    (SELECT $node_id FROM Streamer WHERE login='forsen')),
('2023-04-01', 0,  0,    5.00,
    (SELECT $node_id FROM Viewer WHERE username=N'NewbieChill_FR'),
    (SELECT $node_id FROM Streamer WHERE login='pokimane')),
('2021-11-11', 1,  7,  180.00,
    (SELECT $node_id FROM Viewer WHERE username=N'VodReviewer_PL'),
    (SELECT $node_id FROM Streamer WHERE login='summit1g')),
('2017-12-25', 1, 30,  900.00,
    (SELECT $node_id FROM Viewer WHERE username=N'SubGifterPro_CA'),
    (SELECT $node_id FROM Streamer WHERE login='Ninja'));
GO

SELECT * FROM Follows;
GO


INSERT INTO BelongsTo (assigned_date, relevance_score, is_primary, $from_id, $to_id)
VALUES
('2017-07-25', 9.8, 1,
    (SELECT $node_id FROM Game WHERE title=N'Fortnite'),
    (SELECT $node_id FROM GameCategory WHERE name=N'Battle Royale')),
('2023-09-27', 9.5, 1,
    (SELECT $node_id FROM Game WHERE title=N'Counter-Strike 2'),
    (SELECT $node_id FROM GameCategory WHERE name=N'FPS')),
('2020-06-02', 9.3, 1,
    (SELECT $node_id FROM Game WHERE title=N'Valorant'),
    (SELECT $node_id FROM GameCategory WHERE name=N'FPS')),
('2009-10-27', 9.7, 1,
    (SELECT $node_id FROM Game WHERE title=N'League of Legends'),
    (SELECT $node_id FROM GameCategory WHERE name=N'MOBA')),
('2011-11-18', 8.5, 1,
    (SELECT $node_id FROM Game WHERE title=N'Minecraft'),
    (SELECT $node_id FROM GameCategory WHERE name=N'Survival')),
('2019-02-04', 8.8, 1,
    (SELECT $node_id FROM Game WHERE title=N'Apex Legends'),
    (SELECT $node_id FROM GameCategory WHERE name=N'Battle Royale')),
('2004-11-23', 8.2, 1,
    (SELECT $node_id FROM Game WHERE title=N'World of Warcraft'),
    (SELECT $node_id FROM GameCategory WHERE name=N'MMO RPG')),
('2014-03-11', 8.0, 1,
    (SELECT $node_id FROM Game WHERE title=N'Hearthstone'),
    (SELECT $node_id FROM GameCategory WHERE name=N'Card Games')),
('2018-11-16', 7.5, 1,
    (SELECT $node_id FROM Game WHERE title=N'Among Us'),
    (SELECT $node_id FROM GameCategory WHERE name=N'Indie')),
('2013-09-17', 7.8, 1,
    (SELECT $node_id FROM Game WHERE title=N'Grand Theft Auto V'),
    (SELECT $node_id FROM GameCategory WHERE name=N'Survival')),
('2013-06-11', 8.6, 1,
    (SELECT $node_id FROM Game WHERE title=N'Rust'),
    (SELECT $node_id FROM GameCategory WHERE name=N'Survival')),
('2016-07-28', 8.4, 1,
    (SELECT $node_id FROM Game WHERE title=N'Escape from Tarkov'),
    (SELECT $node_id FROM GameCategory WHERE name=N'FPS')),
('2023-09-29', 7.2, 1,
    (SELECT $node_id FROM Game WHERE title=N'FIFA 24'),
    (SELECT $node_id FROM GameCategory WHERE name=N'Sports Simulation')),
('2013-07-09', 9.0, 1,
    (SELECT $node_id FROM Game WHERE title=N'Dota 2'),
    (SELECT $node_id FROM GameCategory WHERE name=N'MOBA')),
('2016-06-14', 8.1, 1,
    (SELECT $node_id FROM Game WHERE title=N'Dead by Daylight'),
    (SELECT $node_id FROM GameCategory WHERE name=N'Horror'));
GO

SELECT * FROM BelongsTo;
GO

PRINT N'Запрос 1. Стримеры и игры на Twitch';

SELECT
    p.name                              AS [Платформа],
    s.display_name                      AS [Стример],
    s.country                           AS [Страна],
    str.contract_type                   AS [Тип контракта],
    str.avg_viewers                     AS [Ср. зрителей],
    g.title                             AS [Игра],
    pg.total_hours_played               AS [Всего часов],
    pg.peak_viewers                     AS [Пик зрителей],
    IIF(pg.is_sponsored=1,N'Да',N'Нет') AS [Спонсировано]
FROM Platform AS p
   , Streams   AS str
   , Streamer  AS s
   , PlaysGame AS pg
   , Game      AS g
WHERE MATCH(p<-(str)-s-(pg)->g)
  AND p.name = N'Twitch'
ORDER BY s.display_name, pg.peak_viewers DESC;
GO

PRINT N'Запрос 2. Зрители, поддерживающие стримеров донатами (>$100)';

SELECT
    v.username                  AS [Зритель],
    v.country                   AS [Страна зрителя],
    f.follow_date               AS [Дата подписки],
    f.total_donated_usd         AS [Донатов (USD)],
    f.gifted_subs_count         AS [Подарено суб],
    s.display_name              AS [Стример],
    str2.contract_type          AS [Тип контракта],
    pl.name                     AS [Платформа]
FROM Viewer   AS v
   , Follows  AS f
   , Streamer AS s
   , Streams  AS str2
   , Platform AS pl
WHERE MATCH(v-(f)->s-(str2)->pl)
  AND f.is_subscribed = 1
  AND f.total_donated_usd > 100
ORDER BY f.total_donated_usd DESC;
GO

PRINT N'Запрос 3. Коллаборации (Co-stream/Tournament) и игры приглашённых';


SELECT
    s1.display_name             AS [Инициатор],
    c.collab_type               AS [Тип коллаборации],
    c.collab_date               AS [Дата],
    c.viewers_peak              AS [Пик зрителей],
    s2.display_name             AS [Приглашённый],
    g.title                     AS [Игра приглашённого],
    pg.peak_viewers             AS [Пик зрителей игры]
FROM Streamer     AS s1
   , Collaborates AS c
   , Streamer     AS s2
   , PlaysGame    AS pg
   , Game         AS g
WHERE MATCH(s1-(c)->s2-(pg)->g)
  AND c.collab_type IN (N'Co-stream', N'Tournament')
ORDER BY c.viewers_peak DESC;
GO

PRINT N'Запрос 4. Категории контента стримеров Twitch (цепочка 4 узла)';

SELECT
    pl.name             AS [Платформа],
    s.display_name      AS [Стример],
    g.title             AS [Игра],
    gc.name             AS [Категория],
    gc.genre            AS [Жанр],
    gc.avg_viewers      AS [Ср. зрителей категории],
    gc.is_esports       AS [Киберспорт]
FROM Platform     AS pl
   , Streams      AS st
   , Streamer     AS s
   , PlaysGame    AS pg
   , Game         AS g
   , BelongsTo    AS bt
   , GameCategory AS gc
WHERE MATCH(pl<-(st)-s-(pg)->g-(bt)->gc)
  AND pl.name = N'Twitch'
ORDER BY gc.avg_viewers DESC, s.display_name;
GO

PRINT N'Запрос 5. Зрители -> Стримеры -> Спонсируемые игры -> Категории (4 узла)';

SELECT
    v.username          AS [Зритель],
    v.subscription_tier AS [Тир подписки],
    s.display_name      AS [Стример],
    g.title             AS [Спонсируемая игра],
    pg.peak_viewers     AS [Пик зрителей],
    gc.name             AS [Категория],
    gc.genre            AS [Жанр]
FROM Viewer       AS v
   , Follows      AS f
   , Streamer     AS s
   , PlaysGame    AS pg
   , Game         AS g
   , BelongsTo    AS bt
   , GameCategory AS gc
WHERE MATCH(v-(f)->s-(pg)->g-(bt)->gc)
  AND pg.is_sponsored = 1
  AND v.subscription_tier <> N'Free'
ORDER BY pg.peak_viewers DESC;
GO

PRINT N'Запрос 6. Ninja: коллаборации -> стримеры -> игры -> категории (4 узла)';

SELECT DISTINCT
    s1.display_name     AS [Инициатор],
    c.collab_type       AS [Тип],
    s2.display_name     AS [Приглашённый],
    g.title             AS [Игра],
    gc.name             AS [Категория],
    gc.is_esports       AS [Киберспорт]
FROM Streamer     AS s1
   , Collaborates AS c
   , Streamer     AS s2
   , PlaysGame    AS pg
   , Game         AS g
   , BelongsTo    AS bt
   , GameCategory AS gc
WHERE MATCH(s1-(c)->s2-(pg)->g-(bt)->gc)
  AND s1.login = N'Ninja'
ORDER BY gc.name;
GO

PRINT N'Запрос 7. Кратчайшие пути коллаборации из Ninja (шаблон "+")';

SELECT
    s1.display_name                                         AS [Начало пути],
    s1.login                                                AS [Логин],
    STRING_AGG(s2.display_name, N' -> ')
        WITHIN GROUP (GRAPH PATH)                           AS [Цепочка коллабораций],
    LAST_VALUE(s2.display_name)
        WITHIN GROUP (GRAPH PATH)                           AS [Последний стример],
    COUNT(c.*)
        WITHIN GROUP (GRAPH PATH)                           AS [Шагов],
    MIN(c.collab_date)
        WITHIN GROUP (GRAPH PATH)                           AS [Самая ранняя коллаб]
FROM Streamer            AS s1
   , Collaborates FOR PATH AS c
   , Streamer    FOR PATH AS s2
WHERE MATCH(SHORTEST_PATH(s1(-(c)->s2)+))
  AND s1.login = N'Ninja'
ORDER BY COUNT(c.*) WITHIN GROUP (GRAPH PATH);
GO

PRINT N'Запрос 8. Пути коллабораций из xQc длиной 1-3 шага (шаблон "{1,3}")';


SELECT
    s1.display_name                                         AS [Исходный стример],
    STRING_AGG(s2.display_name, N' -> ')
        WITHIN GROUP (GRAPH PATH)                           AS [Путь коллабораций],
    STRING_AGG(s2.login, N'->')
        WITHIN GROUP (GRAPH PATH)                           AS [Логины пути],
    LAST_VALUE(s2.display_name)
        WITHIN GROUP (GRAPH PATH)                           AS [Конечный стример],
    COUNT(c.*)
        WITHIN GROUP (GRAPH PATH)                           AS [Шагов]
FROM Streamer            AS s1
   , Collaborates FOR PATH AS c
   , Streamer    FOR PATH AS s2
WHERE MATCH(SHORTEST_PATH(s1(-(c)->s2){1,3}))
  AND s1.login = N'xQc'
ORDER BY COUNT(c.*) WITHIN GROUP (GRAPH PATH);
GO

PRINT N'Запрос 9. Кратчайший путь pokimane -> forsen через коллаборации';

WITH AllPaths AS
(
    SELECT
        s1.display_name                                     AS StartName,
        s1.login                                            AS StartLogin,
        STRING_AGG(s2.display_name, N' -> ')
            WITHIN GROUP (GRAPH PATH)                       AS PathNames,
        STRING_AGG(s2.login, N'->')
            WITHIN GROUP (GRAPH PATH)                       AS PathLogins,
        LAST_VALUE(s2.login)
            WITHIN GROUP (GRAPH PATH)                       AS LastLogin,
        COUNT(c.*)
            WITHIN GROUP (GRAPH PATH)                       AS Hops
    FROM Streamer            AS s1
       , Collaborates FOR PATH AS c
       , Streamer    FOR PATH AS s2
    WHERE MATCH(SHORTEST_PATH(s1(-(c)->s2)+))
      AND s1.login = N'pokimane'
)
SELECT
    StartName                               AS [Откуда],
    StartName + N' -> ' + PathNames        AS [Полный путь],
    StartLogin + N'->' + PathLogins        AS [Логины],
    Hops                                    AS [Шагов]
FROM AllPaths
WHERE LastLogin = N'forsen';
GO

PRINT N'Запрос 10. Достижимые стримеры от shroud за 1-2 шага (шаблон "{1,2}")';

SELECT
    s1.display_name                                         AS [Исходный стример],
    s1.country                                              AS [Страна],
    STRING_AGG(s2.display_name, N' -> ')
        WITHIN GROUP (GRAPH PATH)                           AS [Путь],
    LAST_VALUE(s2.display_name)
        WITHIN GROUP (GRAPH PATH)                           AS [Конечный стример],
    LAST_VALUE(s2.country)
        WITHIN GROUP (GRAPH PATH)                           AS [Страна конечного],
    COUNT(c.*)
        WITHIN GROUP (GRAPH PATH)                           AS [Шагов],
    MIN(c.viewers_peak)
        WITHIN GROUP (GRAPH PATH)                           AS [Мин. пик зрителей]
FROM Streamer            AS s1
   , Collaborates FOR PATH AS c
   , Streamer    FOR PATH AS s2
WHERE MATCH(SHORTEST_PATH(s1(-(c)->s2){1,2}))
  AND s1.login = N'shroud'
ORDER BY COUNT(c.*) WITHIN GROUP (GRAPH PATH);
GO


PRINT N'Граф коллабораций: узлы и рёбра для визуализации';

SELECT
    s1.id           AS IdFirst,
    s1.display_name AS [Стример 1],
    CONCAT(N'Streamer', s1.id) AS [Image1],
    s2.id           AS IdSecond,
    s2.display_name AS [Стример 2],
    CONCAT(N'Streamer', s2.id) AS [Image2],
    c.viewers_peak  AS Weight,
    c.collab_type   AS [Тип связи]
FROM Streamer        AS s1
   , Collaborates    AS c
   , Streamer        AS s2
WHERE MATCH(s1-(c)->s2);
GO
