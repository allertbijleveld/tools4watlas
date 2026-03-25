# Construct residence patches from position data

A cleaned movement track of one individual at a time can be classified
into residence patches using the function `atl_res_patch`. The function
expects a specific organisation of the data: there should be at least
the following columns, `x`, `y`, and `time`, corresponding to the
coordinates, and the time as `POSIXct`. `atl_res_patch` requires only
three parameters: (1) the maximum speed threshold between localizations
(called `max_speed`), (2) the distance threshold between clusters of
positions (called `lim_spat_indep`), and (3) the time interval between
clusters (called `lim_time_indep`).Clusters formed of fewer than a
minimum number of positions can be excluded.The exclusion of clusters
with few positions can help in removing bias due to short stops, but if
such short stops are also of interest, they can be included by reducing
the `min_fixes` argument.

## Usage

``` r
atl_res_patch(
  data,
  max_speed = 3,
  lim_spat_indep = 75,
  lim_time_indep = 180,
  min_fixes = 3,
  min_duration = 120
)
```

## Arguments

- data:

  A dataframe of any class that is or extends data.frame of one
  individual only. The dataframe must contain at least two spatial
  coordinates, `x` and `y`, and a temporal coordinate, `time`.

- max_speed:

  A numeric value specifying the maximum speed (m/s) between two
  coordinates that would be considered non-transitory

- lim_spat_indep:

  A numeric value of distance in metres of the spatial distance between
  two patches for them to the considered independent.

- lim_time_indep:

  A numeric value of time in minutes of the time difference between two
  patches for them to be considered independent.

- min_fixes:

  The minimum number of fixes for a group of spatially-proximate number
  of points to be considered a preliminary residence patch.

- min_duration:

  The minimum duration (in seconds) for classifying residence patches.

## Value

A data.table that has the added column `patch` as character indicating
the patch ID.

## Author

Pratik R. Gupte, Christine E. Beardsworth, Allert I. Bijleveld &
Johannes Krietsch

## Examples

