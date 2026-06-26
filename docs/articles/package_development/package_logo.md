# tools4watlas logo

## Making the tools4watlas logo

This script uses the WATLAS logo to create the `tools4watlas` logo using
the R package
[`hexSticker`](https://github.com/GuangchuangYu/hexSticker).

``` r
# packages
library(hexSticker)
library(showtext)

# loading Google fonts (http://www.google.com/fonts)
font_add_google("Merriweather", "merriweather")
# automatically use showtext to render text for future devices
showtext_auto()

# path to WATLAS logo
watlas <- "../../man/figures/watlas_logo_clean.png"

# make sticker
sticker(watlas,
        # name
        package = "tools4watlas", p_size = 12, p_y = 0.5,
        p_color = "black", p_family = "merriweather",

        # logo
        s_x = 1, s_y = 1.15, s_width = .85,
        h_fill = "#c8dbee", h_color = "#303c54",
        filename = "../../man/figures/logo.png")
```

![tools4watlas logo](../../reference/figures/logo.png)
