-- =============================================================================
-- Venatus Analytics Engineering Challenge — Seed Data
-- =============================================================================
-- This file is executed once on first ClickHouse startup.
-- It creates the raw schema and populates it with ad-tech event data.
--
-- All event and campaign dates are computed relative to the current date so
-- the dataset stays realistic regardless of when the environment is started.
-- =============================================================================

-- -------------------------------------------------------------------------
-- Databases
-- -------------------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS raw;
CREATE DATABASE IF NOT EXISTS analytics;

-- -------------------------------------------------------------------------
-- raw.publishers
-- -------------------------------------------------------------------------
CREATE TABLE raw.publishers
(
    publisher_id      UInt32,
    publisher_name    String,
    publisher_category String,
    primary_domain    String,
    account_manager   String,
    country           String,
    created_at        DateTime,
    updated_at        DateTime
)
ENGINE = MergeTree()
ORDER BY publisher_id;

INSERT INTO raw.publishers VALUES
    (1,  'GameSpot Digital',       'gaming',        'gamespot.com',           'Alice Johnson',    'US', '2023-01-15 00:00:00', '2024-06-01 00:00:00'),
    (2,  'IGN Entertainment',      'gaming',        'ign.com',                'Bob Smith',        'US', '2023-02-01 00:00:00', '2024-05-15 00:00:00'),
    (3,  'Eurogamer Network',      'gaming',        'eurogamer.net',          'Claire Williams',  'GB', '2023-03-10 00:00:00', '2024-07-20 00:00:00'),
    (4,  'Rock Paper Shotgun',     'gaming',        'rockpapershotgun.com',   'Claire Williams',  'GB', '2023-04-05 00:00:00', '2024-04-10 00:00:00'),
    (5,  'Polygon Media',          'gaming',        'polygon.com',            'David Chen',       'US', '2023-05-20 00:00:00', '2024-08-01 00:00:00'),
    (6,  'Kotaku Digital',         'gaming',        'kotaku.com',             'Emma Davis',       'US', '2023-06-12 00:00:00', '2024-03-15 00:00:00'),
    (7,  'PC Gamer Online',        'gaming',        'pcgamer.com',            'Frank Miller',     'US', '2023-07-01 00:00:00', '2024-09-01 00:00:00'),
    (7,  'PC Gamer Digital',       'gaming',        'pcgamer.com',            'Frank Miller',     'US', '2023-07-01 00:00:00', '2025-01-10 00:00:00'),
    (8,  'GamesRadar Plus',        'gaming',        'gamesradar.com',         'Grace Lee',        'GB', '2023-08-15 00:00:00', '2024-06-20 00:00:00'),
    (9,  'VG247',                  'gaming',        'vg247.com',              'Henry Brown',      'GB', '2023-09-01 00:00:00', '2024-05-10 00:00:00'),
    (10, 'Destructoid',            'gaming',        'destructoid.com',        'Isabel Martinez',  'US', '2023-10-10 00:00:00', '2024-07-15 00:00:00'),
    (11, 'The Gamer Network',      'gaming',        'thegamer.com',           'Jack Wilson',      'CA', '2023-11-05 00:00:00', '2024-08-20 00:00:00'),
    (12, 'Screen Rant Gaming',     'entertainment', 'screenrant.com',         'Karen Taylor',     'US', '2023-12-01 00:00:00', '2024-04-25 00:00:00'),
    (13, 'GameRant',               'gaming',        'gamerant.com',           'Leo Garcia',       'US', '2024-01-15 00:00:00', '2024-09-10 00:00:00'),
    (14, 'DualShockers',           'gaming',        'dualshockers.com',       'Maria Rodriguez',  'US', '2024-02-01 00:00:00', '2024-06-05 00:00:00'),
    (15, 'Attack of the Fanboy',   'gaming',        'attackofthefanboy.com',  'Nate Thompson',    'US', '2024-03-10 00:00:00', '2024-07-30 00:00:00'),
    (16, 'Game Informer Digital',  'gaming',        'gameinformer.com',       'Olivia White',     'US', '2024-04-05 00:00:00', '2024-08-15 00:00:00'),
    (17, 'Push Square',            'gaming',        'pushsquare.com',         'Patrick Harris',   'GB', '2024-05-20 00:00:00', '2024-05-20 00:00:00'),
    (18, 'Nintendo Life',          'gaming',        'nintendolife.com',        'Quinn Adams',      'GB', '2024-06-12 00:00:00', '2024-06-12 00:00:00'),
    (19, 'TouchArcade',            'mobile_gaming', 'toucharcade.com',        'Rachel Scott',     'US', '2024-07-01 00:00:00', '2024-09-20 00:00:00'),
    (20, 'Pocket Gamer',           'mobile_gaming', 'pocketgamer.com',        'Sam Cooper',       'GB', '2024-08-15 00:00:00', '2024-08-15 00:00:00');