``` r
# packages
library(tools4watlas)

# load example data
data <- data_example

# calculate residence patches for one red knot
data <- atl_res_patch(
  data[tag == "3038"],
  max_speed = 3, lim_spat_indep = 75, lim_time_indep = 180,
  min_fixes = 3, min_duration = 120
)

# summary of residence patches
data_summary <- atl_res_patch_summary(data)
data_summary
#>        tag  patch nfixes   x_mean x_median  x_start    x_end  y_mean y_median
#>     <char> <char>  <int>    <num>    <num>    <num>    <num>   <num>    <num>
#>  1:   3038      1    856 650146.6 650148.2 650120.1 650110.4 5902396  5902400
#>  2:   3038      2     51 649933.6 649934.3 649953.4 649921.5 5902356  5902357
#>  3:   3038      3    958 650378.5 650378.6 650369.7 650384.2 5902349  5902368
#>  4:   3038      4    831 650263.3 650251.5 650254.9 650313.1 5902162  5902170
#>  5:   3038      5    354 650472.8 650457.9 650403.8 650534.6 5901982  5901997
#>  6:   3038      6    998 650764.3 650765.6 650722.6 650748.1 5901925  5901912
#>  7:   3038      7    426 650805.2 650798.7 650859.0 650766.6 5901891  5901893
#>  8:   3038      8    163 650739.1 650739.3 650739.5 650738.8 5901747  5901747
#>  9:   3038      9    610 650664.2 650676.0 650696.8 650616.4 5901843  5901844
#> 10:   3038     10   1173 650971.4 650995.1 651071.8 650865.5 5901981  5901988
#> 11:   3038     11   1440 650728.6 650728.2 650773.4 650713.5 5901998  5902007
#> 12:   3038     12     85 650883.8 650881.6 650895.4 650871.3 5902117  5902115
#> 13:   3038     13    248 651540.2 651543.1 651556.2 651488.7 5902139  5902134
#> 14:   3038     14     18 651422.3 651423.4 651428.6 651425.3 5902253  5902254
#> 15:   3038     15    115 651406.1 651402.6 651422.3 651401.5 5902383  5902381
#> 16:   3038     16     34 651425.9 651425.7 651423.4 651429.4 5902519  5902517
#> 17:   3038     17    115 651499.6 651501.2 651457.8 651499.6 5903028  5903027
#> 18:   3038     18      3 650605.3 650605.3 650605.3 650605.3 5903017  5903006
#> 19:   3038     19      4 650681.9 650670.3 650716.7 650670.3 5903107  5903107
#> 20:   3038     20      4 651668.5 651668.5 651668.5 651668.5 5903164  5903148
#> 21:   3038     21      3 651686.5 651686.5 651686.5 651686.5 5902868  5902868
#> 22:   3038     22    294 650211.9 650222.3 650216.9 650211.5 5902178  5902191
#> 23:   3038     23    107 650064.2 650064.0 650073.1 650055.9 5902046  5902044
#> 24:   3038     24   1016 650232.7 650236.5 650201.5 650257.9 5902030  5902023
#> 25:   3038     25     81 650422.0 650421.3 650416.9 650430.5 5901725  5901723
#> 26:   3038     26   3038 650572.6 650547.5 650608.5 650317.2 5902113  5902115
#> 27:   3038     27   1072 650155.0 650155.0 650153.7 650159.1 5902363  5902361
#>        tag  patch nfixes   x_mean x_median  x_start    x_end  y_mean y_median
#>     <char> <char>  <int>    <num>    <num>    <num>    <num>   <num>    <num>
#>     y_start   y_end  time_mean time_median time_start   time_end dist_in_patch
#>       <num>   <num>      <num>       <num>      <num>      <num>         <num>
#>  1: 5902400 5902355 1695432685  1695432626 1695430804 1695435091    1378.57243
#>  2: 5902347 5902357 1695435691  1695435685 1695435580 1695435859      75.19836
#>  3: 5902387 5902293 1695437766  1695437799 1695436000 1695439413    1172.57976
#>  4: 5902239 5902078 1695440961  1695440970 1695439443 1695442431     724.39585
#>  5: 5902046 5901906 1695443046  1695443041 1695442446 1695443661     349.04444
#>  6: 5902017 5901835 1695445424  1695445294 1695443709 1695447237    1189.36768
#>  7: 5901867 5901884 1695448082  1695448075 1695447378 1695448778     394.63487
#>  8: 5901750 5901746 1695449062  1695449063 1695448796 1695449321     116.82332
#>  9: 5901821 5901854 1695450417  1695450415 1695449333 1695451466     411.85421
#> 10: 5901909 5902008 1695453536  1695453524 1695451511 1695455507    1032.20247
#> 11: 5901939 5902044 1695457976  1695457989 1695455525 1695460394    1137.05485
#> 12: 5902104 5902115 1695460570  1695460571 1695460421 1695460718      98.76813
#> 13: 5902123 5902184 1695461369  1695461340 1695460904 1695462364     570.45038
#> 14: 5902254 5902249 1695463025  1695463047 1695462823 1695463090      42.21491
#> 15: 5902354 5902417 1695463438  1695463438 1695463216 1695463678     212.72252
#> 16: 5902509 5902530 1695464090  1695464088 1695464020 1695464152      67.50586
#> 17: 5903046 5903028 1695467451  1695467419 1695464800 1695468340     277.56869
#> 18: 5902993 5903051 1695476338  1695476826 1695475134 1695477054      58.62870
#> 19: 5903100 5903115 1695478187  1695478481 1695477297 1695478491      61.24685
#> 20: 5903143 5903217 1695481657  1695481623 1695481410 1695481974      74.04520
#> 21: 5902868 5902868 1695482459  1695482394 1695482391 1695482592       0.00000
#> 22: 5902167 5902185 1695483849  1695483829 1695483336 1695484371     919.86234
#> 23: 5902066 5902047 1695484644  1695484638 1695484470 1695484839     110.82065
#> 24: 5902047 5902023 1695487182  1695487255 1695485244 1695489158     923.60221
#> 25: 5901726 5901741 1695489321  1695489317 1695489188 1695489455      85.59062
#> 26: 5901823 5902230 1695498074  1695497294 1695489479 1695507850    3526.21362
#> 27: 5902362 5902391 1695511807  1695511816 1695509041 1695513594    1197.75829
#>     y_start   y_end  time_mean time_median time_start   time_end dist_in_patch
#>       <num>   <num>      <num>       <num>      <num>      <num>         <num>
#>     dist_bw_patch time_bw_patch disp_in_patch  duration
#>             <num>         <num>         <num>     <num>
#>  1:            NA            NA     45.928638  4286.659
#>  2:     157.24233       488.961     33.422968   278.978
#>  3:     449.10828       140.989     95.183981  3413.729
#>  4:     140.38571        29.997    171.139566  2987.763
#>  5:      96.27647        14.998    191.555615  1214.904
#>  6:     218.34299        47.996    183.077395  3527.720
#>  7:     115.41919       140.989     94.007329  1400.888
#>  8:     136.99063        17.999      3.606106   524.959
#>  9:      85.36514        11.999     87.212108  2132.830
#> 10:     458.67406        44.997    228.708415  3995.684
#> 11:     114.83434        17.999    120.308727  4868.615
#> 12:     191.48906        26.998     26.517958   296.977
#> 13:     684.97307       185.985     91.138087  1460.886
#> 14:      92.45011       458.964      6.553215   266.979
#> 15:     105.18801       125.990     66.914171   461.963
#> 16:      94.28270       341.973     22.195678   131.989
#> 17:     516.25801       647.949     45.630289  3539.722
#> 18:     894.94689      6794.467     58.628698  1919.850
#> 19:     121.63455       242.981     48.732652  1193.906
#> 20:     998.55687      2918.771     74.045195   563.955
#> 21:     349.40222       416.967      0.000000   200.984
#> 22:    1628.57203       743.942     18.739496  1034.918
#> 23:     182.05255        98.992     25.900497   368.970
#> 24:     145.58326       404.968     61.353129  3914.689
#> 25:     336.92942        29.998     20.560332   266.979
#> 26:     195.76701        23.998    500.761579 18370.541
#> 27:     210.06924      1190.905     29.822003  4553.638
#>     dist_bw_patch time_bw_patch disp_in_patch  duration
#>             <num>         <num>         <num>     <num>
```
