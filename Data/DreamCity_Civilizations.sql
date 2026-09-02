-- =============================================================
-- 梦境之城 / Dream City —— 城邦骨架
-- 结构照原版文化城邦 CIVILIZATION_NAN_MADOL 抄，命名沿用官方惯例：
--   城邦本体   CIVILIZATION_*
--   城邦领袖   LEADER_MINOR_CIV_*   （InheritFrom 决定 1/3/6 使者的类别加成）
--   宗主国能力 MINOR_CIV_*_TRAIT
-- =============================================================

INSERT OR REPLACE INTO Types (Type, Kind) VALUES
    ('CIVILIZATION_TSOD_DREAM_CITY',     'KIND_CIVILIZATION'),
    ('LEADER_MINOR_CIV_TSOD_DREAM_CITY', 'KIND_LEADER'),
    ('MINOR_CIV_TSOD_DREAM_CITY_TRAIT',  'KIND_TRAIT');


INSERT OR REPLACE INTO Civilizations
    (CivilizationType, Name, Description, Adjective, StartingCivilizationLevelType, RandomCityNameDepth)
VALUES
    ('CIVILIZATION_TSOD_DREAM_CITY',
     'LOC_CIVILIZATION_TSOD_DREAM_CITY_NAME',
     'LOC_CIVILIZATION_TSOD_DREAM_CITY_DESCRIPTION',
     'LOC_CIVILIZATION_TSOD_DREAM_CITY_ADJECTIVE',
     'CIVILIZATION_LEVEL_CITY_STATE',
     1);


-- 城邦类别。决定使者加成走哪一套、地图上用哪个类别图标。
INSERT OR REPLACE INTO TypeProperties (Type, Name, Value) VALUES
    ('CIVILIZATION_TSOD_DREAM_CITY', 'CityStateCategory', 'CULTURAL');


INSERT OR REPLACE INTO CivilizationLeaders (CivilizationType, LeaderType, CapitalName) VALUES
    ('CIVILIZATION_TSOD_DREAM_CITY', 'LEADER_MINOR_CIV_TSOD_DREAM_CITY', 'LOC_CITY_NAME_TSOD_DREAM_CITY');


INSERT OR REPLACE INTO CityNames (CivilizationType, CityName) VALUES
    ('CIVILIZATION_TSOD_DREAM_CITY', 'LOC_CITY_NAME_TSOD_DREAM_CITY');


-- Name 用城邦名而不是「上层叙事者」：原版 31 个城邦领袖无一例外都这么写，
-- 界面上出现的也是城邦名。上层叙事者的名字放在能力描述里。
-- InheritFrom 带来文化城邦的 1/3/6 使者加成，本 mod 只需再写宗主国独有能力。
INSERT OR REPLACE INTO Leaders (LeaderType, Name, InheritFrom) VALUES
    ('LEADER_MINOR_CIV_TSOD_DREAM_CITY',
     'LOC_CIVILIZATION_TSOD_DREAM_CITY_NAME',
     'LEADER_MINOR_CIV_CULTURAL');


INSERT OR REPLACE INTO LeaderTraits (LeaderType, TraitType) VALUES
    ('LEADER_MINOR_CIV_TSOD_DREAM_CITY', 'MINOR_CIV_TSOD_DREAM_CITY_TRAIT');


INSERT OR REPLACE INTO Traits (TraitType, Name, Description) VALUES
    ('MINOR_CIV_TSOD_DREAM_CITY_TRAIT',
     'LOC_TRAIT_TSOD_NARRATOR_NETWORK_NAME',
     'LOC_TRAIT_TSOD_NARRATOR_NETWORK_DESCRIPTION');
