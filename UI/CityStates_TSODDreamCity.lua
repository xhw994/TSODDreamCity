-- ===========================================================================
--  城邦面板：让新增的娱乐城邦类别有类别图标、类别名和三档使者说明
--
--  官方 PartialScreens/CityStates.lua 里有五处按六个 LEADER_MINOR_CIV_* 硬编码
--  的分支，新类别一个都匹配不上：
--      GetCityStateType()          映射不上 -> 返回空串，下游全部从这里开始崩
--      GetTypeAtlasPieces()        类别图标
--      GetBonusIconAtlasPieces()   使者奖励图标
--      GetTypeTooltip()            类别 tooltip
--      GetTypeName()               类别名
--      GetBonusText()              「派遣 N 位使者：」后面那半句
--  官方在 CivilopediaPage_CityState.lua 里自己留了注释
--  "Should be database-driven, but presently is not."，海事城邦就是靠在那张表里
--  加一行 KLUDGE 塞进去的——新增类别目前只能照办。
--
--  ---------------------------------------------------------------------------
--  为什么 GetCityStateType 对外报 "CULTURE" 而不是 "ENTERTAINMENT"
--  ---------------------------------------------------------------------------
--  那个字符串会流进别的 UI mod，而它们同样按六个类别硬编码。实测
--  Better City States 的 CUI 列表里有
--      cui_SuzerainList[kCityState.Type].color = ...
--  那张表是函数内的 local、只有六个官方键，遇到第七个值就
--  "attempt to index a nil value"，整个城邦面板白屏，且外部够不到那张表。
--
--  所以反过来：**对外仍报一个官方类别，自己识别城邦靠身份**。
--  kCityState.CivType（官方和 BST 的表里都有）顺着查领袖 InheritFrom 即可。
--  代价只有一个：按 Type 排序/分组的地方会把娱乐城邦并进文化组。
--
--  ---------------------------------------------------------------------------
--  按社区约定写成「include 原文件 + 重定义」，并配同 LoadOrder 的 ImportFiles，
--  好让后来的 mod 能 include 本文件继续接力。下面也 include 了 Better City
--  States 的两个资料片文件，装了它这条链才完整（include 不存在的文件不报错）。
-- ===========================================================================

include("CityStates.lua")
pcall(function() include("CityStates_BST_XP1.lua") end)
pcall(function() include("CityStates_BST_XP2.lua") end)


-- 对外伪装成哪个官方类别。必须是六个官方值之一。
local TSOD_MASQUERADE_AS :string = "CULTURE";

-- 娱乐类别暂时复用文化类的图标资源；换成专属图标时只改这两行。
local ENTERTAINMENT_TYPE_ICON  :string = "ICON_CITYSTATE_CULTURE";
local ENTERTAINMENT_BONUS_ICON :string = "ICON_ENVOY_BONUS_CULTURE";
local ENTERTAINMENT_NAME       :string = "LOC_CITY_STATES_TYPE_ENTERTAINMENT";

local TSOD_CATEGORY_LEADER :string = "LEADER_MINOR_CIV_ENTERTAINMENT";

-- 三档说明。官方那三个门槛常量在原文件里是 local，include 拿不到，
-- 只能按传进来的数字判；官方从来只用 1 / 3 / 6 这三个值。
-- 每档一句：1 使者那档虽然挂了两条 modifier（首都、一级建筑），
-- 但说明是一句话讲完的，跟官方「首都和每座古罗马剧场」一个写法。
local TSOD_TIER_TEXT :table = {
    [1] = { "LOC_MINOR_CIV_SMALL_INFLUENCE_ENVOYS",
            { "LOC_MINOR_CIV_ENTERTAINMENT_TRAIT_SMALL_INFLUENCE_BONUS" } },
    [3] = { "LOC_MINOR_CIV_MEDIUM_INFLUENCE_ENVOYS",
            { "LOC_MINOR_CIV_ENTERTAINMENT_TRAIT_MEDIUM_INFLUENCE_BONUS" } },
    [6] = { "LOC_MINOR_CIV_LARGE_INFLUENCE_ENVOYS",
            { "LOC_MINOR_CIV_ENTERTAINMENT_TRAIT_LARGE_INFLUENCE_BONUS" } },
};


-- ---------------------------------------------------------------------------
--  身份判定。按 InheritFrom 判而不是写死城邦名，
--  以后往这个类别里加城邦不用动 Lua。
-- ---------------------------------------------------------------------------
local function IsEntertainmentLeader( sLeader:string )
    if sLeader == nil then return false; end
    if sLeader == TSOD_CATEGORY_LEADER then return true; end
    local kLeader :table = GameInfo.Leaders[sLeader];
    return kLeader ~= nil and kLeader.InheritFrom == TSOD_CATEGORY_LEADER;
end

local function IsEntertainmentPlayer( playerID:number )
    local pConfig = PlayerConfigurations[playerID];
    if pConfig == nil then return false; end
    return IsEntertainmentLeader(pConfig:GetLeaderTypeName());
end

--  哪些城邦属于娱乐类别 —— 开局算一次就够，数据库里不会再变。
local m_kEntertainmentCivs :table = nil;

local function GetEntertainmentCivs()
    if m_kEntertainmentCivs ~= nil then return m_kEntertainmentCivs; end
    m_kEntertainmentCivs = {};
    for kRow in GameInfo.CivilizationLeaders() do
        if IsEntertainmentLeader(kRow.LeaderType) then
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
BASE_TSOD_GetCityStateType = GetCityStateType;
function GetCityStateType( playerID:number )
    local sType :string = BASE_TSOD_GetCityStateType(playerID);
    if sType ~= nil and sType ~= "" and sType ~= "unknown" then
        return sType;
    end
    if IsEntertainmentPlayer(playerID) then
        return TSOD_MASQUERADE_AS;
    end
    return sType;
end


-- 「派遣 N 位使者：」后面那半句。官方这里同样是六选一，落空就是空字符串，
-- 表现为 tooltip 只剩前半句。这一条和百科页无关——百科读的是 Traits.Description。
BASE_TSOD_GetBonusText = GetBonusText;
function GetBonusText( playerID:number, envoyTokenNum:number )
    if IsEntertainmentPlayer(playerID) then
        local kTier :table = TSOD_TIER_TEXT[envoyTokenNum];
        if kTier ~= nil then
            local sDetails :string = "";
            for _, sTag in ipairs(kTier[2]) do
                if sDetails ~= "" then sDetails = sDetails .. " "; end
                sDetails = sDetails .. Locale.Lookup(sTag);
            end
            return Locale.Lookup(kTier[1]), sDetails;
        end
    end
    return BASE_TSOD_GetBonusText(playerID, envoyTokenNum);
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
