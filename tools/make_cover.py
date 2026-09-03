# -*- coding: utf-8 -*-
"""生成创意工坊封面：深色底 + 琥珀金的上层叙事者 + 下方标题牌。

skill 的发布清单要求封面至少 512×512；这里出 1024×1024，和塞西尔帝国那张一致，
缩略图缩下去更干净。蜘蛛用城邦那套琥珀金（245,190,55，和 PlayerColors 里同一个值），
背后压一层很淡的蛛网，呼应「叙事者神经网络」。

顶上一行英文小字，下面一块标题牌。牌子照着 PS 里那套图层样式复刻，不追求参数一一对应，看着是那么回事就行：

    投影    正片叠底 50%，角度 30°，距离 5px，大小 38px
            -> 一层偏移后高斯模糊的黑，压在牌子底下
    外发光  滤色 50%，黄色，扩展 20%，大小 6px
            -> 把牌子形状往外扩几像素再模糊，以「取较亮者」的方式叠上去
    描边    3px 内部，琥珀金
            -> 直接画在矩形边上
    文字描边
            -> PIL 的 stroke_width，同色描边等于把笔画稍微加粗一点

中文用楷体、英文用 Candara，跟 PS 里选的一致。
把 PLATE_ENABLED 关掉就出一张干净的底图。
"""
import math
import os
import sys

from PIL import Image, ImageChops, ImageDraw, ImageFilter, ImageFont

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import make_icon  # noqa: E402  —— 复用同一只蜘蛛，不另画一份

SIZE = 1024
OUT = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                   "DreamCity.jpg")

AMBER      = (245, 190, 55)
BG_CENTER  = (26, 30, 46)
BG_EDGE    = (8, 10, 16)
WEB_COLOR  = (74, 80, 108)