-- -------------------------------------------------------------------------
-- raw.campaigns  (dates shifted relative to today)
-- -------------------------------------------------------------------------
CREATE TABLE raw.campaigns
(
    campaign_id           UInt32,
    campaign_name         String,
    advertiser_id         UInt32,
    advertiser_name       String,
    campaign_start_date   Date,
    campaign_end_date     Date,
    campaign_budget_usd   Decimal64(2),
    campaign_status       String,
    targeting_device_types String,
    targeting_countries   String,
    created_at            DateTime
)
ENGINE = MergeTree()
ORDER BY campaign_id;

-- Stage with placeholder dates, then shift to be relative to today
CREATE TABLE raw._stg_campaigns AS raw.campaigns ENGINE = Memory;

INSERT INTO raw._stg_campaigns VALUES
    (1,  'Xbox Game Pass - Q1',                1,  'Microsoft Gaming',      '2025-01-01', '2025-03-31',  500000.00, 'active',  'desktop,mobile,ctv',      'US,GB,CA,AU',    '2024-12-15 00:00:00'),
    (2,  'PS5 Pro Launch Wave 2',              2,  'Sony Interactive',      '2025-01-05', '2025-02-28',  750000.00, 'active',  'desktop,mobile,tablet',   'US,GB,DE,FR,JP', '2024-12-20 00:00:00'),
    (3,  'Nintendo Direct - Spring',           3,  'Nintendo',              '2025-01-10', '2025-01-31',  300000.00, 'active',  'desktop,mobile',          'US,GB,JP',       '2025-01-05 00:00:00'),
    (4,  'EA FC Season Update',                4,  'Electronic Arts',       '2025-01-01', '2025-02-15',  400000.00, 'active',  'desktop,mobile,ctv',      'US,GB,DE,FR,BR', '2024-12-18 00:00:00'),
    (5,  'Assassins Creed Shadows',            5,  'Ubisoft',               '2025-01-15', '2025-03-15',  600000.00, 'active',  'desktop,mobile',          'US,GB,FR,DE',    '2025-01-10 00:00:00'),
    (6,  'Call of Duty - Season 2',            6,  'Activision Blizzard',   '2025-01-01', '2025-01-31',  900000.00, 'active',  'desktop,mobile,ctv',      'US,GB,DE,FR,AU', '2024-12-22 00:00:00'),
    (7,  'Fortnite Chapter 6',                 7,  'Epic Games',            '2025-01-01', '2025-04-30',  800000.00, 'active',  'desktop,mobile,tablet',   'US,GB,BR,MX',    '2024-12-28 00:00:00'),
    (8,  'Steam Winter Sale Promo',            8,  'Valve',                 '2024-12-20', '2025-01-05', 200000.00, 'completed','desktop',                 'US,GB,DE,FR,CA', '2024-12-10 00:00:00'),
    (9,  'AMD Ryzen 9000 Series',              9,  'AMD',                   '2025-01-01', '2025-06-30',  350000.00, 'active',  'desktop',                 'US,GB,DE,JP',    '2024-12-25 00:00:00'),
    (10, 'NVIDIA RTX 5090 Launch',             10, 'NVIDIA',                '2025-01-06', '2025-03-31',  450000.00, 'active',  'desktop',                 'US,GB,DE,JP,CA', '2025-01-02 00:00:00'),
    (11, 'Razer Blade 2025',                   1,  'Microsoft Gaming',      '2025-01-10', '2025-02-28',  150000.00, 'active',  'desktop,mobile',          'US,GB',          '2025-01-05 00:00:00'),
    (12, 'HyperX Cloud IV',                    9,  'AMD',                   '2025-01-01', '2025-02-15',  100000.00, 'active',  'desktop,mobile',          'US,GB,DE',       '2024-12-20 00:00:00'),
    (13, 'Hogwarts Legacy DLC',                6,  'Activision Blizzard',   '2025-01-15', '2025-02-28',  250000.00, 'active',  'desktop,mobile',          'US,GB,DE,FR',    '2025-01-10 00:00:00'),
    (14, 'GTA VI Pre-Order',                   4,  'Electronic Arts',       '2025-01-20', '2025-06-30', 1200000.00, 'active',  'desktop,mobile,ctv',      'US,GB,DE,FR,BR,JP,AU', '2025-01-15 00:00:00'),
    (15, 'Logitech G Pro X 2',                 10, 'NVIDIA',                '2025-01-01', '2025-01-31',  120000.00, 'active',  'desktop',                 'US,GB,DE',       '2024-12-28 00:00:00'),
    (16, 'Monster Hunter Wilds',               3,  'Nintendo',              '2025-01-08', '2025-02-28',  500000.00, 'active',  'desktop,mobile,tablet',   'US,GB,JP',       '2025-01-03 00:00:00'),
    (17, 'Corsair Vengeance RGB',              9,  'AMD',                   '2025-01-05', '2025-03-31',   80000.00, 'active',  'desktop',                 'US,GB,DE,CA',    '2024-12-30 00:00:00'),
    (18, 'Elden Ring Nightreign',              2,  'Sony Interactive',      '2025-01-12', '2025-03-15',  650000.00, 'active',  'desktop,mobile',          'US,GB,JP,DE',    '2025-01-08 00:00:00'),
    (19, 'SteelSeries Arctis Nova',            8,  'Valve',                 '2025-01-01', '2025-01-20',   90000.00, 'completed','desktop,mobile',         'US,GB',          '2024-12-22 00:00:00'),
    (20, 'Samsung Odyssey G9',                 5,  'Ubisoft',               '2025-01-10', '2025-04-30',  200000.00, 'active',  'desktop',                 'US,GB,DE,JP',    '2025-01-05 00:00:00'),
    (21, 'Alienware Aurora R16',               1,  'Microsoft Gaming',      '2025-01-15', '2025-03-31',  180000.00, 'active',  'desktop',                 'US,CA',          '2025-01-10 00:00:00'),
    (22, 'Twitch Subs Promo',                  7,  'Epic Games',            '2025-01-01', '2025-01-15',   60000.00, 'completed','desktop,mobile',         'US,GB,BR',       '2024-12-28 00:00:00'),
    (23, 'Discord Nitro Q1',                   7,  'Epic Games',            '2025-01-01', '2025-03-31',  150000.00, 'active',  'desktop,mobile',          'US,GB,DE',       '2024-12-30 00:00:00'),
    (24, 'CyberPower Gaming PC',               10, 'NVIDIA',                '2025-01-08', '2025-02-28',  100000.00, 'active',  'desktop',                 'US,CA',          '2025-01-03 00:00:00'),
    (25, 'Backbone One Controller',            2,  'Sony Interactive',      '2025-01-05', '2025-03-31',   75000.00, 'active',  'mobile',                  'US,GB',          '2024-12-30 00:00:00'),
    (26, 'MSI Claw Handheld',                  9,  'AMD',                   '2025-01-15', '2025-04-30',  110000.00, 'active',  'mobile,tablet',           'US,GB,JP',       '2025-01-10 00:00:00'),
    (27, 'Secretlab Titan',                    5,  'Ubisoft',               '2025-01-01', '2025-02-28',   95000.00, 'active',  'desktop,mobile',          'US,GB,AU',       '2024-12-25 00:00:00');

