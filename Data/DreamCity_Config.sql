-- =============================================================
-- 前端（配置数据库）：让梦境之城出现在开局设置的城邦列表里
-- 结构照工坊 mod「鸣潮：团子城邦」(3731341913) 的 Config + Picker。
-- =============================================================

-- 开局设置 → 地图选项里的一个开关，勾上就把这个城邦放进本局。
INSERT OR REPLACE INTO Parameters
    (ParameterId, Name, Description, Domain, DefaultValue, ConfigurationGroup, ConfigurationId, GroupId, SortIndex)
VALUES
    ('LEADER_MINOR_CIV_TSOD_DREAM_CITY',
     'LOC_CIVILIZATION_TSOD_DREAM_CITY_NAME',
     'LOC_CIVILIZATION_TSOD_DREAM_CITY_DESCRIPTION',
     'bool', 0, 'Map', 'LEADER_MINOR_CIV_TSOD_DREAM_CITY', 'MapOptions', 1300);

-- 只有在「手动挑选城邦」时这个开关才有意义。
INSERT OR REPLACE INTO ParameterDependencies
    (ParameterId, ConfigurationGroup, ConfigurationId, Operator, ConfigurationValue)
VALUES
    ('LEADER_MINOR_CIV_TSOD_DREAM_CITY', 'Map', 'SelectCityStates', 'Equals', 1);
