-- 娱乐是本 mod 新增的类别，官方没有对应的 COLOR_PLAYER_CITY_STATE_*，
-- 之前借用了文化城邦的品红（COLOR_STANDARD_MAGENTA_MD）——所以游戏里看着是紫的。
--
-- 改成琥珀金，取娱乐中心的色调。刻意避开这两个现成色：
--   贸易城邦 COLOR_STANDARD_YELLOW_MD = 247,216,1   （柠檬黄，商业中心那个）
--   工业城邦 COLOR_STANDARD_ORANGE_MD = 255,129,18  （橙）
-- 245,190,55 比贸易黄更暖更沉，又比工业橙亮得多、黄得多，三者不会认混。
INSERT OR REPLACE INTO Colors (Type, Color) VALUES
    ('COLOR_TSOD_CITY_STATE_ENTERTAINMENT_SECONDARY', '245,190,55,255');

INSERT OR REPLACE INTO PlayerColors (Type, Usage, PrimaryColor, SecondaryColor) VALUES
    ('CIVILIZATION_TSOD_DREAM_CITY', 'Minor',
     'COLOR_PLAYER_CITY_STATE_PRIMARY',
     'COLOR_TSOD_CITY_STATE_ENTERTAINMENT_SECONDARY');
