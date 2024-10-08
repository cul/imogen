# imogen
derivative generation and smart square thumbnail via libvips.

## Scale and re-format an image
```ruby
  Imogen.with_image('example.tiff') do |img|
    # img is a FreeImage::BitMap
    Imogen::Scaled.convert(img, 'example-150.jpg', 150)
  end
```

## Scale and re-format an image, using the revalidate option to skip any vips caching and re-reading in the source image
```ruby
  Imogen.with_image('example.tiff', { revalidate: true }) do |img|
    # img is a FreeImage::BitMap
    Imogen::Scaled.convert(img, 'example-150.jpg', 150)
  end
```
Note: The `revalidate` option requires libvips >= 8.15.

## Perform "interesting region" detection
```ruby
  Imogen.with_image('example.tiff') do |img|
    # get the crop area of an "interesting region" of an image
    left_x, top_y, right_x, bottom_y = Imogen::Iiif::Region::Featured.get(img, 768)
  end

  # or

  Imogen.with_image('example.tiff') do |img|
    Imogen::AutoCrop.convert(img, 'example-150-square.jpg', 150)
  end
```

## Convert according to IIIF parameters
```ruby
  Imogen.with_image('example.tiff') do |img|
    Imogen::Iiif.convert(img, 'example-iiif-region.jpg', 'jpg', region: '50,60,500,800', size: '!100,100', quality: 'color', rotation: '!90')
  end
```

## Build IIIF parameters for a DZI-style tileset
```ruby
  Imogen.with_image('example.tiff') do |img|
    Imogen::Iiif::Tiles.for(img,'/tmp',:jpg, 128, 'default') do |image, suggested_tile_dest_path, format, opts|
      # do something
    end
  end
```
