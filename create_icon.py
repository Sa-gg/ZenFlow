from PIL import Image, ImageDraw, ImageFont
import os

def create_zenflow_icon(size, output_path):
    # Create image with dark background
    img = Image.new('RGB', (size, size), color='#1a1a2e')
    draw = ImageDraw.Draw(img)
    
    # Draw a circle background
    circle_margin = size // 8
    draw.ellipse(
        [circle_margin, circle_margin, size - circle_margin, size - circle_margin],
        fill='#e94560'
    )
    
    # Try to use a font for the fire emoji, fallback to text
    try:
        # Try to load a font that supports emojis
        font_size = int(size * 0.5)
        try:
            font = ImageFont.truetype("seguiemj.ttf", font_size)  # Windows emoji font
        except:
            try:
                font = ImageFont.truetype("arial.ttf", font_size)
            except:
                font = ImageFont.load_default()
        
        # Draw fire emoji or "Z" for ZenFlow
        text = "🔥"
        
        # Get text bounding box
        bbox = draw.textbbox((0, 0), text, font=font)
        text_width = bbox[2] - bbox[0]
        text_height = bbox[3] - bbox[1]
        
        # Center the text
        x = (size - text_width) // 2
        y = (size - text_height) // 2 - bbox[1]
        
        draw.text((x, y), text, fill='white', font=font)
    except Exception as e:
        print(f"Error with emoji, using 'Z': {e}")
        # Fallback: draw a large "Z"
        font_size = int(size * 0.6)
        try:
            font = ImageFont.truetype("arial.ttf", font_size)
        except:
            font = ImageFont.load_default()
        
        text = "Z"
        bbox = draw.textbbox((0, 0), text, font=font)
        text_width = bbox[2] - bbox[0]
        text_height = bbox[3] - bbox[1]
        x = (size - text_width) // 2
        y = (size - text_height) // 2 - bbox[1]
        draw.text((x, y), text, fill='white', font=font)
    
    # Save the image
    img.save(output_path, 'PNG')
    print(f"Created {output_path}")

# Create icons for different platforms
print("Creating app icons...")

# Android icons (mipmap directories)
android_sizes = {
    'mdpi': 48,
    'hdpi': 72,
    'xhdpi': 96,
    'xxhdpi': 144,
    'xxxhdpi': 192
}

base_path = r'C:\Users\parus\Desktop\ZenFlow\hive\android\app\src\main\res'
for density, size in android_sizes.items():
    dir_path = os.path.join(base_path, f'mipmap-{density}')
    os.makedirs(dir_path, exist_ok=True)
    create_zenflow_icon(size, os.path.join(dir_path, 'ic_launcher.png'))

# Web icons
web_path = r'C:\Users\parus\Desktop\ZenFlow\hive\web\icons'
os.makedirs(web_path, exist_ok=True)
create_zenflow_icon(192, os.path.join(web_path, 'Icon-192.png'))
create_zenflow_icon(512, os.path.join(web_path, 'Icon-512.png'))
create_zenflow_icon(192, os.path.join(web_path, 'Icon-maskable-192.png'))
create_zenflow_icon(512, os.path.join(web_path, 'Icon-maskable-512.png'))

# Favicon
create_zenflow_icon(32, r'C:\Users\parus\Desktop\ZenFlow\hive\web\favicon.png')

# iOS icons (if needed later)
ios_path = r'C:\Users\parus\Desktop\ZenFlow\hive\ios\Runner\Assets.xcassets\AppIcon.appiconset'
if os.path.exists(ios_path):
    create_zenflow_icon(1024, os.path.join(ios_path, 'Icon-App-1024x1024@1x.png'))

print("\nAll icons created successfully!")
