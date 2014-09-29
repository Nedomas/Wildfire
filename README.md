# Wildfire

Uses computer vision to cut objects from images.

Something like this.

![Page Rectangle](https://cloud.githubusercontent.com/assets/1877286/4446183/244f081a-4800-11e4-8b71-b7abe348e2c1.png)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'wildfire'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install wildfire

## Usage

Use it from command line:
```sh
bin/wildfire a4 spec/support/printed-iphones-on-a4.jpg
# => The page was cut and placed at spec/support/big_page.jpg

bin/wildfire printed_screens spec/support/printed-iphones-on-a4.jpg
# => The screens were cut and placed at spec/support/screen_0.jpg,
# spec/support/screen_1.jpg, spec/support/screen_2.jpg, spec/support/screen_3.jpg
```

Use it from Ruby code:
```ruby
  manager = Wildfire::Manager.new(image_path)
  manager.predicted_page_coords
  # => [[0,0], [0, 50], [50, 0], [50, 50]]
  manager.cut_page!(manager.predicted_page_coords)
  # => cut_page_path.jpg

  Wildfire::ScreenCutter.new('cut_page_path.jpg').paths
  # => ['screen_1.jpg', 'screen_2.jpg', ...]
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/wildfire/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
