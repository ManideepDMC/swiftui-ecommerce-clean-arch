#!/usr/bin/env python3
"""Creates a tinted variant of the app icon (monochrome style for iOS tinted mode)."""
from PIL import Image, ImageDraw, ImageFilter, ImageFont
import os

W, H = 1024, 1024

def draw_tinted_icon():
    """Tinted icons in iOS are rendered as a single-color silhouette.
    We create a version with a transparent background and white shapes."""
    img = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Solid fill background
    draw.rounded_rectangle([0, 0, W, H], radius=0, fill=(45, 155, 78, 255))

    bagX, bagY = W // 2, H // 2 + 60
    bagW, bagH = 340, 360
    bag_left = bagX - bagW // 2
    bag_right = bagX + bagW // 2
    bag_top = bagY - bagH // 2 + 30
    bag_bottom = bagY + bagH // 2

    # Bag body (white with some transparency)
    draw.rounded_rectangle(
        [bag_left, bag_top + 30, bag_right, bag_bottom],
        radius=30, fill=(255, 255, 255, 220)
    )
    # Bag fold
    draw.rectangle(
        [bag_left + 10, bag_top + 30, bag_right - 10, bag_top + 60],
        fill=(230, 230, 230, 220)
    )

    # Handles
    handle_img = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    hdraw = ImageDraw.Draw(handle_img)
    hdraw.arc([bagX - 100, bag_top - 60, bagX - 10, bag_top + 40],
              start=180, end=360, fill=(220, 220, 220, 255), width=12)
    hdraw.arc([bagX + 10, bag_top - 60, bagX + 100, bag_top + 40],
              start=180, end=360, fill=(220, 220, 220, 255), width=12)
    img = Image.alpha_composite(img, handle_img)
    draw = ImageDraw.Draw(img)

    # Apple (darker silhouette)
    appleX, appleY = bagX, bagY - 50
    apple_r = 88
    draw.ellipse([appleX - apple_r, appleY - apple_r + 10, appleX + apple_r, appleY + apple_r + 10],
                  fill=(200, 50, 50, 200))
    # Stem
    draw.line([(appleX, appleY - apple_r + 10), (appleX + 8, appleY - apple_r - 25)],
              fill=(93, 58, 26, 200), width=7)
    # Leaf
    leaf_pts = [
        (appleX + 8, appleY - apple_r - 20),
        (appleX + 50, appleY - apple_r - 45),
        (appleX + 60, appleY - apple_r - 20),
        (appleX + 35, appleY - apple_r - 15),
    ]
    draw.polygon(leaf_pts, fill=(60, 180, 80, 200))

    # Orange
    draw.ellipse([bagX - 148, bagY + 72, bagX - 72, bagY + 148],
                  fill=(255, 160, 50, 200))

    # Grapes
    grape_positions = [
        (bagX + 100, bagY + 85), (bagX + 130, bagY + 85),
        (bagX + 85, bagY + 115), (bagX + 115, bagY + 115), (bagX + 145, bagY + 115),
        (bagX + 100, bagY + 145), (bagX + 130, bagY + 145),
    ]
    for gx, gy in grape_positions:
        draw.ellipse([gx - 17, gy - 17, gx + 17, gy + 17], fill=(130, 60, 160, 200))

    return img

if __name__ == '__main__':
    icon = draw_tinted_icon()
    output_dir = "/Users/manideep/development/iOS/Practice/ECommerce With MVVM/ECommerce With MVVM/Assets.xcassets/AppIcon.appiconset"
    output_path = os.path.join(output_dir, "AppIcon-tinted.png")
    icon.save(output_path, 'PNG')
    print(f"Tinted icon saved to: {output_path}")
