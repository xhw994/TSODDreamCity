-- =============================================================
-- 兼容：CIVITAS City-States（工坊 1331757859，GUID 7d0b57ba-…）
--
-- 装了 CIVITAS 时，文明百科的城邦页由它的 CivilopediaPage_CityState.lua 接管。
-- 它把官方那张硬编码的类别表改成了数据库驱动 —— 正好对上官方自己留的那句
-- "Should be database-driven, but presently is not."：
--
--     local tCityStateTypes = {}
--     for row in GameInfo.CSE_ClassTypes() do
--         tCityStateTypes[row.Type] = { TypeName=…, LeaderType=…, TypeIcon=… }
--     end
--     …
--     for k, v in pairs(tCityStateTypes) do
--         types[v.LeaderType] = { v.TypeIcon, v.TypeName, v.SecondaryColor }
--     end
--
-- 也就是说它按 LeaderType 重新索引，再跟这个城邦的领袖继承链比对。
-- 所以往 CSE_ClassTypes 插一行、LeaderType 填我们的类别领袖，百科页就认得了。
-- 不需要替换任何 UI 文件，也不会和它抢 LuaContext。
--
-- 本文件只在 CIVITAS 启用时加载（.modinfo 里的 ModInUse criteria），
-- 否则 CSE_ClassTypes 这张表根本不存在。LoadOrder 需大于 20，
-- 这是 CIVITAS 自己在 Core/CSE_ModSupport_Guide.sql 里写的要求。
--
-- 列的填法照它 Core/Framework/CSE_Master.sql 里自己那几行；
-- Color 是 RGBA 字符串，用本 mod 那个琥珀金，和 PlayerColors 里保持一致。
-- =============================================================

INSERT INTO CSE_ClassTypes
    (Type,                  New,  LeaderType,
     TypeName,                              Color,
     BonusIcon,                             TypeIcon,
     TraitType,                             TraitDescription)
VALUES
    ('TSOD_ENTERTAINMENT',  1,    'LEADER_MINOR_CIV_ENTERTAINMENT',
     'LOC_CITY_STATES_TYPE_ENTERTAINMENT',  '245,190,55,255',
     'ICON_ENVOY_BONUS_CULTURE',            'ICON_CITYSTATE_CULTURE',
     'MINOR_CIV_ENTERTAINMENT_TRAIT',       'LOC_MINOR_CIV_ENTERTAINMENT_TRAIT_DESCRIPTION');
