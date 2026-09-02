# 梦境之城 / Dream City

《黎明之剑》里沙箱中的城邦，由上层叙事者——一只巨大的蜘蛛——看顾。
城邦毁灭后，它的丝线留了下来，成了「叙事者神经网络」。

## 内容

**文化城邦「梦境之城」**（需要《风云变幻》）

作为宗主国：

- [ICON_TechBoosted] 尤里卡和 [ICON_CivicBoosted] 鼓舞提供 60% 的科技与市政，而非 50%
- 你的城市中每个区域 +1 [ICON_Amenities] 宜居度

1/3/6 使者的加成走原版文化城邦那一套（`LEADER_MINOR_CIV_CULTURAL` 继承而来），
本 mod 不重复定义。

## 实现要点

结构照原版文化城邦 `CIVILIZATION_NAN_MADOL` 抄，命名沿用官方惯例。

**宗主国能力是两层**：外层 `MODIFIER_ALL_PLAYERS_ATTACH_MODIFIER`
配 `SubjectRequirementSetId = PLAYER_IS_SUZERAIN`，把内层 modifier 挂到当前宗主国身上。
一个 trait 挂多条外层是官方做法（`MINOR_CIV_HATTUSA_TRAIT` 挂了 7 条）。

宜居度那条要下发三层，因为效果本身是区域级的：

```
玩家  --MODIFIER_PLAYER_CITIES_ATTACH_MODIFIER-->  每座城市
城市  --MODIFIER_CITY_DISTRICTS_ADJUST_DISTRICT_AMENITY-->  每个区域 +1
```

尤里卡/鼓舞那两条直接抄中国的朝代更替（`TRAIT_CIVILIZATION_DYNASTIC_CYCLE`），
`Amount` 是额外的百分点，官方填的就是 10。

用到的 modifier 类型全部是官方已定义的 DynamicModifier，本 mod 一个都没新建。

**图标走「直接 DDS」路线**：不打 XLP、不需要 SDK。
`tools/make_icon.py` 画蜘蛛并直接写出 13 个尺寸的未压缩 32 位 RGBA `.dds`，
DDS 头逐字段照抄已在游戏里验证可用的图标。

## 目录

```
Data/DreamCity_Civilizations.sql   城邦 / 领袖 / 特性骨架
Data/DreamCity_Modifiers.sql       宗主国能力
Data/DreamCity_Colors.sql          配色（复用官方文化城邦）
Data/DreamCity_Config.sql          开局设置里的开关
Data/DreamCity_Picker.sql          城邦挑选界面的条目
Data/DreamCity_Icons.xml           图标登记（13 个尺寸）
Text/DreamCity_Text.sql            中英文
Textures/*.dds                     图标本体
tools/make_icon.py                 重新生成图标
```

## 部署

纯数据 mod，不需要 ModBuddy / SDK，直接复制进 Mods 目录即可：

```
python <skill>/scripts/build_mod.py <本目录>
```

改完再跑一次。游戏运行中改的话要回主菜单重进。

## 状态

MVP 已部署，四项静态检查（modinfo 结构 / LOC 覆盖 / 修正定义 / 文件登记）全过。
**尚未进游戏验证。**

后续想做的：新增一类「娱乐城邦」，收益放在娱乐中心的建筑里。