SPIDER_SIZE   = 620
SPIDER_CENTER = (SIZE // 2, 410)   # 偏上，把下半张留给标题牌
WEB_CENTER    = SPIDER_CENTER
WEB_RINGS     = 6
WEB_SPOKES    = 12
WEB_MAX_R     = 560

# ---- 顶部小标题 ------------------------------------------------------------
TOP_TITLE       = "The Sword of Dawn"            # 置空则不画
TOP_TITLE_FONT  = r"C:\Windows\Fonts\segoeuil.ttf"   # Segoe UI Light
TOP_TITLE_SIZE  = 32
TOP_TITLE_TRACK = 0.50       # em 为单位；PS 字符面板里的字距填 500
TOP_TITLE_TOP   = 24         # 字形顶端离画布顶端的像素数

# ---- 标题牌 ----------------------------------------------------------------
PLATE_ENABLED = True
PLATE_BOX     = (52, 676, 972, 984)      # left, top, right, bottom
PLATE_FILL    = (9, 9, 11)
PLATE_STROKE  = 3

GLOW_SPREAD = 5      # 外发光「扩展」：形状先往外胀这么多像素
GLOW_BLUR   = 7      # 外发光「大小」
GLOW_ALPHA  = 0.50

SHADOW_ANGLE = 30    # PS 的光源角度，阴影落在反方向
SHADOW_DIST  = 5
SHADOW_BLUR  = 19    # PS 的「大小 38」约等于这个半径
SHADOW_ALPHA = 0.50

TEXT_CN      = "黎明之剑：梦境之城"
TEXT_EN      = "TSOD: Dream City"
FONT_CN      = r"C:\Windows\Fonts\simkai.ttf"    # 楷体
FONT_EN      = r"C:\Windows\Fonts\Candara.ttf"
SIZE_CN      = 76
SIZE_EN      = 68
BASELINE_CN  = 762      # 两行文字各自的视觉中线
BASELINE_EN  = 906
TRACK_CN     = 0.06     # 楷体挤在一起不好看，稍微松一点
TRACK_EN     = 0.02


def radial_background():
    img = Image.new("RGB", (SIZE, SIZE), BG_EDGE)
    d = ImageDraw.Draw(img)
    cx, cy = WEB_CENTER
    steps = 96
    maxr = int(math.hypot(SIZE, SIZE) * 0.62)
    for i in range(steps, 0, -1):
        t = i / steps
        r = int(maxr * t)
        col = tuple(int(BG_EDGE[c] + (BG_CENTER[c] - BG_EDGE[c]) * (1.0 - t) ** 1.6)
                    for c in range(3))
        d.ellipse((cx - r, cy - r, cx + r, cy + r), fill=col)
    return img


def draw_web(img):
    """蛛网单独画在一层上再模糊，免得线条太硬抢戏。"""
    layer = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    cx, cy = WEB_CENTER
    angles = [2 * math.pi * k / WEB_SPOKES for k in range(WEB_SPOKES)]

    for k in range(WEB_SPOKES):
        a = angles[k]
        d.line((cx, cy, cx + WEB_MAX_R * math.cos(a), cy + WEB_MAX_R * math.sin(a)),
               fill=WEB_COLOR + (185,), width=3)

    for ring in range(1, WEB_RINGS + 1):
        r = WEB_MAX_R * ring / WEB_RINGS
        pts = [(cx + r * math.cos(a), cy + r * math.sin(a)) for a in angles]
        pts.append(pts[0])
        d.line(pts, fill=WEB_COLOR + (160,), width=3, joint="curve")

    layer = layer.filter(ImageFilter.GaussianBlur(1.6))
    img.paste(Image.alpha_composite(img.convert("RGBA"), layer).convert("RGB"), (0, 0))
    return img


def _plate_mask(spread=0, offset=(0, 0)):
    """标题牌的形状。spread 让它往外胀，offset 让它整体位移。"""
    m = Image.new("L", (SIZE, SIZE), 0)
    d = ImageDraw.Draw(m)
    l, t, r, b = PLATE_BOX
    d.rectangle((l - spread + offset[0], t - spread + offset[1],
                 r + spread + offset[0], b + spread + offset[1]), fill=255)
    return m


def draw_plate(img):
    """投影 -> 外发光 -> 牌面 -> 描边，顺序和 PS 图层样式一致。"""
    # 投影：正片叠底就是往下压暗，这里直接按 mask 把底图往黑里插值
    rad = math.radians(SHADOW_ANGLE)
    off = (int(round(-SHADOW_DIST * math.cos(rad))),
           int(round(SHADOW_DIST * math.sin(rad))))
    shadow = _plate_mask(spread=2, offset=off).filter(ImageFilter.GaussianBlur(SHADOW_BLUR))
    shadow = shadow.point(lambda v: int(v * SHADOW_ALPHA))
    img = Image.composite(Image.new("RGB", img.size, (0, 0, 0)), img, shadow)

    # 外发光：滤色 = 取较亮者，用胀开后模糊的形状当强度
    glow_mask = _plate_mask(spread=GLOW_SPREAD).filter(ImageFilter.GaussianBlur(GLOW_BLUR))
    glow_mask = glow_mask.point(lambda v: int(v * GLOW_ALPHA))
    glow = Image.new("RGB", img.size, AMBER)
    glow.putalpha(glow_mask)
    img = ImageChops.lighter(img, Image.composite(glow.convert("RGB"),
                                                  Image.new("RGB", img.size, (0, 0, 0)),
                                                  glow_mask))

    # 牌面与描边
    d = ImageDraw.Draw(img)
    d.rectangle(PLATE_BOX, fill=PLATE_FILL, outline=AMBER, width=PLATE_STROKE)
    return img


def draw_tracked(d, center_x, mid_y, text, font, tracking_em,
                 fill=AMBER, stroke=1, top_y=None):
    """按字距逐字排，并按墨迹包围盒把整行垂直居中。

    字距是加在每个字后面的，末尾会多出一份空档，所以整行要右移半格才是视觉居中。
    """
    extra  = font.size * tracking_em
    widths = [d.textlength(ch, font=font) for ch in text]
    total  = sum(widths) + extra * (len(text) - 1)
    ink    = d.textbbox((0, 0), text, font=font)
    # top_y 给的是「字形顶端」，mid_y 给的是「视觉中线」，二选一
    y      = (top_y - ink[1]) if top_y is not None else (mid_y - (ink[1] + ink[3]) / 2.0)
    x      = center_x - total / 2.0 + extra / 2.0
    for ch, w in zip(text, widths):
        d.text((x, y), ch, font=font, fill=fill,
               stroke_width=stroke, stroke_fill=fill)  # 同色描边 = 笔画稍微加粗
        x += w + extra
    return total


def draw_top_title(img):
    d = ImageDraw.Draw(img)
    f = ImageFont.truetype(TOP_TITLE_FONT, TOP_TITLE_SIZE)
    draw_tracked(d, img.width // 2, None, TOP_TITLE, f, TOP_TITLE_TRACK,
                 fill=(255, 255, 255), stroke=0, top_y=TOP_TITLE_TOP)
    return img


def draw_titles(img):
    d = ImageDraw.Draw(img)
    cx = (PLATE_BOX[0] + PLATE_BOX[2]) // 2
    draw_tracked(d, cx, BASELINE_CN, TEXT_CN,
                 ImageFont.truetype(FONT_CN, SIZE_CN), TRACK_CN)
    draw_tracked(d, cx, BASELINE_EN, TEXT_EN,
                 ImageFont.truetype(FONT_EN, SIZE_EN), TRACK_EN)
    return img


def main():
    img = draw_web(radial_background())

    # 白色剪影 -> 琥珀金：拿它自己的 alpha 当遮罩贴一块纯色上去
    spider = make_icon.draw_spider().resize((SPIDER_SIZE, SPIDER_SIZE), Image.LANCZOS)
    tinted = Image.new("RGBA", spider.size, AMBER + (255,))
    tinted.putalpha(spider.getchannel("A"))

    # 蜘蛛背后一圈很淡的辉光，让它从网上浮起来
    glow = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    gx = SPIDER_CENTER[0] - SPIDER_SIZE // 2
    gy = SPIDER_CENTER[1] - SPIDER_SIZE // 2
    glow.paste(tinted, (gx, gy), tinted)
    glow = glow.filter(ImageFilter.GaussianBlur(26))
    glow.putalpha(glow.getchannel("A").point(lambda v: int(v * 0.55)))

    out = Image.alpha_composite(img.convert("RGBA"), glow)
    out.alpha_composite(tinted, (gx, gy))
    out = out.convert("RGB")

    if TOP_TITLE:
        out = draw_top_title(out)
    if PLATE_ENABLED:
        out = draw_titles(draw_plate(out))

    out.save(OUT, "JPEG", quality=94, subsampling=0)
    print("wrote %s (%dx%d)" % (OUT, SIZE, SIZE))


if __name__ == "__main__":
    main()
