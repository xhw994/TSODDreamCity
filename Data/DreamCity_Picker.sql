-- 城邦挑选界面里的条目。Domain 决定它在哪个规则集下出现；
-- Expansion2CityStates = 风云变幻。Bonus 列直接指向宗主国能力的描述 LOC。
INSERT OR REPLACE INTO CityStates (Domain, CivilizationType, CityStateCategory, Name, Icon, Bonus) VALUES
    ('Expansion2CityStates',
     'CIVILIZATION_TSOD_DREAM_CITY',
     'CULTURAL',
     'LOC_CIVILIZATION_TSOD_DREAM_CITY_NAME',
     'ICON_CIVILIZATION_TSOD_DREAM_CITY',
     'LOC_TRAIT_TSOD_NARRATOR_NETWORK_DESCRIPTION');