INSERT INTO raw.campaigns
SELECT
    campaign_id, campaign_name, advertiser_id, advertiser_name,
    campaign_start_date + toInt32(dateDiff('day', toDate('2025-01-31'), today())) AS campaign_start_date,
    campaign_end_date   + toInt32(dateDiff('day', toDate('2025-01-31'), today())) AS campaign_end_date,
    campaign_budget_usd, campaign_status, targeting_device_types, targeting_countries,
    created_at
FROM raw._stg_campaigns;

DROP TABLE raw._stg_campaigns;


-- -------------------------------------------------------------------------
-- raw.ad_units
-- -------------------------------------------------------------------------
CREATE TABLE raw.ad_units
(
    ad_unit_id      String,
    publisher_id    UInt32,
    ad_unit_name    String,
    ad_format       String,
    ad_size         String,
    placement_type  String,
    is_active       UInt8,
    created_at      DateTime
)
ENGINE = MergeTree()
ORDER BY (publisher_id, ad_unit_id);

INSERT INTO raw.ad_units VALUES
    ('au_1_1',  1,  'GameSpot Leaderboard',        'display', '728x90',  'above_fold', 1, '2023-02-01 00:00:00'),
    ('au_1_2',  1,  'GameSpot MPU',                'display', '300x250', 'in_content', 1, '2023-02-01 00:00:00'),
    ('au_1_3',  1,  'GameSpot Pre-roll',           'video',   '640x480', 'in_content', 1, '2023-03-15 00:00:00'),
    ('au_2_1',  2,  'IGN Top Banner',              'display', '728x90',  'above_fold', 1, '2023-03-01 00:00:00'),
    ('au_2_2',  2,  'IGN Sidebar',                 'display', '160x600', 'sidebar',    1, '2023-03-01 00:00:00'),
    ('au_2_3',  2,  'IGN Video Player',            'video',   '640x480', 'in_content', 1, '2023-04-15 00:00:00'),
    ('au_3_1',  3,  'Eurogamer Billboard',         'display', '970x250', 'above_fold', 1, '2023-04-10 00:00:00'),
    ('au_3_2',  3,  'Eurogamer Native',            'native',  'fluid',   'in_content', 1, '2023-04-10 00:00:00'),
    ('au_3_3',  3,  'Eurogamer Pre-roll',          'video',   '640x480', 'in_content', 1, '2023-05-20 00:00:00'),
    ('au_4_1',  4,  'RPS Leaderboard',             'display', '728x90',  'above_fold', 1, '2023-05-05 00:00:00'),
    ('au_4_2',  4,  'RPS Rectangle',               'display', '300x250', 'below_fold', 1, '2023-05-05 00:00:00'),
    ('au_4_3',  4,  'RPS Outstream',               'video',   '640x480', 'in_content', 1, '2023-06-15 00:00:00'),
    ('au_5_1',  5,  'Polygon Hero Banner',         'display', '970x250', 'above_fold', 1, '2023-06-20 00:00:00'),
    ('au_5_2',  5,  'Polygon In-article',          'native',  'fluid',   'in_content', 1, '2023-06-20 00:00:00'),
    ('au_5_3',  5,  'Polygon Sidebar MPU',         'display', '300x250', 'sidebar',    0, '2023-07-10 00:00:00'),
    ('au_6_1',  6,  'Kotaku Leaderboard',          'display', '728x90',  'above_fold', 1, '2023-07-12 00:00:00'),
    ('au_6_2',  6,  'Kotaku Mobile Banner',        'display', '320x50',  'above_fold', 1, '2023-07-12 00:00:00'),
    ('au_6_3',  6,  'Kotaku Native Feed',          'native',  'fluid',   'in_content', 1, '2023-08-20 00:00:00'),
    ('au_7_1',  7,  'PCG Masthead',                'display', '970x90',  'above_fold', 1, '2023-08-01 00:00:00'),
    ('au_7_2',  7,  'PCG In-content',              'display', '300x250', 'in_content', 1, '2023-08-01 00:00:00'),
    ('au_7_3',  7,  'PCG Video Interstitial',      'video',   '640x480', 'in_content', 1, '2023-09-15 00:00:00'),
    ('au_8_1',  8,  'GR Leaderboard',              'display', '728x90',  'above_fold', 1, '2023-09-15 00:00:00'),
    ('au_8_2',  8,  'GR Sticky Footer',            'display', '320x50',  'below_fold', 1, '2023-09-15 00:00:00'),
    ('au_8_3',  8,  'GR Pre-roll',                 'video',   '640x480', 'in_content', 1, '2023-10-20 00:00:00'),
    ('au_9_1',  9,  'VG247 Billboard',             'display', '970x250', 'above_fold', 1, '2023-10-01 00:00:00'),
    ('au_9_2',  9,  'VG247 MPU',                   'display', '300x250', 'in_content', 1, '2023-10-01 00:00:00'),
    ('au_9_3',  9,  'VG247 Native',                'native',  'fluid',   'in_content', 1, '2023-11-10 00:00:00'),
    ('au_10_1', 10, 'Destructoid Banner',          'display', '728x90',  'above_fold', 1, '2023-11-10 00:00:00'),
    ('au_10_2', 10, 'Destructoid Sidebar',         'display', '160x600', 'sidebar',    1, '2023-11-10 00:00:00'),
    ('au_10_3', 10, 'Destructoid Outstream',       'video',   '640x480', 'in_content', 1, '2023-12-15 00:00:00'),
    ('au_11_1', 11, 'TheGamer Hero',               'display', '970x250', 'above_fold', 1, '2023-12-05 00:00:00'),
    ('au_11_2', 11, 'TheGamer In-article',         'native',  'fluid',   'in_content', 1, '2023-12-05 00:00:00'),
    ('au_11_3', 11, 'TheGamer Video',              'video',   '640x480', 'in_content', 1, '2024-01-15 00:00:00'),
    ('au_12_1', 12, 'ScreenRant Top Banner',       'display', '728x90',  'above_fold', 1, '2024-01-01 00:00:00'),
    ('au_12_2', 12, 'ScreenRant Mobile MPU',       'display', '300x250', 'in_content', 1, '2024-01-01 00:00:00'),
    ('au_12_3', 12, 'ScreenRant Pre-roll',         'video',   '640x480', 'in_content', 1, '2024-02-10 00:00:00'),
    ('au_13_1', 13, 'GameRant Leaderboard',        'display', '728x90',  'above_fold', 1, '2024-02-15 00:00:00'),
    ('au_13_2', 13, 'GameRant Sticky',             'display', '320x50',  'below_fold', 1, '2024-02-15 00:00:00'),
    ('au_13_3', 13, 'GameRant Native',             'native',  'fluid',   'in_content', 1, '2024-03-20 00:00:00'),
    ('au_14_1', 14, 'DualShockers Banner',         'display', '728x90',  'above_fold', 1, '2024-03-01 00:00:00'),
    ('au_14_2', 14, 'DualShockers In-content',     'display', '300x250', 'in_content', 1, '2024-03-01 00:00:00'),
    ('au_14_3', 14, 'DualShockers Video',          'video',   '640x480', 'in_content', 1, '2024-04-10 00:00:00'),
    ('au_15_1', 15, 'AOTF Masthead',               'display', '970x90',  'above_fold', 1, '2024-04-10 00:00:00'),
    ('au_15_2', 15, 'AOTF MPU',                    'display', '300x250', 'below_fold', 1, '2024-04-10 00:00:00'),
    ('au_15_3', 15, 'AOTF Outstream',              'video',   '640x480', 'in_content', 1, '2024-05-15 00:00:00'),
    ('au_16_1', 16, 'GameInformer Billboard',      'display', '970x250', 'above_fold', 1, '2024-05-05 00:00:00'),
    ('au_16_2', 16, 'GameInformer Native',         'native',  'fluid',   'in_content', 1, '2024-05-05 00:00:00'),
    ('au_16_3', 16, 'GameInformer Pre-roll',       'video',   '640x480', 'in_content', 1, '2024-06-10 00:00:00'),
    ('au_17_1', 17, 'PushSquare Leaderboard',      'display', '728x90',  'above_fold', 1, '2024-06-20 00:00:00'),
    ('au_17_2', 17, 'PushSquare Mobile',           'display', '320x50',  'above_fold', 1, '2024-06-20 00:00:00'),
    ('au_17_3', 17, 'PushSquare Video',            'video',   '640x480', 'in_content', 1, '2024-07-15 00:00:00'),
    ('au_18_1', 18, 'NintendoLife Banner',         'display', '728x90',  'above_fold', 1, '2024-07-12 00:00:00'),
    ('au_18_2', 18, 'NintendoLife Sidebar',        'display', '160x600', 'sidebar',    1, '2024-07-12 00:00:00'),
    ('au_18_3', 18, 'NintendoLife Native',         'native',  'fluid',   'in_content', 1, '2024-08-15 00:00:00'),
    ('au_19_1', 19, 'TouchArcade Top',             'display', '320x50',  'above_fold', 1, '2024-08-01 00:00:00'),
    ('au_19_2', 19, 'TouchArcade Interstitial',    'display', '320x480', 'in_content', 1, '2024-08-01 00:00:00'),
    ('au_19_3', 19, 'TouchArcade Rewarded',        'video',   '640x480', 'in_content', 1, '2024-09-10 00:00:00'),
    ('au_20_1', 20, 'PocketGamer Leaderboard',     'display', '728x90',  'above_fold', 1, '2024-09-15 00:00:00'),
    ('au_20_2', 20, 'PocketGamer Mobile MPU',      'display', '300x250', 'in_content', 1, '2024-09-15 00:00:00'),
    ('au_20_3', 20, 'PocketGamer Pre-roll',        'video',   '640x480', 'in_content', 1, '2024-10-20 00:00:00');


