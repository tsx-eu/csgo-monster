from PIL import Image, ImageOps, ImageDraw

img = Image.new(mode="RGBA", size=(512, 512))

circle = Image.open("../../effects/Circle17.png")

for x in range(0, circle.width):
    m = circle.getpixel((x, circle.height//2))
    for y in range(0, circle.height):
        img.putpixel((x, y), m)


img.save("a.png")