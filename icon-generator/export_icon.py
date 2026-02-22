#!/usr/bin/env python3
"""
Generates the app icon by reading the canvas data from the HTML page
and saving it as a 1024x1024 PNG in the Xcode asset catalog.
"""
import http.client
import base64
import json
import os

# We'll fetch the page, run the canvas export JS, and save the result.
# Since we already have the HTML with the canvas, let's just render it
# programmatically using the same approach.

from PIL import Image, ImageDraw, ImageFont, ImageFilter
import math

W, H = 1024, 1024

def draw_icon():
    img = Image.new('RGBA', (W, H))
    draw = ImageDraw.Draw(img)

    # === BACKGROUND GRADIENT (Green) ===
    for y in range(H):
        t = y / H
        r = int(27 + (69 - 27) * t)
        g = int(122 + (182 - 122) * t)
        b = int(61 + (73 - 61) * t)
        draw.line([(0, y), (W, y)], fill=(r, g, b, 255))

    # === SUBTLE DIAGONAL LINES ===
    overlay = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    odraw = ImageDraw.Draw(overlay)
    for i in range(-H, W + H, 40):
        odraw.line([(i, 0), (i + H, H)], fill=(255, 255, 255, 15), width=2)
    img = Image.alpha_composite(img, overlay)
    draw = ImageDraw.Draw(img)

    # === RADIAL GLOW ===
    glow = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    gdraw = ImageDraw.Draw(glow)
    cx, cy = W // 2, H // 2 + 40
    for radius in range(420, 50, -2):
        alpha = int(30 * (1 - radius / 420))
        gdraw.ellipse([cx - radius, cy - radius, cx + radius, cy + radius],
                       fill=(255, 255, 255, max(0, alpha)))
    img = Image.alpha_composite(img, glow)
    draw = ImageDraw.Draw(img)

    # === SHOPPING BAG ===
    bagX, bagY = W // 2, H // 2 + 60
    bagW, bagH = 340, 360

    # Bag shadow
    shadow = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    sdraw = ImageDraw.Draw(shadow)
    bag_left = bagX - bagW // 2
    bag_right = bagX + bagW // 2
    bag_top = bagY - bagH // 2 + 30
    bag_bottom = bagY + bagH // 2
    sdraw.rounded_rectangle(
        [bag_left - 5, bag_top + 30, bag_right + 5, bag_bottom + 20],
        radius=30, fill=(0, 0, 0, 70)
    )
    shadow = shadow.filter(ImageFilter.GaussianBlur(radius=25))
    img = Image.alpha_composite(img, shadow)
    draw = ImageDraw.Draw(img)

    # Bag body
    draw.rounded_rectangle(
        [bag_left, bag_top + 30, bag_right, bag_bottom],
        radius=30, fill=(248, 248, 248, 255)
    )

    # Bag top fold
    draw.rectangle(
        [bag_left + 10, bag_top + 30, bag_right - 10, bag_top + 60],
        fill=(232, 232, 232, 255)
    )

    # Bag handles
    handle_img = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    hdraw = ImageDraw.Draw(handle_img)
    # Left handle arc
    hdraw.arc([bagX - 100, bag_top - 60, bagX - 10, bag_top + 40],
              start=180, end=360, fill=(200, 200, 200, 255), width=12)
    # Right handle arc
    hdraw.arc([bagX + 10, bag_top - 60, bagX + 100, bag_top + 40],
              start=180, end=360, fill=(200, 200, 200, 255), width=12)
    img = Image.alpha_composite(img, handle_img)
    draw = ImageDraw.Draw(img)

    # === RED APPLE ===
    appleX, appleY = bagX, bagY - 50

    # Apple shadow on bag
    apple_shadow = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    asdraw = ImageDraw.Draw(apple_shadow)
    asdraw.ellipse([appleX - 85, appleY - 60, appleX + 85, appleY + 100],
                    fill=(180, 0, 0, 30))
    apple_shadow = apple_shadow.filter(ImageFilter.GaussianBlur(radius=15))
    img = Image.alpha_composite(img, apple_shadow)
    draw = ImageDraw.Draw(img)

    # Apple body - gradient circle
    apple_layer = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    adraw = ImageDraw.Draw(apple_layer)

    apple_r = 88
    for r in range(apple_r, 0, -1):
        t = r / apple_r
        red = int(255 - (255 - 200) * (1 - t))
        green = int(45 * t)
        blue = int(48 * t)
        adraw.ellipse([appleX - r, appleY - r + 10, appleX + r, appleY + r + 10],
                       fill=(red, green, blue, 255))

    # Apple indent at top
    adraw.ellipse([appleX - 15, appleY - apple_r + 5, appleX + 15, appleY - apple_r + 25],
                   fill=(200, 30, 30, 255))

    img = Image.alpha_composite(img, apple_layer)
    draw = ImageDraw.Draw(img)

    # Apple highlight
    highlight = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    hldraw = ImageDraw.Draw(highlight)
    hldraw.ellipse([appleX - 55, appleY - 40, appleX - 10, appleY + 30],
                    fill=(255, 255, 255, 50))
    highlight = highlight.filter(ImageFilter.GaussianBlur(radius=12))
    img = Image.alpha_composite(img, highlight)
    draw = ImageDraw.Draw(img)

    # Apple stem
    draw.line([(appleX, appleY - apple_r + 10), (appleX + 8, appleY - apple_r - 25)],
              fill=(93, 58, 26, 255), width=7)

    # Apple leaf
    leaf_pts = [
        (appleX + 8, appleY - apple_r - 20),
        (appleX + 50, appleY - apple_r - 45),
        (appleX + 60, appleY - apple_r - 20),
        (appleX + 35, appleY - apple_r - 15),
    ]
    draw.polygon(leaf_pts, fill=(76, 217, 100, 255))

    # === ORANGE (bottom-left of bag) ===
    orangeX, orangeY = bagX - 110, bagY + 110
    orange_layer = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    odraw2 = ImageDraw.Draw(orange_layer)
    orange_r = 38
    for r in range(orange_r, 0, -1):
        t = r / orange_r
        rr = int(255 - (255 - 230) * (1 - t))
        gg = int(179 * t + 140 * (1 - t))
        bb = int(71 * t)
        odraw2.ellipse([orangeX - r, orangeY - r, orangeX + r, orangeY + r],
                        fill=(rr, gg, bb, 255))
    img = Image.alpha_composite(img, orange_layer)
    draw = ImageDraw.Draw(img)

    # Orange highlight
    oh = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    ohdraw = ImageDraw.Draw(oh)
    ohdraw.ellipse([orangeX - 18, orangeY - 22, orangeX + 2, orangeY + 2],
                    fill=(255, 255, 255, 55))
    oh = oh.filter(ImageFilter.GaussianBlur(radius=6))
    img = Image.alpha_composite(img, oh)
    draw = ImageDraw.Draw(img)

    # === GRAPE CLUSTER (bottom-right of bag) ===
    grape_positions = [
        (bagX + 100, bagY + 85),
        (bagX + 130, bagY + 85),
        (bagX + 85, bagY + 115),
        (bagX + 115, bagY + 115),
        (bagX + 145, bagY + 115),
        (bagX + 100, bagY + 145),
        (bagX + 130, bagY + 145),
    ]
    grape_layer = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    gpdraw = ImageDraw.Draw(grape_layer)
    grape_colors = [(142, 68, 173), (155, 89, 182), (125, 60, 152)]
    for i, (gx, gy) in enumerate(grape_positions):
        gr = 17
        base = grape_colors[i % 3]
        for r in range(gr, 0, -1):
            t = r / gr
            rr = int(base[0] + (187 - base[0]) * (1 - t))
            gg = int(base[1] + (107 - base[1]) * (1 - t))
            bb = int(base[2] + (217 - base[2]) * (1 - t))
            gpdraw.ellipse([gx - r, gy - r, gx + r, gy + r], fill=(rr, gg, bb, 255))
    img = Image.alpha_composite(img, grape_layer)
    draw = ImageDraw.Draw(img)

    # === "FRESH MARKET" BADGE ===
    badge_y = bag_bottom + 30
    badge = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    bdraw = ImageDraw.Draw(badge)
    bdraw.rounded_rectangle(
        [bagX - 130, badge_y, bagX + 130, badge_y + 55],
        radius=27, fill=(0, 0, 0, 50)
    )
    img = Image.alpha_composite(img, badge)
    draw = ImageDraw.Draw(img)

    # Text
    try:
        font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 28)
    except Exception:
        try:
            font = ImageFont.truetype("/System/Library/Fonts/SFNSDisplay.ttf", 28)
        except Exception:
            font = ImageFont.load_default()

    draw.text((bagX, badge_y + 28), "FRESH MARKET",
              fill=(255, 255, 255, 240), font=font, anchor="mm")

    return img


if __name__ == '__main__':
    icon = draw_icon()

    # Save to Xcode AppIcon asset
    output_dir = "/Users/manideep/development/iOS/Practice/ECommerce With MVVM/ECommerce With MVVM/Assets.xcassets/AppIcon.appiconset"
    output_path = os.path.join(output_dir, "AppIcon.png")
    icon.save(output_path, 'PNG')
    print(f"Icon saved to: {output_path}")

    # Also save a dark variant (darker background)
    dark = draw_icon()
    # We could create a dark variant if needed
    dark_path = os.path.join(output_dir, "AppIcon-dark.png")
    dark.save(dark_path, 'PNG')
    print(f"Dark icon saved to: {dark_path}")

    print("Done! Update Contents.json to reference these files.")
