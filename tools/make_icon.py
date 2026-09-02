# -*- coding: utf-8 -*-
"""生成梦境之城的城邦图标：一只简笔蜘蛛（上层叙事者）。

Civ6 的图标不是一张图，是一组尺寸。少出一个尺寸，对应界面就是空白。
文明/城邦这一类要 13 个尺寸（由 skill 的 icon_spec.py 给出，源自官方 488 个图集）。

图标本体画成白色剪影：游戏会按玩家颜色着色，官方城邦图标也是这么做的。
先在 1024 的画布上画，再降采样到各尺寸，小图才不会糊。

输出直接是未压缩 32 位 RGBA 的 .dds，头部逐字段照抄 TSODCecilEmpire 里
已验证可用的图标（pfflags=0x41，掩码 R=0x000000ff ... A=0xff000000），
因此不需要 texconv。
"""
import io
import os
import struct

from PIL import Image, ImageDraw

SUPER = 1024                     # 超采样画布边长
SIZES = [22, 30, 32, 36, 44, 45, 48, 50, 64, 80, 128, 200, 256]
NAME = "ICON_CIVILIZATION_TSOD_DREAM_CITY"
OUT_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "Textures")

WHITE = (255, 255, 255, 255)
LEG_W = 60                       # 腿宽（1024 画布上）。再细的话 22px 尺寸会断掉。

# 每条腿：体侧起点 -> 膝 -> 脚。只写左半边，右半边镜像。
LEGS = [
    ((410, 350), (230, 200), (110, 250)),
    ((400, 395), (180, 330), (60, 420)),
    ((400, 440), (175, 480), (70, 610)),
    ((415, 485), (215, 640), (140, 800)),
]


def draw_spider():
    img = Image.new("RGBA", (SUPER, SUPER), (255, 255, 255, 0))
    d = ImageDraw.Draw(img)

    for leg in LEGS:
        for pts in (leg, tuple((SUPER - x, y) for x, y in leg)):
            d.line(pts, fill=WHITE, width=LEG_W, joint="curve")
            # 关节和脚端补圆，避免转折处出现缺口
            for x, y in pts:
                r = LEG_W // 2
                d.ellipse((x - r, y - r, x + r, y + r), fill=WHITE)

    # 腹部（下）与头胸部（上）
    d.ellipse((512 - 165, 620 - 190, 512 + 165, 620 + 190), fill=WHITE)
    d.ellipse((512 - 120, 400 - 105, 512 + 120, 400 + 105), fill=WHITE)
    return img


def write_dds(img, path):
    """未压缩 32 位 RGBA，头部与游戏内已验证可用的图标逐字段一致。"""
    w, h = img.size
    header = struct.pack(
        "<4s7I44xII4sIIIII4I4x",
        b"DDS ",
        124,            # dwSize
        0x00021007,     # CAPS | HEIGHT | WIDTH | PIXELFORMAT | MIPMAPCOUNT
        h, w,
        0,              # dwPitchOrLinearSize
        1,              # dwDepth
        1,              # dwMipMapCount
        32,             # ddspf.dwSize
        0x41,           # DDPF_RGB | DDPF_ALPHAPIXELS
        b"\x00\x00\x00\x00",
        32,             # bits per pixel
        0x000000FF, 0x0000FF00, 0x00FF0000, 0xFF000000,
        0x00401008,     # COMPLEX | TEXTURE | MIPMAP
        0, 0, 0,
    )
    assert len(header) == 128, len(header)
    with io.open(path, "wb") as f:
        f.write(header)
        f.write(img.convert("RGBA").tobytes())


def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    master = draw_spider()
    master.resize((256, 256), Image.LANCZOS).save(
        os.path.join(os.path.dirname(os.path.abspath(__file__)), "preview_spider_256.png"))
    for s in SIZES:
        write_dds(master.resize((s, s), Image.LANCZOS),
                  os.path.join(OUT_DIR, "%s_%d.dds" % (NAME, s)))
    print("wrote %d dds files to %s" % (len(SIZES), OUT_DIR))


if __name__ == "__main__":
    main()
