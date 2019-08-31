tidymodelsによるモデル構築と運用
===============

Fukuoka.R#15
https://fukuoka-r.connpass.com/event/139211/

[r-wakalang](https://r-wakalang.slack.com/) (日本語RコミュニティのSlackチーム)内にtidymodelsやデータモデリングに関する知見や参考情報を共有するチャンネルがあります。ぜひご参加ください。

[こちらのリンク](https://join.slack.com/t/r-wakalang/shared_invite/enQtMzI3OTUxMjMyMjYwLTlhMzU2MTFhZDlkN2JjNWE5ZjVjODVjZWI5NGI0NGZjY2MzY2E1YTczOWU3YmM0MDY4NzE1NThiNjFjMTIzY2Y)をクリックしてメールアドレスを登録するだけです。

## 再現環境

```r
install.packages(c("remotes", "usethis"))
remotes::install_github("rstudio/renv@0.7.0-9")
usethis::use_course("uribo/190831_fukuokar15")
```

Rprojectが立ち上がったら

```r
renv::restore()
```

### Session Information

<details>

```r
sessioninfo::session_info()
#> ─ Session info ──────────────────────────────────────────────────────────────────────────────────────
#>  setting  value                       
#>  version  R version 3.6.0 (2019-04-26)
#>  os       macOS Mojave 10.14.6        
#>  system   x86_64, darwin18.5.0        
#>  ui       RStudio                     
#>  language En                          
#>  collate  ja_JP.UTF-8                 
#>  ctype    ja_JP.UTF-8                 
#>  tz       Asia/Tokyo                  
#>  date     2019-08-30                  
#> 
#> ─ Packages ──────────────────────────────────────────────────────────────────────────────────────────
#>  !  package       * version    date       lib source                       
#>  P  assertthat      0.2.1      2019-03-21 [?] standard (@0.2.1)            
#>     backports       1.1.4      2019-04-10 [1] standard (@1.1.4)            
#>     base64enc       0.1-3      2015-07-28 [1] standard (@0.1-3)            
#>     base64url       1.4        2018-05-14 [1] CRAN (R 3.6.0)               
#>     bayesplot       1.7.0      2019-05-23 [1] CRAN (R 3.6.0)               
#>     boot            1.3-23     2019-07-05 [1] CRAN (R 3.6.0)               
#>     broom         * 0.5.2      2019-04-07 [1] standard (@0.5.2)            
#>     callr           3.3.1      2019-07-18 [1] standard (@3.3.1)            
#>     class           7.3-15     2019-01-01 [1] standard (@7.3-15)           
#>  P  cli             1.1.0      2019-03-19 [?] standard (@1.1.0)            
#>     codetools       0.2-16     2018-12-24 [1] standard (@0.2-16)           
#>  P  colorspace      1.4-1      2019-03-18 [?] standard (@1.4-1)            
#>     colourpicker    1.0        2017-09-27 [1] CRAN (R 3.6.0)               
#>  P  crayon          1.3.4      2017-09-16 [?] standard (@1.3.4)            
#>     crosstalk       1.0.0      2016-12-21 [1] CRAN (R 3.6.0)               
#>     dials         * 0.0.2      2018-12-09 [1] CRAN (R 3.6.0)               
#>     digest          0.6.20     2019-07-04 [1] standard (@0.6.20)           
#>  P  dplyr         * 0.8.3      2019-07-04 [?] standard (@0.8.3)            
#>     drake         * 7.6.1      2019-08-19 [1] CRAN (R 3.6.0)               
#>     DT              0.8        2019-08-07 [1] CRAN (R 3.6.0)               
#>     dygraphs        1.1.1.6    2018-07-11 [1] CRAN (R 3.6.0)               
#>     fansi           0.4.0      2018-10-05 [1] standard (@0.4.0)            
#>     filelock        1.0.2      2018-10-05 [1] CRAN (R 3.6.0)               
#>     fs              1.3.1      2019-05-06 [1] standard (@1.3.1)            
#>     furrr           0.1.0      2018-05-16 [1] CRAN (R 3.6.0)               
#>     future          1.14.0     2019-07-02 [1] CRAN (R 3.6.0)               
#>     generics        0.0.2      2018-11-29 [1] standard (@0.0.2)            
#>  P  ggplot2       * 3.2.1      2019-08-10 [?] standard (@3.2.1)            
#>     ggridges        0.5.1      2018-09-27 [1] CRAN (R 3.6.0)               
#>     globals         0.12.4     2018-10-11 [1] CRAN (R 3.6.0)               
#>  VP glue            1.3.1.9000 2019-03-12 [?] standard (@1.3.1)            
#>     gower           0.2.1      2019-05-14 [1] standard (@0.2.1)            
#>     gridExtra       2.3        2017-09-09 [1] CRAN (R 3.6.0)               
#>  P  gtable          0.3.0      2019-03-25 [?] standard (@0.3.0)            
#>     gtools          3.8.1      2018-06-26 [1] CRAN (R 3.6.0)               
#>     htmltools       0.3.6      2017-04-28 [1] standard (@0.3.6)            
#>     htmlwidgets     1.3        2018-09-30 [1] CRAN (R 3.6.0)               
#>     httpuv          1.5.1      2019-04-05 [1] CRAN (R 3.6.0)               
#>     igraph          1.2.4.1    2019-04-22 [1] CRAN (R 3.6.0)               
#>     infer         * 0.4.0.1    2019-04-22 [1] CRAN (R 3.6.0)               
#>     inline          0.3.15     2018-05-18 [1] CRAN (R 3.6.0)               
#>     ipred           0.9-9      2019-04-28 [1] standard (@0.9-9)            
#>     janeaustenr     0.1.5      2017-06-10 [1] CRAN (R 3.6.0)               
#>     knitr           1.24       2019-08-08 [1] standard (@1.24)             
#>     labeling        0.3        2014-08-23 [1] standard (@0.3)              
#>     later           0.8.0      2019-02-11 [1] CRAN (R 3.6.0)               
#>     lattice         0.20-38    2018-11-04 [1] standard (@0.20-38)          
#>     lava            1.6.6      2019-08-01 [1] CRAN (R 3.6.0)               
#>  P  lazyeval        0.2.2      2019-03-15 [?] standard (@0.2.2)            
#>     listenv         0.7.0      2018-01-21 [1] CRAN (R 3.6.0)               
#>     lme4            1.1-21     2019-03-05 [1] CRAN (R 3.6.0)               
#>     loo             2.1.0      2019-03-13 [1] CRAN (R 3.6.0)               
#>     lubridate       1.7.4      2018-04-11 [1] standard (@1.7.4)            
#>  P  magrittr        1.5        2014-11-22 [?] standard (@1.5)              
#>     markdown        1.1        2019-08-07 [1] standard (@1.1)              
#>     MASS            7.3-51.4   2019-04-26 [1] standard (@7.3-51.)          
#>     Matrix          1.2-17     2019-03-22 [1] standard (@1.2-17)           
#>     matrixStats     0.54.0     2018-07-23 [1] CRAN (R 3.6.0)               
#>     mime            0.7        2019-06-11 [1] standard (@0.7)              
#>     miniUI          0.1.1.1    2018-05-18 [1] CRAN (R 3.6.0)               
#>     minqa           1.2.4      2014-10-09 [1] CRAN (R 3.6.0)               
#>  P  munsell         0.5.0      2018-06-12 [?] standard (@0.5.0)            
#>     nlme            3.1-141    2019-08-01 [1] standard (@3.1-141)          
#>     nloptr          1.2.1      2018-10-03 [1] CRAN (R 3.6.0)               
#>     nnet            7.3-12     2016-02-02 [1] standard (@7.3-12)           
#>     packrat         0.5.0      2018-11-14 [1] CRAN (R 3.6.0)               
#>     parsnip       * 0.0.3.1    2019-08-06 [1] CRAN (R 3.6.0)               
#>  P  pillar          1.4.2      2019-06-29 [?] standard (@1.4.2)            
#>     pkgbuild        1.0.5      2019-08-26 [1] CRAN (R 3.6.0)               
#>  P  pkgconfig       2.0.2      2018-08-16 [?] standard (@2.0.2)            
#>     plyr            1.8.4      2016-06-08 [1] standard (@1.8.4)            
#>     prettyunits     1.0.2      2015-07-13 [1] standard (@1.0.2)            
#>     pROC            1.15.3     2019-07-21 [1] CRAN (R 3.6.0)               
#>     processx        3.4.1      2019-07-18 [1] standard (@3.4.1)            
#>     prodlim         2018.04.18 2018-04-18 [1] standard (@2018.04)          
#>     promises        1.0.1      2018-04-13 [1] CRAN (R 3.6.0)               
#>     ps              1.3.0      2018-12-21 [1] standard (@1.3.0)            
#>  P  purrr         * 0.3.2      2019-03-15 [?] standard (@0.3.2)            
#>  P  R6              2.4.0      2019-02-14 [?] standard (@2.4.0)            
#>  P  randomForest    4.6-14     2018-03-25 [?] CRAN (R 3.6.0)               
#>  P  ranger          0.11.2     2019-03-07 [?] CRAN (R 3.6.0)               
#>  P  Rcpp            1.0.2      2019-07-25 [?] standard (@1.0.2)            
#>     recipes       * 0.1.6      2019-07-02 [1] standard (@0.1.6)            
#>     renv            0.7.0-9    2019-08-29 [1] github (rstudio/renv@d368c29)
#>     reprex          0.3.0      2019-05-16 [1] standard (@0.3.0)            
#>     reshape2        1.4.3      2017-12-11 [1] standard (@1.4.3)            
#>  P  rlang           0.4.0      2019-06-25 [?] standard (@0.4.0)            
#>     rpart           4.1-15     2019-04-12 [1] standard (@4.1-15)           
#>     rsample       * 0.0.5      2019-07-12 [1] CRAN (R 3.6.0)               
#>     rsconnect       0.8.15     2019-07-22 [1] CRAN (R 3.6.0)               
#>     rstan           2.19.2     2019-07-09 [1] CRAN (R 3.6.0)               
#>     rstanarm        2.18.2     2018-11-10 [1] CRAN (R 3.6.0)               
#>     rstantools      1.5.1      2018-08-22 [1] CRAN (R 3.6.0)               
#>  P  rstudioapi      0.10       2019-03-19 [?] standard (@0.10)             
#>  P  scales        * 1.0.0      2018-08-09 [?] standard (@1.0.0)            
#>  R  sessioninfo     1.1.1      <NA>       [?] <NA>                         
#>     shiny           1.3.2      2019-04-22 [1] CRAN (R 3.6.0)               
#>     shinyjs         1.0        2018-01-08 [1] CRAN (R 3.6.0)               
#>     shinystan       2.5.0      2018-05-01 [1] CRAN (R 3.6.0)               
#>     shinythemes     1.1.2      2018-11-06 [1] CRAN (R 3.6.0)               
#>     SnowballC       0.6.0      2019-01-15 [1] CRAN (R 3.6.0)               
#>     StanHeaders     2.18.1-10  2019-06-14 [1] CRAN (R 3.6.0)               
#>     storr           1.2.1      2018-10-18 [1] CRAN (R 3.6.0)               
#>     stringi         1.4.3      2019-03-12 [1] standard (@1.4.3)            
#>     stringr         1.4.0      2019-02-10 [1] standard (@1.4.0)            
#>     survival        2.44-1.1   2019-04-01 [1] standard (@2.44-1.)          
#>     threejs         0.3.1      2017-08-13 [1] CRAN (R 3.6.0)               
#>  P  tibble        * 2.1.3      2019-06-06 [?] standard (@2.1.3)            
#>     tidymodels    * 0.0.2      2018-11-27 [1] CRAN (R 3.6.0)               
#>     tidyposterior   0.0.2      2018-11-15 [1] CRAN (R 3.6.0)               
#>     tidypredict     0.4.2      2019-07-15 [1] CRAN (R 3.6.0)               
#>     tidyr         * 0.8.3      2019-03-01 [1] standard (@0.8.3)            
#>  P  tidyselect    * 0.2.5      2018-10-11 [?] standard (@0.2.5)            
#>     tidytext        0.2.2      2019-07-29 [1] CRAN (R 3.6.0)               
#>     timeDate        3043.102   2018-02-21 [1] standard (@3043.10)          
#>     tokenizers      0.2.1      2018-03-29 [1] CRAN (R 3.6.0)               
#>     txtq            0.1.5      2019-08-19 [1] CRAN (R 3.6.0)               
#>     utf8            1.1.4      2018-05-24 [1] standard (@1.1.4)            
#>     vctrs           0.2.0      2019-07-05 [1] standard (@0.2.0)            
#>  P  withr           2.1.2      2018-03-15 [?] standard (@2.1.2)            
#>     xfun            0.9        2019-08-21 [1] CRAN (R 3.6.0)               
#>     xtable          1.8-4      2019-04-21 [1] CRAN (R 3.6.0)               
#>     xts             0.11-2     2018-11-05 [1] CRAN (R 3.6.0)               
#>     yardstick     * 0.0.4      2019-08-26 [1] CRAN (R 3.6.0)               
#>     zeallot         0.1.0      2018-01-28 [1] standard (@0.1.0)            
#>     zoo             1.8-6      2019-05-28 [1] CRAN (R 3.6.0)               
#> 
#> [1] /Users/uri/Documents/slides/190831_fukuokar15/renv/library/R-3.6/x86_64-apple-darwin18.5.0
#> [2] /private/var/folders/ty/j83j79pj6_s97qx4vlylnzzw0000gn/T/RtmplXNa3X/renv-system-library
#> 
#>  V ── Loaded and on-disk version mismatch.
#>  P ── Loaded and on-disk path mismatch.
#>  R ── Package was removed from disk.#> 
```

</details>


## 参考文献・URL

- Max Kuhn and Kjell Johnson (2019). [Feature Engineering and Selection: A Practical Approach for Predictive Models (CRC Press)](https://www.crcpress.com/Feature-Engineering-and-Selection-A-Practical-Approach-for-Predictive-Models/Kuhn-Johnson/p/book/9781138079229)
- [データ分析における特徴量エンジニアリング / feature engineering recipes](https://speakerdeck.com/s_uryu/feature-engineering-recipes)
- [実践的データサイエンス](https://uribo.github.io/practical-ds/intro)
- [dpp-cookbook | Baked your data :)[https://uribo.github.io/dpp-cookbook/]
- [A Gentle Introduction to tidymodels · R Views](https://rviews.rstudio.com/2019/06/19/a-gentle-intro-to-tidymodels/)
- [Caret and Tidymodels | Ryan Johnson](https://ryjohnson09.netlify.com/post/caret-and-tidymodels/)
- [tidymodelsによるtidyな機械学習フロー（その1） - Dropout](https://dropout009.hatenablog.com/entry/2019/01/06/124932)
- [tidymodelsによるtidyな機械学習フロー（その2：Cross Varidation） - Dropout](https://dropout009.hatenablog.com/entry/2019/01/09/214233)
- [Rでのナウなデータ分割のやり方: rsampleパッケージによる交差検証 - 株式会社ホクソエムのブログ](https://blog.hoxo-m.com/entry/2019/06/08/220307)
- [モデルで扱うデータの前処理をrecipesで行う - 株式会社ホクソエムのブログ](https://blog.hoxo-m.com/entry/2018/08/26/161144)
