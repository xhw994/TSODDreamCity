# -*- coding: utf-8 -*-
"""生成创意工坊封面：深色底 + 琥珀金的上层叙事者。

skill 的发布清单要求封面至少 512×512；这里出 1024×1024，和塞西尔帝国那张一致，
缩略图缩下去更干净。蜘蛛用城邦那套琥珀金（245,190,55，和 PlayerColors 里同一个值），
背后压一层很淡的蛛网，呼应「叙事者神经网络」。

下方约四分之一刻意留空，方便自己用 PS 往上压标题。
"""
import math
import os
import sys

from PIL import Image, ImageDraw, ImageFilter

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import make_icon  # noqa: E402  —— 复用同一只蜘蛛，不另画一份

SIZE = 1024
OUT = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                   "DreamCity.jpg")

AMBER      = (245, 190, 55)
BG_CENTER  = (26, 30, 46)
BG_EDGE    = (8, 10, 16)
WEB_COLOR  = (74, 80, 108)

SPIDER_SIZE   = 620          # 蜘蛛边长
SPIDER_CENTER = (SIZE // 2, 430)   # 偏上，给标题留地方
WEB_CENTER    = SPIDER_CENTER
WEB_RINGS     = 6
WEB_SPOKES    = 12
WEB_MAX_R     = 560


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
    out.convert("RGB").save(OUT, "JPEG", quality=94, subsampling=0)
    print("wrote %s (%dx%d)" % (OUT, SIZE, SIZE))


if __name__ == "__main__":
    main()
