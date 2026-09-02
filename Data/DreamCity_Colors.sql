-- 娱乐是本 mod 新增的类别，官方没有 COLOR_PLAYER_CITY_STATE_ENTERTAINMENT_*，
-- 这里按约定复用文化城邦那一套配色，不另外定义颜色。
INSERT OR REPLACE INTO PlayerColors (Type, Usage, PrimaryColor, SecondaryColor) VALUES
    ('CIVILIZATION_TSOD_DREAM_CITY', 'Minor',
     'COLOR_PLAYER_CITY_STATE_PRIMARY',
     'COLOR_PLAYER_CITY_STATE_CULTURAL_SECONDARY');