-- -------------------------------------------------------------------------
-- raw.ad_events
-- Source: ad_server_events_v2 | Load schedule: daily batch
-- Data window: last 30 days
-- -------------------------------------------------------------------------
CREATE TABLE raw.ad_events
(
    event_id          String,
    event_type        String,
    event_timestamp   DateTime64(3),
    publisher_id      UInt32,
    site_domain       String,
    ad_unit_id        String,
    campaign_id       Nullable(UInt32),
    advertiser_id     Nullable(UInt32),
    device_type       String,
    country_code      String,
    browser           String,
    revenue_usd       Decimal64(6),
    bid_floor_usd     Decimal64(6),
    is_filled         UInt8,
    _loaded_at        DateTime
)
ENGINE = MergeTree()
ORDER BY (event_timestamp, publisher_id);


-- Load: primary event extract
INSERT INTO raw.ad_events
SELECT
    event_id,
    event_type,
    event_timestamp,
    publisher_id,
    arrayElement(
        ['gamespot.com','ign.com','eurogamer.net','rockpapershotgun.com','polygon.com',
         'kotaku.com','pcgamer.com','gamesradar.com','vg247.com','destructoid.com',
         'thegamer.com','screenrant.com','gamerant.com','dualshockers.com','attackofthefanboy.com',
         'gameinformer.com','pushsquare.com','nintendolife.com','toucharcade.com','pocketgamer.com'],
        publisher_id
    ) AS site_domain,
    concat('au_', toString(publisher_id), '_', toString(au_idx)) AS ad_unit_id,
    CASE WHEN fill_rnd < 15 THEN CAST(NULL AS Nullable(UInt32))
         ELSE CAST(camp_idx AS Nullable(UInt32)) END AS campaign_id,
    CASE WHEN fill_rnd < 15 THEN CAST(NULL AS Nullable(UInt32))
         ELSE CAST(1 + ((camp_idx - 1) % 10) AS Nullable(UInt32)) END AS advertiser_id,
    device_type,
    country_code,
    browser,
    CASE
        WHEN fill_rnd < 15 THEN toDecimal64(0, 6)
        WHEN event_type = 'click' THEN toDecimal64(0.50 + (toFloat64(rev_rnd) / 100.0), 6)
        WHEN event_type = 'viewable_impression' THEN toDecimal64(0.010 + (toFloat64(rev_rnd % 30) / 1000.0), 6)
        ELSE toDecimal64(0.002 + (toFloat64(rev_rnd % 15) / 1000.0), 6)
    END AS revenue_usd,
    toDecimal64(0.001 + (toFloat64(floor_rnd) / 10000.0), 6) AS bid_floor_usd,
    CASE WHEN fill_rnd < 15 THEN toUInt8(0) ELSE toUInt8(1) END AS is_filled,
    toDateTime(today()) + 21600 AS _loaded_at
