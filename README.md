# 梦境之城 / Dream City

《黎明之剑》里沙箱中的城邦，由上层叙事者——一只巨大的蜘蛛——看顾。
城邦毁灭后，它的丝线留了下来，成了「叙事者神经网络」。

## 内容

**娱乐城邦「梦境之城」**（需要《风云变幻》）——「娱乐」是本 mod 新增的第 7 类城邦。

派遣使者（类别加成）：

- 1 位使者：[ICON_Capital] 首都 +1 [ICON_Amenities] 宜居度
- 3 位使者：拥有**竞技场**或**摩天轮**的城市 +1 [ICON_Amenities] 宜居度
- 6 位使者：拥有**动物园**或**水族馆**的城市 +1；拥有**体育场**或**水上运动中心**的城市再 +1

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

| 档位 | 官方文化城邦（资料片） |
|---|---|
| 3 使者 | `BUILDING_AMPHITHEATER` +2 文化 |
| 6 使者 | `BUILDING_MUSEUM_ART` +2、`BUILDING_MUSEUM_ARTIFACT` +2（LARGE 挂两条） |

所以这里也按建筑分档，并把娱乐中心与水上乐园的**同级建筑合并在同一档**里，
用 `REQUIREMENTSET_TEST_ANY` 判定。6 使者挂两条（二级一条、三级一条），
和官方文化城邦 LARGE 挂两条同形。数值取 1 而不是官方的 2 —— 一点宜居度比两点产出贵得多。

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

> **已知限制**：与其它替换 `CityStates` 这个 LuaContext 的 mod（如 CIVITAS
> City-States）同时开启时，LoadOrder 大的那个赢。本 mod 用了 100000 并配了
> `ImportFiles`，对方若也按约定写就能接力。
> 另外 CIVITAS City-States 自己也做了一个娱乐城邦类别
> （`MINOR_CIV_CSE_ENTERTAINMENT_TRAIT`），和本 mod 的是两个互不相干的类别，
> 同开时会并存。
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
