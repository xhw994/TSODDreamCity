-- 复用官方文化城邦的配色，跟原版文化城邦在小地图和外交界面上完全一致。
INSERT OR REPLACE INTO PlayerColors (Type, Usage, PrimaryColor, SecondaryColor) VALUES
    ('CIVILIZATION_TSOD_DREAM_CITY', 'Minor',
     'COLOR_PLAYER_CITY_STATE_PRIMARY',
     'COLOR_PLAYER_CITY_STATE_CULTURAL_SECONDARY');
