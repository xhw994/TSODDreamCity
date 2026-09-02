# 梦境之城 / Dream City

《黎明之剑》里沙箱中的城邦，由上层叙事者——一只巨大的蜘蛛——看顾。
城邦毁灭后，它的丝线留了下来，成了「叙事者神经网络」。

## 内容

**娱乐城邦「梦境之城」**（需要《风云变幻》）——「娱乐」是本 mod 新增的第 7 类城邦。

派遣使者（类别加成）：

- 1 位使者：[ICON_Capital] 首都 +1 [ICON_Amenities] 宜居度
- 3 位使者：每个娱乐中心区域 +1 [ICON_Amenities] 宜居度
- 6 位使者：每个娱乐中心区域额外 +1 [ICON_Amenities] 宜居度

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

三档使者的结构实测六个官方类别完全一致：1 使者给首都，3 使者给每个对应区域，
6 使者指向**同一个**内层 modifier 再挂一次（attach 两次即叠加）。产出换成宜居度，
数值取 1 而不是官方的 2 —— 1 点宜居度比 2 点产出贵得多。

首都那档用 `MODIFIER_PLAYER_CAPITAL_CITY_ADJUST_CITY_ENTERTAINMENT`，
`EFFECT_ADJUST_CITY_ENTERTAINMENT` 里的 "Entertainment" 就是宜居度，
官方毛利库佩的「首都 +1 宜居度」用的正是这条。

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

> **已知限制**：与其它替换 `CityStates` 这个 LuaContext 的 mod（如 CIVITAS
> City-States）同时开启时，LoadOrder 大的那个赢。本 mod 用了 100000 并配了
> `ImportFiles`，对方若也按约定写就能接力。
> 文明百科页里的类别图标还没接——那张表是函数内的局部变量，覆盖不了，
> 只能整文件替换，暂不做。

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
Data/DreamCity_Colors.sql             配色（复用官方文化城邦）
Data/DreamCity_Config.sql             开局设置里的开关
Data/DreamCity_Picker.sql             城邦挑选界面的条目
Data/DreamCity_Icons.xml              图标登记（13 个尺寸）
Text/DreamCity_Text.sql               中英文
UI/CityStates_TSODDreamCity.lua       城邦面板：让新类别有图标和名字
Textures/*.dds                        图标本体
tools/make_icon.py                    重新生成图标
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
