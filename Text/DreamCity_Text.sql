-- =============================================================
-- 梦境之城 —— 文本（英文 / 简体中文）
-- 面向玩家的字符串一律走 LOC tag，不在数据表里写死字面量。
-- =============================================================

INSERT OR REPLACE INTO LocalizedText (Tag, Language, Text) VALUES
    ('LOC_CIVILIZATION_TSOD_DREAM_CITY_NAME', 'en_US', 'Dream City'),
    ('LOC_CIVILIZATION_TSOD_DREAM_CITY_NAME', 'zh_Hans_CN', '梦境之城'),
    ('LOC_CIVILIZATION_TSOD_DREAM_CITY_DESCRIPTION', 'en_US', 'City-State of Dream City'),
    ('LOC_CIVILIZATION_TSOD_DREAM_CITY_DESCRIPTION', 'zh_Hans_CN', '梦境之城城邦'),
    ('LOC_CIVILIZATION_TSOD_DREAM_CITY_ADJECTIVE', 'en_US', 'Dream City'),
    ('LOC_CIVILIZATION_TSOD_DREAM_CITY_ADJECTIVE', 'zh_Hans_CN', '梦境之城的'),
    ('LOC_CITY_NAME_TSOD_DREAM_CITY', 'en_US', 'Dream City'),
    ('LOC_CITY_NAME_TSOD_DREAM_CITY', 'zh_Hans_CN', '梦境之城'),
    ('LOC_TRAIT_TSOD_NARRATOR_NETWORK_NAME', 'en_US', 'Narrator Neural Network'),
    ('LOC_TRAIT_TSOD_NARRATOR_NETWORK_NAME', 'zh_Hans_CN', '叙事者神经网络'),
    ('LOC_TRAIT_TSOD_NARRATOR_NETWORK_DESCRIPTION', 'en_US', '[ICON_TechBoosted] Eurekas and [ICON_CivicBoosted] Inspirations provide an additional 10% of technology and civic costs. Each district in your cities provides +1 [ICON_Amenities] Amenity.'),
    ('LOC_TRAIT_TSOD_NARRATOR_NETWORK_DESCRIPTION', 'zh_Hans_CN', '[ICON_TechBoosted]尤里卡和 [ICON_CivicBoosted]鼓舞额外提供10%的科技与市政开销。你的城市中每个区域+1 [ICON_Amenities] 宜居度。'),
    ('LOC_PEDIA_CITYSTATES_PAGE_CIVILIZATION_TSOD_DREAM_CITY_CHAPTER_HISTORY_PARA_1', 'en_US', 'A city that existed inside a sandbox, watched over by a god its people called the High Narrator - a vast spider whose threads ran through every mind in the city. When the city itself was destroyed, the threads remained: what had been a place became the Narrator Neural Network, a full-dive world where thought moves faster than the flesh that once carried it. Those who plug in do not merely learn - they remember having always known.'),
    ('LOC_PEDIA_CITYSTATES_PAGE_CIVILIZATION_TSOD_DREAM_CITY_CHAPTER_HISTORY_PARA_1', 'zh_Hans_CN', '沙箱之中的城邦，其上有一位被居民称作「上层叙事者」的神明——一只巨大的蜘蛛，它的丝线穿过城中每一颗心智。城邦本身毁灭之后，丝线却留了下来：曾经的地方成了「叙事者神经网络」，一个思维快过血肉的完全潜行世界。接入其中的人并非在学习，而是想起自己本就知晓。');
