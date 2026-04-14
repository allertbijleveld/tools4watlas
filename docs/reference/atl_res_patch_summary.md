# Summary of patch data

Computes summary statistics of movement data grouped by patches for each
individual tag. Calculates spatial and temporal summaries within each
patch, distances traveled inside patches, distances and time intervals
between patches, displacement within patches, and patch duration.
Additional user-specified summary variables and functions can also be
applied dynamically.

## Usage

``` r
atl_res_patch_summary(data, summary_variables = c(), summary_functions = c())
```

## Arguments

- data:

  A data.frame or data.table containing movement data. Must include
  columns: `tag` (ID), `x`, `y` (coords), `time` (timestamp), and
  `patch` (patch ID).

- summary_variables:

  Character vector of variable names in `data` for additional summaries.
  Variables should be numeric or compatible with the summary functions.

- summary_functions:

  Character vector of function names to apply to each variable in
  `summary_variables`. Functions must work on numeric vectors (e.g.,
  "mean" or "median").

## Value

A data.table with one row per `tag` and `patch` containing:

- `nfixes`: Number of fixes in the patch.

- `x_mean`, `x_median`, `x_start`, `x_end`: Summary stats of x.

- `y_mean`, `y_median`, `y_start`, `y_end`: Summary stats of y.

- `time_mean`, `time_median`, `time_start`, `time_end`: Summary stats of
  time.

- Additional summaries from `summary_variables` and `summary_functions`.

- `dist_start_end`: Straight-line (in m) distance between start and end
  of patch.

- `dist_in_patch`: Total distance (in m) travelled within the patch.

- `dist_bw_patch`: Distance (in m) between end of previous and start of
  current patch.

- `time_bw_patch`: Time (in sec) elapsed between end of previous and
  start of current patch.

- `disp_in_patch`: Straight-line (in m) displacement between start and
  end of patch.

- `duration`: Duration spent (in sec) within the patch.

## Details

Converts input data to data.table if needed and filters out rows with
missing patch assignments. All summaries are calculated by `tag` and
`patch`.Distance calculations use Euclidean distance in x-y coordinate
space.

