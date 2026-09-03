# 梦境之城 / Dream City

《黎明之剑》里沙箱中的城邦，由上层叙事者——一只巨大的蜘蛛——看顾。
城邦毁灭后，它的丝线留了下来，成了「叙事者神经网络」。

## 内容

**娱乐城邦「梦境之城」**（需要《风云变幻》）——「娱乐」是本 mod 新增的第 7 类城邦。

派遣使者（类别加成）：

- 1 位使者：[ICON_Capital] 首都、每座**竞技场**和**摩天轮** +1 [ICON_Amenities] 宜居度
- 3 位使者：每座**动物园**和**水族馆** +1 [ICON_Amenities] 宜居度
- 6 位使者：每座**体育场**和**水上运动中心** +1 [ICON_Amenities] 宜居度

作为宗主国（城邦独有能力「叙事者神经网络」）：

- [ICON_TechBoosted] 尤里卡和 [ICON_CivicBoosted] 鼓舞额外提供 10% 的科技与市政开销
- 你的城市中每个区域 +1 [ICON_Amenities] 宜居度

## 实现要点

### 新增城邦类别

官方自己扩展过城邦类别：「印度尼西亚&高棉」场景里的**海事城邦**
（`LEADER_MINOR_CIV_MARITIME`）就是第 7 类。这里照它的做法——类别领袖
`InheritFrom` 通用的 `LEADER_MINOR_CIV_DEFAULT`，类别加成挂在类别领袖自己的
trait 上，具体城邦再 `InheritFrom` 类别领袖。`CityStateCategory` 只是
`TypeProperties` 里的一个字符串，没有枚举限制。

三档加成照的是**资料片**的形态，不是原版的。原版
（`Base/Assets/Gameplay/Data/Leaders.xml`）给的是「首都 / 每个对应区域」；
**迭起兴衰把 MEDIUM 与 LARGE 整条删掉重写成了按建筑给**
（`Expansion1_RemoveData.xml` 删、`Expansion1_Leaders.xml` 重建），
风云变幻沿用这一版。以文化城邦为例，资料片版是：

| 档位 | 官方文化城邦（资料片） | 本 mod |
|---|---|---|
| 1 使者 | 首都 + `BUILDING_AMPHITHEATER`（一级） | 首都 + 竞技场 / 摩天轮 |
| 3 使者 | 二级建筑 | 动物园 / 水族馆 |
| 6 使者 | `BUILDING_MUSEUM_ART` / `_ARTIFACT`（三级，挂两条） | 体育场 / 水上运动中心 |

**建筑等级跟着使者档位走**。1 使者那档挂两条 modifier（首都一条、一级建筑一条），
和官方「首都和每座古罗马剧场」是一个写法。娱乐中心与水上乐园的同级建筑合并在
同一档，用 `REQUIREMENTSET_TEST_ANY` 判定。数值取 1 而不是官方的 2 ——
一点宜居度比两点产出贵得多。

宜居度用 `EFFECT_ADJUST_CITY_AMENITIES_FROM_CITY_STATES`，它会正确归类成
「来自城邦的宜居度」，比拿区域级的 `EFFECT_ADJUST_DISTRICT_AMENITY` 绕三层干净。
官方没有配套的 DynamicModifier，自建了两条（`COLLECTION_PLAYER_CAPITAL_CITY` /
`COLLECTION_PLAYER_CITIES`），前缀带 TSOD 不会和别的 mod 撞。

### UI：官方把六个类别硬编码了

`PartialScreens/CityStates.lua` 有四条 if-elseif 链，落到 `else` 会
`UI.DataError` 并返回空值。`CivilopediaPage_CityState.lua` 里官方自己留了注释
`-- Should be database-driven, but presently is not.`，海事城邦就是靠在那张表里
加一行 `KLUDGE` 塞进去的。

按社区约定处理，而不是整文件重写：

```lua
include("CityStates.lua")
BASE_TSOD_GetTypeAtlasPieces = GetTypeAtlasPieces
function GetTypeAtlasPieces(kCityState, size) ... end
```

`ReplaceUIScript` 配一个**同 LoadOrder 的 `ImportFiles`**，后来的 mod 才能
`include` 本文件接力，而不是把我们顶掉。

判断上不去猜娱乐城邦被映射成什么字符串（官方文化城邦在 Lua 里是 `"CULTURE"`，
在数据库里却是 `"CULTURAL"`），而是反过来：**凡是官方六种之外的类型一律当成
本 mod 的娱乐城邦**。本 mod 只引入一个新类别，这样既安全又不受映射规则影响。

官方 `PartialScreens/CityStates.lua` 里按六个 `LEADER_MINOR_CIV_*` 硬编码的分支
一共**六处**，逐个覆盖：

