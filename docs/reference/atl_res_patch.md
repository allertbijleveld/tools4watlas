# Construct residence patches from position data

A cleaned movement track of one individual at a time can be classified
into residence patches using the function `atl_res_patch`. The function
expects a specific organisation of the data: there should be at least
the following columns, `x`, `y`, and `time`, corresponding to the
coordinates, and the time as `POSIXct`. `atl_res_patch` requires only
three parameters: (1) the maximum speed threshold between localizations
(called `max_speed`), (2) the distance threshold between proto-patches
of positions (called `lim_spat_indep`), and (3) the time interval
between proto-patches (called `lim_time_indep`). As the code initially
only looks at proto-patches, at the end it checks if positions within
patches are interrupted by short flights (with a distance larger than
`lim_spat_indep` to the last position of the proto-patch before and
first position of the next proto-patch). If there are more than
`min_fixes` in this bout, then the patch will be split. If there are
less, we assume this to be single outliers and only assign no patch ID

## Usage

``` r
atl_res_patch(
  data,
  max_speed = 3,
  lim_spat_indep = 75,
  lim_time_indep = 180,
  min_fixes = 2,
  min_duration = 60
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
  min_fixes = 2, min_duration = 60
)

# summary of residence patches
data_summary <- atl_res_patch_summary(data)
data_summary
#>      species    tag  patch nfixes   x_mean x_median  x_start    x_end  y_mean
#>       <char> <char> <char>  <int>    <num>    <num>    <num>    <num>   <num>
#>  1: red knot   3038      1    218 650118.2 650143.9 650120.1 649896.0 5902387
#>  2: red knot   3038      2    204 650378.7 650378.4 650372.3 650384.2 5902349
#>  3: red knot   3038      3    172 650263.5 650251.5 650254.3 650313.1 5902163
#>  4: red knot   3038      4     67 650471.0 650457.7 650410.7 650530.4 5901984
#>  5: red knot   3038      5    197 650763.8 650764.5 650722.6 650729.8 5901924
#>  6: red knot   3038      6     90 650804.9 650799.0 650857.1 650766.2 5901892
#>  7: red knot   3038      7     27 650740.2 650739.5 650766.6 650738.8 5901749
#>  8: red knot   3038      8    103 650661.8 650673.3 650696.7 650620.4 5901843
#>  9: red knot   3038      9    210 650965.7 650994.0 651071.8 650865.5 5901982
#> 10: red knot   3038     10    257 650728.6 650728.2 650761.8 650705.0 5902000
#> 11: red knot   3038     11     15 650883.6 650881.3 650896.3 650871.3 5902117
#> 12: red knot   3038     12     73 651514.7 651536.8 651557.2 651428.6 5902163
#> 13: red knot   3038     13     46 651415.0 651412.4 651422.3 651432.0 5902456
#> 14: red knot   3038     14     21 651498.8 651500.7 651457.8 651496.5 5903028
#> 15: red knot   3038     15      3 650865.7 650860.7 650924.7 650811.8 5902937
#> 16: red knot   3038     16      3 650723.2 650743.0 650756.3 650670.3 5903119
#> 17: red knot   3038     17      3 651631.0 651626.9 651644.1 651622.0 5902820
#> 18: red knot   3038     18     10 650218.6 650214.1 650259.9 650213.1 5902162
#> 19: red knot   3038     19     37 650228.3 650227.6 650251.0 650216.7 5902192
#> 20: red knot   3038     20     38 650062.7 650063.7 650080.3 650055.9 5902048
#> 21: red knot   3038     21    201 650232.5 650236.3 650180.9 650257.9 5902030
#> 22: red knot   3038     22     19 650421.0 650421.3 650400.5 650425.8 5901725
#> 23: red knot   3038     23    603 650577.0 650576.7 650608.5 650304.4 5902112
#> 24: red knot   3038     24    201 650155.1 650155.2 650152.0 650159.6 5902363
#>      species    tag  patch nfixes   x_mean x_median  x_start    x_end  y_mean
#>       <char> <char> <char>  <int>    <num>    <num>    <num>    <num>   <num>
#>     y_median y_start   y_end           time_mean         time_median
#>        <num>   <num>   <num>              <POSc>              <POSc>
#>  1:  5902399 5902400 5902365 2023-09-23 01:39:22 2023-09-23 01:36:02
#>  2:  5902368 5902392 5902293 2023-09-23 02:56:27 2023-09-23 02:56:52
#>  3:  5902170 5902235 5902078 2023-09-23 03:49:05 2023-09-23 03:49:28
#>  4:  5901998 5902046 5901908 2023-09-23 04:23:52 2023-09-23 04:23:38
#>  5:  5901923 5902017 5901775 2023-09-23 05:03:36 2023-09-23 04:59:44
#>  6:  5901893 5901869 5901886 2023-09-23 05:47:59 2023-09-23 05:47:29
#>  7:  5901747 5901802 5901746 2023-09-23 06:03:59 2023-09-23 06:03:56
#>  8:  5901845 5901822 5901828 2023-09-23 06:27:29 2023-09-23 06:27:32
#>  9:  5901989 5901909 5902008 2023-09-23 07:20:25 2023-09-23 07:21:42
#> 10:  5902013 5901944 5902041 2023-09-23 08:34:29 2023-09-23 08:36:55
#> 11:  5902115 5902112 5902117 2023-09-23 09:16:10 2023-09-23 09:16:01
#> 12:  5902148 5902123 5902264 2023-09-23 09:34:52 2023-09-23 09:31:52
#> 13:  5902446 5902354 5902591 2023-09-23 10:09:23 2023-09-23 10:08:50
#> 14:  5903027 5903046 5903014 2023-09-23 11:10:06 2023-09-23 11:10:22
#> 15:  5902926 5902926 5902960 2023-09-23 12:48:19 2023-09-23 12:48:12
#> 16:  5903114 5903136 5903114 2023-09-23 14:01:20 2023-09-23 13:54:45
#> 17:  5902819 5902823 5902819 2023-09-23 15:17:11 2023-09-23 15:17:11
#> 18:  5902161 5902163 5902159 2023-09-23 15:36:55 2023-09-23 15:36:58
#> 19:  5902192 5902192 5902187 2023-09-23 15:46:35 2023-09-23 15:46:26
#> 20:  5902043 5902081 5902018 2023-09-23 15:57:43 2023-09-23 15:57:32
#> 21:  5902023 5902042 5902023 2023-09-23 16:39:36 2023-09-23 16:40:38
#> 22:  5901723 5901726 5901739 2023-09-23 17:15:05 2023-09-23 17:14:59
#> 23:  5902115 5901823 5902230 2023-09-23 19:34:56 2023-09-23 19:13:25
#> 24:  5902361 5902365 5902389 2023-09-23 23:30:27 2023-09-23 23:30:54
#>     y_median y_start   y_end           time_mean         time_median
#>        <num>   <num>   <num>              <POSc>              <POSc>
#>              time_start            time_end dist_start_end dist_in_patch
#>                  <POSc>              <POSc>          <num>         <num>
#>  1: 2023-09-23 01:00:06 2023-09-23 02:25:42      226.85244    1281.06282
#>  2: 2023-09-23 02:26:48 2023-09-23 03:23:33       99.74456     771.87479
#>  3: 2023-09-23 03:24:06 2023-09-23 04:13:51      167.43290     507.29482
#>  4: 2023-09-23 04:14:18 2023-09-23 04:34:11      182.98565     267.17182
#>  5: 2023-09-23 04:35:08 2023-09-23 05:35:53      241.91015     902.15210
#>  6: 2023-09-23 05:36:32 2023-09-23 05:59:29       92.57042     267.24318
#>  7: 2023-09-23 05:59:47 2023-09-23 06:08:38       62.36975     121.87841
#>  8: 2023-09-23 06:09:02 2023-09-23 06:44:29       76.54410     299.12699
#>  9: 2023-09-23 06:45:11 2023-09-23 07:51:46      228.70842     745.23055
#> 10: 2023-09-23 07:52:13 2023-09-23 09:12:58      112.48659     673.26698
#> 11: 2023-09-23 09:13:49 2023-09-23 09:18:34       25.61180      65.69697
#> 12: 2023-09-23 09:19:25 2023-09-23 09:59:49      191.23129     700.00219
#> 13: 2023-09-23 10:00:16 2023-09-23 10:19:46      237.67675     478.78933
#> 14: 2023-09-23 10:26:40 2023-09-23 11:25:42       49.83545     248.27591
#> 15: 2023-09-23 12:47:39 2023-09-23 12:49:06      117.95871     123.62149
#> 16: 2023-09-23 13:54:27 2023-09-23 14:14:48       88.74901     103.17843
#> 17: 2023-09-23 15:16:17 2023-09-23 15:18:05       22.53865      22.82717
#> 18: 2023-09-23 15:35:23 2023-09-23 15:38:14       46.93707      77.42522
#> 19: 2023-09-23 15:40:29 2023-09-23 15:52:41       34.77431      91.59222
#> 20: 2023-09-23 15:53:11 2023-09-23 16:02:35       67.17012     241.29544
#> 21: 2023-09-23 16:04:11 2023-09-23 17:12:38       79.28867     632.14064
#> 22: 2023-09-23 17:13:05 2023-09-23 17:17:23       28.27475      73.40384
#> 23: 2023-09-23 17:17:59 2023-09-23 22:24:12      508.34358    2464.47436
#> 24: 2023-09-23 23:00:39 2023-09-23 23:59:39       26.08165     756.04426
#>              time_start            time_end dist_start_end dist_in_patch
#>                  <POSc>              <POSc>          <num>         <num>
#>     dist_bw_patch time_bw_patch disp_in_patch  duration
#>             <num>         <num>         <num>     <num>
#>  1:            NA            NA     226.85244  5135.592
#>  2:     477.14838        65.994      99.74456  3404.730
#>  3:     142.59999        32.997     167.43290  2984.763
#>  4:     102.65534        26.997     182.98565  1193.905
#>  5:     221.05409        56.996     241.91015  3644.711
#>  6:     158.11922        38.997      92.57042  1376.890
#>  7:      84.19272        17.999      62.36975   530.958
#>  8:      86.36810        23.998      76.54410  2126.831
#>  9:     458.65180        41.997     228.70842  3995.684
#> 10:     122.15609        26.998     112.48659  4844.617
#> 11:     203.97417        50.996      25.61180   284.978
#> 12:     685.93767        50.996     191.23129  2423.810
#> 13:      89.64572        26.998     237.67675  1169.907
#> 14:     455.41284       413.967      49.83545  3542.722
#> 15:     578.58853      4916.614     117.95871    86.994
#> 16:     184.20630      3920.692      88.74901  1220.904
#> 17:    1016.23017      3689.710      22.53865   107.992
#> 18:    1512.01045      1037.917      46.93707   170.987
#> 19:      50.62455       134.989      34.77431   731.942
#> 20:     172.67229        29.998      67.17012   563.955
#> 21:     127.23215        95.993      79.28867  4106.673
#> 22:     329.23561        26.998      28.27475   257.980
#> 23:     201.06877        35.997     508.34358 18373.541
#> 24:     203.33747      2186.826      26.08165  3539.718
#>     dist_bw_patch time_bw_patch disp_in_patch  duration
#>             <num>         <num>         <num>     <num>
```