## Author

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
#>  1:   3038      1    218 650118.2 650143.9 650120.1 649896.0 5902387  5902399
#>  2:   3038      2    204 650378.7 650378.4 650372.3 650384.2 5902349  5902368
#>  3:   3038      3    172 650263.5 650251.5 650254.3 650313.1 5902163  5902170
#>  4:   3038      4     67 650471.0 650457.7 650410.7 650530.4 5901984  5901998
#>  5:   3038      5    190 650765.0 650765.1 650722.6 650748.1 5901930  5901928
#>  6:   3038      6     90 650804.9 650799.0 650857.1 650766.2 5901892  5901893
#>  7:   3038      7     27 650740.2 650739.5 650766.6 650738.8 5901749  5901747
#>  8:   3038      8    103 650661.8 650673.3 650696.7 650620.4 5901843  5901845
#>  9:   3038      9    210 650965.7 650994.0 651071.8 650865.5 5901982  5901989
#> 10:   3038     10    257 650728.6 650728.2 650761.8 650705.0 5902000  5902013
#> 11:   3038     11     15 650883.6 650881.3 650896.3 650871.3 5902117  5902115
#> 12:   3038     12     73 651514.7 651536.8 651557.2 651428.6 5902163  5902148
#> 13:   3038     13     46 651415.0 651412.4 651422.3 651432.0 5902456  5902446
#> 14:   3038     14     21 651498.8 651500.7 651457.8 651496.5 5903028  5903027
#> 15:   3038     15      3 650723.2 650743.0 650756.3 650670.3 5903119  5903114
#> 16:   3038     16     54 650213.1 650223.0 650259.9 650216.7 5902177  5902191
#> 17:   3038     17     38 650062.7 650063.7 650080.3 650055.9 5902048  5902043
#> 18:   3038     18    201 650232.5 650236.3 650180.9 650257.9 5902030  5902023
#> 19:   3038     19     19 650421.0 650421.3 650400.5 650425.8 5901725  5901723
#> 20:   3038     20    603 650577.0 650576.7 650608.5 650304.4 5902112  5902115
#> 21:   3038     21    201 650155.1 650155.2 650152.0 650159.6 5902363  5902361
#>        tag  patch nfixes   x_mean x_median  x_start    x_end  y_mean y_median
#>     <char> <char>  <int>    <num>    <num>    <num>    <num>   <num>    <num>
#>     y_start   y_end           time_mean         time_median          time_start
#>       <num>   <num>              <POSc>              <POSc>              <POSc>
#>  1: 5902400 5902365 2023-09-23 01:39:22 2023-09-23 01:36:02 2023-09-23 01:00:06
#>  2: 5902392 5902293 2023-09-23 02:56:27 2023-09-23 02:56:52 2023-09-23 02:26:48
#>  3: 5902235 5902078 2023-09-23 03:49:05 2023-09-23 03:49:28 2023-09-23 03:24:06
#>  4: 5902046 5901908 2023-09-23 04:23:52 2023-09-23 04:23:38 2023-09-23 04:14:18
#>  5: 5902017 5901835 2023-09-23 05:02:27 2023-09-23 04:58:34 2023-09-23 04:35:08
#>  6: 5901869 5901886 2023-09-23 05:47:59 2023-09-23 05:47:29 2023-09-23 05:36:32
#>  7: 5901802 5901746 2023-09-23 06:03:59 2023-09-23 06:03:56 2023-09-23 05:59:47
#>  8: 5901822 5901828 2023-09-23 06:27:29 2023-09-23 06:27:32 2023-09-23 06:09:02
#>  9: 5901909 5902008 2023-09-23 07:20:25 2023-09-23 07:21:42 2023-09-23 06:45:11
#> 10: 5901944 5902041 2023-09-23 08:34:29 2023-09-23 08:36:55 2023-09-23 07:52:13
#> 11: 5902112 5902117 2023-09-23 09:16:10 2023-09-23 09:16:01 2023-09-23 09:13:49
#> 12: 5902123 5902264 2023-09-23 09:34:52 2023-09-23 09:31:52 2023-09-23 09:19:25
#> 13: 5902354 5902591 2023-09-23 10:09:23 2023-09-23 10:08:50 2023-09-23 10:00:16
#> 14: 5903046 5903014 2023-09-23 11:10:06 2023-09-23 11:10:22 2023-09-23 10:26:40
#> 15: 5903136 5903114 2023-09-23 14:01:20 2023-09-23 13:54:45 2023-09-23 13:54:27
#> 16: 5902163 5902187 2023-09-23 15:43:51 2023-09-23 15:43:32 2023-09-23 15:35:23
#> 17: 5902081 5902018 2023-09-23 15:57:43 2023-09-23 15:57:32 2023-09-23 15:53:11
#> 18: 5902042 5902023 2023-09-23 16:39:36 2023-09-23 16:40:38 2023-09-23 16:04:11
#> 19: 5901726 5901739 2023-09-23 17:15:05 2023-09-23 17:14:59 2023-09-23 17:13:05
#> 20: 5901823 5902230 2023-09-23 19:34:56 2023-09-23 19:13:25 2023-09-23 17:17:59
#> 21: 5902365 5902389 2023-09-23 23:30:27 2023-09-23 23:30:54 2023-09-23 23:00:39
#>     y_start   y_end           time_mean         time_median          time_start
#>       <num>   <num>              <POSc>              <POSc>              <POSc>
#>                time_end dist_start_end dist_in_patch dist_bw_patch
#>                  <POSc>          <num>         <num>         <num>
#>  1: 2023-09-23 02:25:42      226.85244    1281.06282            NA
#>  2: 2023-09-23 03:23:33       99.74456     771.87479     477.14838
#>  3: 2023-09-23 04:13:51      167.43290     507.29482     142.59999
#>  4: 2023-09-23 04:34:11      182.98565     267.17182     102.65534
#>  5: 2023-09-23 05:33:50      183.07740     820.64195     221.05409
#>  6: 2023-09-23 05:59:29       92.57042     267.24318     113.96041
#>  7: 2023-09-23 06:08:38       62.36975     121.87841      84.19272
#>  8: 2023-09-23 06:44:29       76.54410     299.12699      86.36810
#>  9: 2023-09-23 07:51:46      228.70842     745.23055     458.65180
#> 10: 2023-09-23 09:12:58      112.48659     673.26698     122.15609
#> 11: 2023-09-23 09:18:34       25.61180      65.69697     203.97417
#> 12: 2023-09-23 09:59:49      191.23129     700.00219     685.93767
#> 13: 2023-09-23 10:19:46      237.67675     478.78933      89.64572
#> 14: 2023-09-23 11:25:42       49.83545     248.27591     455.41284
#> 15: 2023-09-23 14:14:48       88.74901     103.17843     750.03092
#> 16: 2023-09-23 15:52:41       49.42532     809.71532    1036.01996
#> 17: 2023-09-23 16:02:35       67.17012     241.29544     172.67229
#> 18: 2023-09-23 17:12:38       79.28867     632.14064     127.23215
#> 19: 2023-09-23 17:17:23       28.27475      73.40384     329.23561
#> 20: 2023-09-23 22:24:12      508.34358    2464.47436     201.06877
#> 21: 2023-09-23 23:59:39       26.08165     756.04426     203.33747
#>                time_end dist_start_end dist_in_patch dist_bw_patch
#>                  <POSc>          <num>         <num>         <num>
#>     time_bw_patch disp_in_patch  duration
#>             <num>         <num>     <num>
#>  1:            NA     226.85244  5135.592
#>  2:        65.994      99.74456  3404.730
#>  3:        32.997     167.43290  2984.763
#>  4:        26.997     182.98565  1193.905
#>  5:        56.996     183.07740  3521.721
#>  6:       161.987      92.57042  1376.890
#>  7:        17.999      62.36975   530.958
#>  8:        23.998      76.54410  2126.831
#>  9:        41.997     228.70842  3995.684
#> 10:        26.998     112.48659  4844.617
#> 11:        50.996      25.61180   284.978
#> 12:        50.996     191.23129  2423.810
#> 13:        26.998     237.67675  1169.907
#> 14:       413.967      49.83545  3542.722
#> 15:      8924.300      88.74901  1220.904
#> 16:      4835.619      49.42532  1037.918
#> 17:        29.998      67.17012   563.955
#> 18:        95.993      79.28867  4106.673
#> 19:        26.998      28.27475   257.980
#> 20:        35.997     508.34358 18373.541
#> 21:      2186.826      26.08165  3539.718
#>     time_bw_patch disp_in_patch  duration
#>             <num>         <num>     <num>
```