FROM (
    SELECT
        toString(generateUUIDv4()) AS event_id,
        arrayElement(
            ['impression','impression','impression','impression','impression',
             'impression','impression','viewable_impression','viewable_impression','click'],
            1 + (rand() % 10)
        ) AS event_type,
        toDateTime64(toDateTime(today() - 30), 3)
            + toInt64(rand() % toUInt32(30 * 86400))
            + (toFloat64(rand() % 1000) / 1000.0)
        AS event_timestamp,
        arrayElement(
            [1,1,1,1, 2,2,2,2, 3,3,3, 4,4, 5,5,5, 6,6, 7,7,7, 8,8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20],
            1 + (rand() % 34)
        ) AS publisher_id,
        1 + (rand() % 3) AS au_idx,
        rand() % 100 AS fill_rnd,
        1 + (rand() % 27) AS camp_idx,
        arrayElement(
            ['desktop','desktop','desktop','mobile','mobile','mobile','mobile','tablet','ctv'],
            1 + (rand() % 9)
        ) AS device_type,
        arrayElement(
            ['US','US','US','US','GB','GB','DE','FR','CA','AU','JP','BR','IN','MX'],
            1 + (rand() % 14)
        ) AS country_code,
        arrayElement(
            ['Chrome','Chrome','Chrome','Safari','Safari','Firefox','Edge','Samsung Internet'],
            1 + (rand() % 8)
        ) AS browser,
        rand() % 500 AS rev_rnd,
        rand() % 50  AS floor_rnd
    FROM numbers(120000)
) AS base;


