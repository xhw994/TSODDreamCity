-- ===========================================================================
--  城邦面板：让新增的娱乐城邦类别有类型、图标、名字和 tooltip
--
--  官方 PartialScreens/CityStates.lua 用 GetCityStateType() 把领袖映射成六个
--  类别字符串之一，映射不上就返回**空串**；后面四条 if-elseif 链再拿这个字符串
--  查图标 / tooltip，落到 else 会 UI.DataError。所以新类别要先把 Type 补上，
--  再补那四个查表函数。CivilopediaPage_CityState.lua 里官方自己留了注释
--  "Should be database-driven, but presently is not."，海事城邦就是靠在那张表
--  里加一行 KLUDGE 塞进去的——新增类别目前只能照办。
--
--  按社区约定写成「include 原文件 + 重定义」而不是整文件重写，并配一个同
--  LoadOrder 的 ImportFiles，好让后来的 mod 能 include 本文件继续接力。
--  下面把 Better City States 的两个资料片文件也 include 进来，装了它的话
--  这条链才完整（include 不存在的文件不报错，没装也无妨）。
-- ===========================================================================

include("CityStates.lua")
pcall(function() include("CityStates_BST_XP1.lua") end)
pcall(function() include("CityStates_BST_XP2.lua") end)


-- ---------------------------------------------------------------------------
--  兼容开关
--
--  "ENTERTAINMENT" —— 娱乐城邦作为独立类别显示（默认）。
--  "CULTURE"       —— 对 UI 伪装成文化城邦：图标、颜色、类别名都变回文化，
--                     加成不受影响（加成来自 trait，不看这个字符串）。
--
--  什么时候要改成 "CULTURE"：装了会按类别字符串查自己表的城邦 UI mod。
--  已知 Better City States 的 CUI 列表就是这种写法——
--      cui_SuzerainList[kCityState.Type].color = ...
--  它那张表是函数内的 local，只有六个官方键，遇到第七个类别会
--  "attempt to index a nil value"，整个城邦面板白屏。那张表从外部改不了，
--  除非把它整个函数重写，所以这里留一个开关，一行就能退回全兼容模式。
-- ---------------------------------------------------------------------------
local TSOD_ENTERTAINMENT_TYPE :string = "ENTERTAINMENT";

-- 娱乐类别暂时复用文化类的图标资源；换成专属图标时只改这两行。
local ENTERTAINMENT_TYPE_ICON  :string = "ICON_CITYSTATE_CULTURE";
local ENTERTAINMENT_BONUS_ICON :string = "ICON_ENVOY_BONUS_CULTURE";
local ENTERTAINMENT_NAME       :string = "LOC_CITY_STATES_TYPE_ENTERTAINMENT";

local KNOWN_TYPES :table = {
    SCIENTIFIC   = true,
    RELIGIOUS    = true,
    TRADE        = true,
    CULTURE      = true,
    MILITARISTIC = true,
    INDUSTRIAL   = true,
};

local function IsEntertainment( kCityState:table )
    return kCityState ~= nil
       and kCityState.Type ~= nil
       and KNOWN_TYPES[kCityState.Type] == nil;
end


-- ---------------------------------------------------------------------------
--  官方 GetCityStateType 逐个比对六个 LEADER_MINOR_CIV_*，我们的城邦
--  InheritFrom 的是 LEADER_MINOR_CIV_ENTERTAINMENT，一个都匹配不上，
--  于是返回空串——后面所有查表都从这里开始崩。先把它补上。
-- ---------------------------------------------------------------------------
BASE_TSOD_GetCityStateType = GetCityStateType;
function GetCityStateType( playerID:number )
    local sType :string = BASE_TSOD_GetCityStateType(playerID);
    if sType ~= nil and sType ~= "" and sType ~= "unknown" then
        return sType;
    end

    local pConfig = PlayerConfigurations[playerID];
    if pConfig == nil then return sType; end
    local sLeader :string = pConfig:GetLeaderTypeName();
    local kLeader :table  = GameInfo.Leaders[sLeader];
    if kLeader ~= nil
       and (sLeader == "LEADER_MINOR_CIV_ENTERTAINMENT"
            or kLeader.InheritFrom == "LEADER_MINOR_CIV_ENTERTAINMENT") then
        return TSOD_ENTERTAINMENT_TYPE;
    end
    return sType;
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
