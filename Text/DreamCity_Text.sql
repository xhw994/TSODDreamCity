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


-- ===== 新增城邦类别：娱乐城邦 =====
-- 三档描述沿用官方六个类别的句式，并直接嵌套引用本体的
-- 本体那三个「派遣 N 位使者：」的 tag，这样档位那半句自动跟随游戏语言。
INSERT OR REPLACE INTO LocalizedText (Tag, Language, Text) VALUES
    ('LOC_MINOR_CIV_ENTERTAINMENT_TRAIT_NAME', 'en_US', 'Entertainment City-State'),
    ('LOC_MINOR_CIV_ENTERTAINMENT_TRAIT_NAME', 'zh_Hans_CN', '娱乐城邦'),
    ('LOC_MINOR_CIV_ENTERTAINMENT_TRAIT_DESCRIPTION', 'en_US', '{LOC_MINOR_CIV_SMALL_INFLUENCE_ENVOYS} {LOC_MINOR_CIV_ENTERTAINMENT_TRAIT_SMALL_INFLUENCE_BONUS}[NEWLINE]{LOC_MINOR_CIV_MEDIUM_INFLUENCE_ENVOYS} {LOC_MINOR_CIV_ENTERTAINMENT_TRAIT_MEDIUM_INFLUENCE_BONUS}[NEWLINE]{LOC_MINOR_CIV_LARGE_INFLUENCE_ENVOYS} {LOC_MINOR_CIV_ENTERTAINMENT_TRAIT_LARGE_INFLUENCE_BONUS} {LOC_MINOR_CIV_ENTERTAINMENT_TRAIT_LARGE_INFLUENCE_BONUS_TIER3}'),
    ('LOC_MINOR_CIV_ENTERTAINMENT_TRAIT_DESCRIPTION', 'zh_Hans_CN', '{LOC_MINOR_CIV_SMALL_INFLUENCE_ENVOYS} {LOC_MINOR_CIV_ENTERTAINMENT_TRAIT_SMALL_INFLUENCE_BONUS}[NEWLINE]{LOC_MINOR_CIV_MEDIUM_INFLUENCE_ENVOYS} {LOC_MINOR_CIV_ENTERTAINMENT_TRAIT_MEDIUM_INFLUENCE_BONUS}[NEWLINE]{LOC_MINOR_CIV_LARGE_INFLUENCE_ENVOYS} {LOC_MINOR_CIV_ENTERTAINMENT_TRAIT_LARGE_INFLUENCE_BONUS} {LOC_MINOR_CIV_ENTERTAINMENT_TRAIT_LARGE_INFLUENCE_BONUS_TIER3}'),
    ('LOC_MINOR_CIV_ENTERTAINMENT_TRAIT_SMALL_INFLUENCE_BONUS', 'en_US', '+1 [ICON_Amenities] Amenity in the [ICON_Capital] Capital.'),
    ('LOC_MINOR_CIV_ENTERTAINMENT_TRAIT_SMALL_INFLUENCE_BONUS', 'zh_Hans_CN', '[ICON_Capital] 首都+1 [ICON_Amenities] 宜居度。'),
    ('LOC_MINOR_CIV_ENTERTAINMENT_TRAIT_MEDIUM_INFLUENCE_BONUS', 'en_US', '+1 [ICON_Amenities] Amenity in each city with an Arena or Ferris Wheel.'),
    ('LOC_MINOR_CIV_ENTERTAINMENT_TRAIT_MEDIUM_INFLUENCE_BONUS', 'zh_Hans_CN', '拥有竞技场或摩天轮的城市+1 [ICON_Amenities] 宜居度。'),
    ('LOC_MINOR_CIV_ENTERTAINMENT_TRAIT_LARGE_INFLUENCE_BONUS', 'en_US', '+1 [ICON_Amenities] Amenity in each city with a Zoo or Aquarium.'),
    ('LOC_MINOR_CIV_ENTERTAINMENT_TRAIT_LARGE_INFLUENCE_BONUS', 'zh_Hans_CN', '拥有动物园或水族馆的城市+1 [ICON_Amenities] 宜居度。'),
    ('LOC_CITY_STATES_TYPE_ENTERTAINMENT', 'en_US', 'Entertainment'),
    ('LOC_CITY_STATES_TYPE_ENTERTAINMENT', 'zh_Hans_CN', '娱乐');

-- 6 使者档挂了两条 modifier，各自需要一句 Preview 文本。
INSERT OR REPLACE INTO LocalizedText (Tag, Language, Text) VALUES
    ('LOC_MINOR_CIV_ENTERTAINMENT_TRAIT_LARGE_INFLUENCE_BONUS_TIER3', 'en_US', 'Additional +1 [ICON_Amenities] Amenity in each city with a Stadium or Aquatics Center.'),
    ('LOC_MINOR_CIV_ENTERTAINMENT_TRAIT_LARGE_INFLUENCE_BONUS_TIER3', 'zh_Hans_CN', '拥有体育场或水上运动中心的城市额外+1 [ICON_Amenities] 宜居度。');

-- 百科分组名
INSERT OR REPLACE INTO LocalizedText (Tag, Language, Text) VALUES
    ('LOC_PEDIA_CITYSTATES_PAGEGROUP_ENTERTAINMENT_NAME', 'en_US', 'Entertainment City-States'),
    ('LOC_PEDIA_CITYSTATES_PAGEGROUP_ENTERTAINMENT_NAME', 'zh_Hans_CN', '娱乐');
