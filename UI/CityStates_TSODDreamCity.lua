-- ===========================================================================
--  城邦面板：让新增的娱乐城邦类别有图标、名字和 tooltip
--
--  官方 PartialScreens/CityStates.lua 把六个类别硬编码成了四条 if-elseif 链，
--  落到 else 会 UI.DataError 并返回空值。CivilopediaPage_CityState.lua 里官方
--  自己也留了注释 "Should be database-driven, but presently is not."，海事城邦
--  就是靠在那张表里加一行 KLUDGE 塞进去的。新增类别只能照办。
--
--  按社区约定写成「include 原文件 + 重定义」而不是整文件重写，
--  并配一个同 LoadOrder 的 ImportFiles，好让后来的 mod 能 include 本文件接力。
--
--  注意 kCityState.Type 不等于 TypeProperties 里的 CityStateCategory
--  （官方文化城邦在这里是 "CULTURE"，在数据库里是 "CULTURAL"），所以这里不去
--  猜娱乐城邦会被映射成什么字符串，而是反过来：**凡是官方六种之外的类型一律
--  当成本 mod 的娱乐城邦**。本 mod 只引入一个新类别，这样判断既安全又不会因为
--  映射规则不同而失效。
-- ===========================================================================

include("CityStates.lua")

local KNOWN_TYPES :table = {
    SCIENTIFIC   = true,
    RELIGIOUS    = true,
    TRADE        = true,
    CULTURE      = true,
    MILITARISTIC = true,
    INDUSTRIAL   = true,
};

-- 娱乐类别暂时复用文化类的图标资源；换成专属图标时只改这两行。
local ENTERTAINMENT_TYPE_ICON  :string = "ICON_CITYSTATE_CULTURE";
local ENTERTAINMENT_BONUS_ICON :string = "ICON_ENVOY_BONUS_CULTURE";
local ENTERTAINMENT_NAME       :string = "LOC_CITY_STATES_TYPE_ENTERTAINMENT";

local function IsEntertainment( kCityState:table )
    return kCityState ~= nil
       and kCityState.Type ~= nil
       and KNOWN_TYPES[kCityState.Type] == nil;
end


BASE_TSOD_GetTypeAtlasPieces = GetTypeAtlasPieces;
function GetTypeAtlasPieces( kCityState:table, size:number )
    if IsEntertainment(kCityState) then
        return IconManager:FindIconAtlas(ENTERTAINMENT_TYPE_ICON, size);
    end
    return BASE_TSOD_GetTypeAtlasPieces(kCityState, size);
end


BASE_TSOD_GetBonusIconAtlasPieces = GetBonusIconAtlasPieces;
function GetBonusIconAtlasPieces( kCityState:table, size:number )
    if IsEntertainment(kCityState) then
        return IconManager:FindIconAtlas(ENTERTAINMENT_BONUS_ICON, size);
    end
    return BASE_TSOD_GetBonusIconAtlasPieces(kCityState, size);
end


BASE_TSOD_GetTypeTooltip = GetTypeTooltip;
function GetTypeTooltip( kCityState:table )
    if IsEntertainment(kCityState) then
        return ENTERTAINMENT_NAME;
    end
    return BASE_TSOD_GetTypeTooltip(kCityState);
end


BASE_TSOD_GetTypeName = GetTypeName;
function GetTypeName( kCityState:table )
    if IsEntertainment(kCityState) then
        return Locale.Lookup(ENTERTAINMENT_NAME);
    end
    return BASE_TSOD_GetTypeName(kCityState);
end