| 函数 | 不覆盖会怎样 |
|---|---|
| `GetCityStateType()` | 映射不上返回**空串**，下游全部从这里开始崩 |
| `GetTypeAtlasPieces()` | 类别图标空白 |
| `GetBonusIconAtlasPieces()` | 使者奖励图标空白 |
| `GetTypeTooltip()` | 类别 tooltip 空 |
| `GetTypeName()` | 显示成 `unknownType'X'` |
| `GetBonusText()` | 「派遣 N 位使者：」后面**半句都没有** |

最后一条和文明百科页无关 —— 百科读的是 `Traits.Description`，所以百科里三档
说明是全的，而面板 tooltip 是空的。两条路，得分别喂。

**不让 `GetCityStateType` 返回 `"ENTERTAINMENT"`** —— 那个字符串会流进别的 UI
mod，而它们同样按六个类别硬编码。实测 Better City States 的 CUI 列表里有
`cui_SuzerainList[kCityState.Type].color = ...`，那张表是函数内的 local、只有六个
官方键，遇到第七个类别就 `attempt to index a nil value`，整个城邦面板白屏，
而且从外部够不到那张表。

所以反过来做：**对外仍报一个官方类别（文化），我们自己识别城邦靠身份**。
`kCityState.CivType` 一路都在（官方和 BST 的表里都有），顺着它查这个城邦的领袖
`InheritFrom` 是不是 `LEADER_MINOR_CIV_ENTERTAINMENT` 就行。这样图标、类别名、
tooltip 还是娱乐的，而任何按 `Type` 查表的第三方代码看到的都是它认识的 `"CULTURE"`。
判定按 `InheritFrom` 而不是写死城邦名，以后往这个类别里加城邦不用改 Lua。

> **代价**：BST 那类按 `Type` 分组的列表会把娱乐城邦并进文化组。
> 与其它替换 `CityStates` 这个 LuaContext 的 mod 同开时，LoadOrder 大的那个赢；
> 本 mod 用了 100000 并配了 `ImportFiles`，也 include 了 BST 的两个资料片文件，
> 对方若也按约定写就能接力。

### 宗主国能力

两层结构：外层 `MODIFIER_ALL_PLAYERS_ATTACH_MODIFIER` 配
`SubjectRequirementSetId = PLAYER_IS_SUZERAIN`，把内层挂到当前宗主国身上。
一个 trait 挂多条外层是官方做法（`MINOR_CIV_HATTUSA_TRAIT` 挂了 7 条）。

宜居度那条要下发三层，因为效果本身是区域级的：

```
玩家  --MODIFIER_PLAYER_CITIES_ATTACH_MODIFIER-->  每座城市
城市  --MODIFIER_CITY_DISTRICTS_ADJUST_DISTRICT_AMENITY-->  每个区域 +1
```

尤里卡/鼓舞那两条的 modifier 抄本体的三处用例（中国的朝代更替、巴比伦、
时代纪念「自由探索」/「百花齐放」），`Amount` 是额外的百分点，官方填的就是 10。
描述文本照抄「自由探索」黄金时代的官方措辞：只说额外 10%，不提基数是多少
（简中写 10%、繁中写 20%，官方自己就对不上，不提反而准确）。

三档使者的描述直接嵌套引用本体的「派遣 N 位使者：」tag，多语言自动跟随。

用到的 modifier 类型全部是官方已定义的 DynamicModifier，本 mod 一个都没新建；
唯一自建的是一个只包 `REQUIRES_DISTRICT_IS_ENTERTAINMENT_COMPLEX` 的
RequirementSet（官方只有 `..._INDUSTRIAL_ZONE_OR_ENTERTAINMENT_COMPLEX`）。
注意巴西的街头狂欢节是另一个区域类型，不在此列。

### 界面上的类别名与使者说明

风云变幻新增了 `MinorCivBonuses` 与 `Leaders_XP2` 两张表，城邦面板从这里取
「这个城邦属于哪一类」。新类别不登记进去，界面上那一栏就是空的。

「派遣 N 位使者：」后面那半句走 `ModifierStrings` 的 `Preview` 上下文。
官方六个类别的说明是引擎内置的、不经这张表，新加的类别必须自己写，
否则 tooltip 里只剩前半句。CIVITAS City-States 也是这么补的。

### 文明百科的分组

侧边栏的分组来自 `CivilopediaPageGroups`，`PageGroupId` 与 `TypeProperties` 里的
`CityStateCategory` **同名**。官方六个组就叫 `CULTURAL` / `SCIENTIFIC` / …，
印尼场景的海事城邦也是照这个加了一行 `PageGroupId="MARITIME"`。
不加的话页面无处可归，会裸露在所有分组外面。一行 SQL，不用碰 Lua。