-- Load: supplemental pipeline segments (backfills, late-arriving partitions, corrections)
INSERT INTO raw.ad_events
SELECT
    event_id, event_type, event_timestamp, publisher_id, site_domain,
    ad_unit_id, campaign_id, advertiser_id, device_type, country_code,
    browser, revenue_usd, bid_floor_usd, is_filled, _loaded_at
FROM (
    SELECT
        toString(generateUUIDv4()) AS event_id,
        arrayElement(['impression','impression','impression','viewable_impression','click'], 1 + (rand() % 5)) AS event_type,
        toDateTime64(toDateTime(today() - 30), 3) + toInt64(rand() % toUInt32(30 * 86400)) AS event_timestamp,
        arrayElement([1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20], 1 + (rand() % 20)) AS publisher_id,
        arrayElement(
            ['gamespot.com','ign.com','eurogamer.net','rockpapershotgun.com','polygon.com',
             'kotaku.com','pcgamer.com','gamesradar.com','vg247.com','destructoid.com',
             'thegamer.com','screenrant.com','gamerant.com','dualshockers.com','attackofthefanboy.com',
             'gameinformer.com','pushsquare.com','nintendolife.com','toucharcade.com','pocketgamer.com'],
            arrayElement([1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20], 1 + (rand() % 20))
        ) AS site_domain,
        concat('au_', toString(arrayElement([1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20], 1 + (rand() % 20))), '_', toString(1 + (rand() % 3))) AS ad_unit_id,
        CAST(1 + (rand() % 27) AS Nullable(UInt32)) AS campaign_id,
        CAST(1 + (rand() % 10) AS Nullable(UInt32)) AS advertiser_id,
        arrayElement(['desktop','mobile','mobile','tablet'], 1 + (rand() % 4)) AS device_type,
        arrayElement(['us','gb','de','fr','ca','au','jp','br','Us','Gb'], 1 + (rand() % 10)) AS country_code,
        arrayElement(['Chrome','Safari','Firefox'], 1 + (rand() % 3)) AS browser,
        toDecimal64(0.002 + (toFloat64(rand() % 15) / 1000.0), 6) AS revenue_usd,
        toDecimal64(0.001 + (toFloat64(rand() % 50) / 10000.0), 6) AS bid_floor_usd,
        toUInt8(1) AS is_filled,
        toDateTime(today()) + 21600 AS _loaded_at
    FROM numbers(3000)

    UNION ALL

    SELECT
        toString(generateUUIDv4()),
        arrayElement(['impression','impression','impression','viewable_impression','click'], 1 + (rand() % 5)),
        toDateTime64(toDateTime(today() + 1), 3) + toInt64(rand() % toUInt32(7 * 86400)),
        arrayElement([1,2,3,5,7,10,13], 1 + (rand() % 7)),
        arrayElement(['gamespot.com','ign.com','eurogamer.net','polygon.com','pcgamer.com','destructoid.com','gamerant.com'], 1 + (rand() % 7)),
        concat('au_', toString(arrayElement([1,2,3,5,7,10,13], 1 + (rand() % 7))), '_1'),
        CAST(1 + (rand() % 27) AS Nullable(UInt32)),
        CAST(1 + (rand() % 10) AS Nullable(UInt32)),
        arrayElement(['desktop','mobile','mobile'], 1 + (rand() % 3)),
        arrayElement(['US','GB','DE'], 1 + (rand() % 3)),
        'Chrome',
        toDecimal64(0.003 + (toFloat64(rand() % 15) / 1000.0), 6),
        toDecimal64(0.002, 6),
        toUInt8(1),
        toDateTime(today() + 8) + 21600
    FROM numbers(400)

    UNION ALL

    SELECT
        toString(generateUUIDv4()),
        'impression',
        toDateTime64(toDateTime(today() - 26), 3) + toInt64(rand() % toUInt32(20 * 86400)),
        arrayElement([1,2,3,5,7,13], 1 + (rand() % 6)),
        arrayElement(['gamespot.com','ign.com','eurogamer.net','polygon.com','pcgamer.com','gamerant.com'], 1 + (rand() % 6)),
        concat('au_', toString(arrayElement([1,2,3,5,7,13], 1 + (rand() % 6))), '_1'),
        CAST(1 + (rand() % 10) AS Nullable(UInt32)),
        CAST(1 + (rand() % 10) AS Nullable(UInt32)),
        'desktop',
        'US',
        'Chrome',
        toDecimal64(-1.0 * (0.50 + (toFloat64(rand() % 200) / 100.0)), 6),
        toDecimal64(0.002, 6),
        toUInt8(1),
        toDateTime(today()) + 21600
    FROM numbers(150)

    UNION ALL

    SELECT
        toString(generateUUIDv4()),
        arrayElement(['impression','impression','viewable_impression','click'], 1 + (rand() % 4)),
        toDateTime64(toDateTime(today() - 21), 3) + toInt64(rand() % toUInt32(15 * 86400)),
        arrayElement([2,5,8,11,14,17,20], 1 + (rand() % 7)),
        arrayElement(['ign.com','polygon.com','gamesradar.com','thegamer.com','dualshockers.com','pushsquare.com','pocketgamer.com'], 1 + (rand() % 7)),
        concat('au_', toString(arrayElement([2,5,8,11,14,17,20], 1 + (rand() % 7))), '_2'),
        CAST(27 + (1 + (rand() % 3)) AS Nullable(UInt32)),
        CAST(11 + (rand() % 3) AS Nullable(UInt32)),
        arrayElement(['desktop','mobile'], 1 + (rand() % 2)),
        'US',
        'Chrome',
        toDecimal64(0.003 + (toFloat64(rand() % 20) / 1000.0), 6),
        toDecimal64(0.002, 6),
        toUInt8(1),
        toDateTime(today()) + 21600
    FROM numbers(300)

    UNION ALL

    SELECT
        toString(generateUUIDv4()),
        arrayElement(['impression','impression','impression','impression','impression',
                      'impression','impression','impression','viewable_impression','click'],
                      1 + (rand() % 10)),
        toDateTime64(toDateTime(today() - 16), 3) + toInt64(2 * 3600) + toInt64(rand() % toUInt32(4 * 3600)),
        toUInt32(13),
        'gamerant.com',
        arrayElement(['au_13_1','au_13_1','au_13_2'], 1 + (rand() % 3)),
        CAST(arrayElement([6,7,14], 1 + (rand() % 3)) AS Nullable(UInt32)),
        CAST(arrayElement([6,7,4], 1 + (rand() % 3)) AS Nullable(UInt32)),
        'mobile',
        'BR',
        'Samsung Internet',
        toDecimal64(0.002 + (toFloat64(rand() % 8) / 1000.0), 6),
        toDecimal64(0.001, 6),
        toUInt8(1),
        toDateTime(today()) + 21600
    FROM numbers(5000)

    UNION ALL

    SELECT
        toString(generateUUIDv4()),
        'impression',
        toDateTime64(toDateTime(today() - 9), 3) + toInt64(rand() % toUInt32(5 * 86400)),
        arrayElement([1,3,5,10], 1 + (rand() % 4)),
        arrayElement(['gamespot.com','eurogamer.net','polygon.com','destructoid.com'], 1 + (rand() % 4)),
        concat('au_', toString(arrayElement([1,3,5,10], 1 + (rand() % 4))), '_1'),
        CAST(arrayElement([8, 19], 1 + (rand() % 2)) AS Nullable(UInt32)),
        CAST(arrayElement([8, 8], 1 + (rand() % 2)) AS Nullable(UInt32)),
        'desktop',
        'US',
        'Chrome',
        toDecimal64(0.003, 6),
        toDecimal64(0.002, 6),
        toUInt8(1),
        toDateTime(today()) + 21600
    FROM numbers(200)
) AS staged;


-- Load: reprocessed segments (pipeline delivery retry)
INSERT INTO raw.ad_events
SELECT
    event_id,
    event_type,
    event_timestamp,
    publisher_id,
    site_domain,
    ad_unit_id,
    campaign_id,
    advertiser_id,
    device_type,
    country_code,
    browser,
    revenue_usd,
    bid_floor_usd,
    is_filled,
    toDateTime(today()) + 43200 AS _loaded_at
FROM raw.ad_events
ORDER BY rand()
LIMIT 2000;
