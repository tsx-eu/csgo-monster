from PIL import Image, ImageOps, ImageDraw

img = Image.new(mode="RGBA", size=(1024*4 + 1024*2, 1024*2 + 1024*1))

front = Image.open("../UI_parts/Right_ampoule.png")
front_mask = Image.new(mode="RGB", size=img.size)
front_mask.paste(Image.open("../UI_parts/Right_ampoule_mask.png"), (0, img.height-front.height))

water = Image.open("../Textures/G_Textures_07.png")

water_mask = Image.new(mode="RGB", size=img.size)
water_mask.paste(water, (-256, img.height-front.height-256))
water = ImageOps.colorize(water_mask.convert("L"), black="black", white="red")

back = Image.new(mode="RGB", size=img.size)
back.paste(Image.open("../Textures/G_Textures_04.png"), (0, 0))
back = ImageOps.colorize(back.convert("L"), black="black", white="red")

blend = Image.composite(back, water, back.convert("L"))
H = 32
S = 5

for HP in range(0, 100, S):
    Y = (100-HP)/100 * (front.height-64)
    back_mask = Image.new("L", img.size)
    draw = ImageDraw.Draw(back_mask)
    for i in range(0, H):
        draw.line((0, img.height-front.height+i+Y-H/2, back.width, img.height-front.height+i+Y-H/2), int(i/H*255))
    for i in range(H, back.height):
        draw.line((0, img.height-front.height+i+Y-H/2, back.width, img.height-front.height+i+Y-H/2), 255)

    mask = Image.new(mode="RGB", size=img.size)
    mask.paste(back_mask, (0, 0), front_mask.convert("L"))

    img.paste(blend, (0, 0), mask.convert("L"))
    img.alpha_composite(front, (0, img.height-front.height))

    exp = Image.new(mode="RGBA", size=(1024 * 4, 1024 * 2))
    exp.alpha_composite(img.resize((img.width//4*3, img.height//4*3)), (0, 256), (0, 512))
    exp.resize((exp.width//2, exp.height//2)).save("../HP/" + str(HP) + ".png")