### 兼容 CIVITAS City-States

装了 CIVITAS 时，文明百科的城邦页由它的 `CivilopediaPage_CityState.lua` 接管，
而它把官方那张硬编码的类别表**改成了数据库驱动**——正好对上官方自己留的那句
`-- Should be database-driven, but presently is not.`：

```lua
for row in GameInfo.CSE_ClassTypes() do
    tCityStateTypes[row.Type] = { TypeName=…, LeaderType=…, TypeIcon=… }
end
for k, v in pairs(tCityStateTypes) do
    types[v.LeaderType] = { v.TypeIcon, v.TypeName, v.SecondaryColor }
end
```

它按 `LeaderType` 重新索引再跟城邦的领袖继承链比对，所以往 `CSE_ClassTypes`
插一行、`LeaderType` 填我们的类别领袖，百科页就认得了——不用替换任何 UI 文件，
也不跟它抢 LuaContext。见 `Data/DreamCity_Compat_CIVITAS.sql`，由 `.modinfo` 的
`ModInUse` criteria 控制，只在 CIVITAS 启用时加载（否则那张表根本不存在）。
`LoadOrder` 需大于 20，这是 CIVITAS 在 `Core/CSE_ModSupport_Guide.sql` 里写的要求。

> 顺带：CIVITAS 自己也有一个娱乐城邦类别 `CSE_ENTERTAINMENT`，而且它那份
> ModSupport 指南给的接入方式是把你的城邦 `InheritFrom` 直接改挂到
> `LEADER_MINOR_CIV_CSE_ENTERTAINMENT` 上。那样融合得更彻底（颜色、图标、百科全走它的），
> 但城邦的三档加成也会跟着换成它的四档设计，本 mod 自己写的那套就不生效了。
> 这里选的是保留自己的类别与加成，只借它的百科页认一下。

### 配色

娱乐是新类别，官方没有对应的 `COLOR_PLAYER_CITY_STATE_*`。之前借用文化城邦的
品红（`COLOR_STANDARD_MAGENTA_MD`），所以游戏里看着是紫的；现在自定义成琥珀金
`245,190,55`，取娱乐中心的色调，并刻意避开贸易城邦的柠檬黄
（`247,216,1`，商业中心那个）和工业城邦的橙（`255,129,18`）。

### 图标

走「直接 DDS」路线：不打 XLP、不需要 SDK。`tools/make_icon.py` 画蜘蛛并直接写出
13 个尺寸的未压缩 32 位 RGBA `.dds`，DDS 头逐字段照抄已在游戏里验证可用的图标。

散装 `.dds` **必须走 `ImportFiles` action** 才进得了游戏的虚拟文件系统；
只写在 `<Files>` 里那是文件清单，不等于 `IconTextureAtlases.Filename` 找得到它。
前端和游戏内两边都要写（开局界面属于前端）。

娱乐类别自己的图标（`ICON_CITYSTATE_ENTERTAINMENT`）还没做，暂时复用文化类的，
换的时候只改 `UI/CityStates_TSODDreamCity.lua` 顶部那两行常量。

## 目录

```
Data/DreamCity_CityStateCategory.sql  新增的娱乐城邦类别 + 三档使者加成
Data/DreamCity_Civilizations.sql      城邦 / 领袖 / 特性骨架
Data/DreamCity_Modifiers.sql          宗主国能力
Data/DreamCity_Colors.sql             配色（琥珀金，自定义）
Data/DreamCity_Config.sql             开局设置里的开关
Data/DreamCity_Picker.sql             城邦挑选界面的条目
Data/DreamCity_Compat_CIVITAS.sql     CIVITAS City-States 兼容（仅在它启用时加载）
Data/DreamCity_Icons.xml              图标登记（13 个尺寸）
Text/DreamCity_Text.sql               中英文
UI/CityStates_TSODDreamCity.lua       城邦面板：让新类别有图标和名字
Textures/*.dds                        图标本体
tools/make_icon.py                    重新生成图标
tools/make_cover.py                   重新生成创意工坊封面
DreamCity.jpg                         创意工坊封面（1024×1024，下方留白待加标题）
WORKSHOP_CN.md / WORKSHOP_EN.md       创意工坊简介（Steam BBCode）
```

## 部署

纯数据 + 一个 UI 脚本，不需要 ModBuddy / SDK：

```
python <skill>/scripts/build_mod.py <本目录>
```

改完再跑一次。游戏运行中改的话要回主菜单重进。

## 状态

四项静态检查（modinfo 结构 / LOC 覆盖 / 修正定义 / Lua）全过，已部署。
文化城邦版本已在游戏里验过；**娱乐城邦这一版尚未进游戏验证**。
