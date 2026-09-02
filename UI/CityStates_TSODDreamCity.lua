-- ===========================================================================
--  城邦面板：让新增的娱乐城邦类别有图标、类别名和 tooltip
--
--  背景：官方 PartialScreens/CityStates.lua 用 GetCityStateType() 把领袖映射成
--  六个类别字符串之一，匹配不上就返回空串；后面四条 if-elseif 链拿这个字符串
--  查图标 / 名字 / tooltip，落到 else 会 UI.DataError。CivilopediaPage_CityState.lua
--  里官方自己留了注释 "Should be database-driven, but presently is not."。
--
--  ---------------------------------------------------------------------------
--  为什么不让 GetCityStateType 返回 "ENTERTAINMENT"
--  ---------------------------------------------------------------------------
--  因为那个字符串会流进别的 UI mod，而它们同样按六个类别硬编码。实测
--  Better City States 的 CUI 列表里有：
--      cui_SuzerainList[kCityState.Type].color = ...
--  那张表是函数内的 local，只有六个官方键，遇到第七个类别就
--  "attempt to index a nil value"，整个城邦面板白屏。外部改不到那张表。
--
--  所以反过来做：**对外仍然报一个官方类别**（文化），谁都不会崩；
--  **我们自己识别城邦靠身份而不是靠这个字符串** —— kCityState.CivType 一路
--  都在（官方和 BST 的表里都有），顺着它查这个城邦的领袖 InheritFrom 是不是
--  LEADER_MINOR_CIV_ENTERTAINMENT 即可。这样图标、类别名、tooltip 还是娱乐的，
--  而任何按 Type 查表的第三方代码看到的都是它认识的 "CULTURE"。
--
--  代价：BST 那类按 Type 分组的列表会把娱乐城邦并进文化组。可以接受。
--
--  ---------------------------------------------------------------------------
--  按社区约定写成「include 原文件 + 重定义」，并配同 LoadOrder 的 ImportFiles，
--  好让后来的 mod 能 include 本文件继续接力。下面也 include 了 Better City
--  States 的两个资料片文件，装了它这条链才完整（include 不存在的文件不报错）。
-- ===========================================================================

include("CityStates.lua")
pcall(function() include("CityStates_BST_XP1.lua") end)
pcall(function() include("CityStates_BST_XP2.lua") end)


-- 对外伪装成哪个官方类别。六个官方值之一，别填 "ENTERTAINMENT"，
-- 那会让按类别硬编码的第三方 UI 崩掉（见上）。
local TSOD_MASQUERADE_AS :string = "CULTURE";

-- 娱乐类别暂时复用文化类的图标资源；换成专属图标时只改这两行。
local ENTERTAINMENT_TYPE_ICON  :string = "ICON_CITYSTATE_CULTURE";
local ENTERTAINMENT_BONUS_ICON :string = "ICON_ENVOY_BONUS_CULTURE";
local ENTERTAINMENT_NAME       :string = "LOC_CITY_STATES_TYPE_ENTERTAINMENT";

local TSOD_CATEGORY_LEADER :string = "LEADER_MINOR_CIV_ENTERTAINMENT";


-- ---------------------------------------------------------------------------
--  哪些城邦属于娱乐类别 —— 开局算一次就够，数据库里不会再变。
--  按 InheritFrom 判定而不是写死城邦名，以后往这个类别里加城邦不用动这里。
-- ---------------------------------------------------------------------------
local m_kEntertainmentCivs :table = nil;

local function GetEntertainmentCivs()
    if m_kEntertainmentCivs ~= nil then return m_kEntertainmentCivs; end
    m_kEntertainmentCivs = {};
    for kRow in GameInfo.CivilizationLeaders() do
        local kLeader :table = GameInfo.Leaders[kRow.LeaderType];
        if kLeader ~= nil
           and (kRow.LeaderType == TSOD_CATEGORY_LEADER
                or kLeader.InheritFrom == TSOD_CATEGORY_LEADER) then
            m_kEntertainmentCivs[kRow.CivilizationType] = true;
        end
    end
    return m_kEntertainmentCivs;
end

local function IsEntertainment( kCityState:table )
    if kCityState == nil or kCityState.CivType == nil then return false; end
    return GetEntertainmentCivs()[kCityState.CivType] == true;
end


-- 官方的映射对我们的领袖会落空，返回空串，后面所有查表都从这里开始崩。
-- 补成一个官方类别，别的 mod 才不会被第七个字符串噎住。
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
       and (sLeader == TSOD_CATEGORY_LEADER
            or kLeader.InheritFrom == TSOD_CATEGORY_LEADER) then
        return TSOD_MASQUERADE_AS;
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
