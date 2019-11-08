# imogen
derivative generation via FreeImage and smart square thumbnail via OpenCV

## Scale and re-format an image
```ruby
  Imogen.with_image('example.tiff') do |img|
    # img is a FreeImage::BitMap
    Imogen::Scaled.convert(img, 'example-150.jpg', 150)
  end
```
## Use OpenCV's "Interesting Region" detection
```ruby
  Imogen.with_image('example.tiff') do |img|
    Imogen::AutoCrop.convert(img, 'example-150-square.jpg', 150)
  end
```

## Convert according to IIIF parameters
```ruby
  Imogen.with_image('example.tiff') do |img|
    Imogen::Iiif.convert(img, 'example-iiif-region.jpg', 'jpg', region: '50,60,500,800', size: '!100,100', quality: 'color', rotation: 90)
  end
```
## Build IIIF parameters for a DZI-style tileset
```ruby
  Imogen.with_image('example.tiff') do |img|
    Imogen::Iiif::Tiles.for(img,'/tmp',:jpeg) do |bitmap, suggested_path, format, iiif_opts|
      # do something
    end
  end
```
