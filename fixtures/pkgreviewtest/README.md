
<!-- README.md is generated from README.Rmd. Please edit that file -->

# pkgreviewtest

<!-- badges: start -->

<!-- badges: end -->

The pkgreviewtest package provides water point observations from four
Swiss regions. Each observation records the water source type, the
functional status of the water point, the installation date, and the
number of people using it. The data support exploratory analyses of
water point functionality and coverage. This package is a fixture used
to test the openwashdata package review workflow.

The data are synthetic: they were generated deterministically by the
openwashdata team with `make_pkgreviewtest.R` in
[openwashdata/pkgreview](https://github.com/openwashdata/pkgreview) in
July 2026, cover four Swiss regions, and carry no license or permission
constraints from any source data because no external source exists.

## Installation

You can install the development version of pkgreviewtest from GitHub
with:

``` r
# install.packages("devtools")
devtools::install_github("openwashdata/pkgreviewtest")
```

## Download

Non-R users can download the data directly:

- [pkgreviewtest.csv](https://github.com/openwashdata/pkgreview/raw/main/fixtures/pkgreviewtest/inst/extdata/pkgreviewtest.csv)
- [pkgreviewtest.xlsx](https://github.com/openwashdata/pkgreview/raw/main/fixtures/pkgreviewtest/inst/extdata/pkgreviewtest.xlsx)

## Data

The package provides access to one dataset, `pkgreviewtest`.

``` r
library(pkgreviewtest)
```

### pkgreviewtest

The dataset `pkgreviewtest` has 30 observations and 10 variables.

``` r
pkgreviewtest |>
  head(3)
#>       id region      waterSource         status installation_date users_count
#> 1 WP-001 Genève        rainwater     functional        2018-03-11         377
#> 2 WP-002   Bern protected spring Non-Functional        2020-09-06          70
#> 3 WP-003  Basel    hand-dug well     functional        30/10/2021         269
#>        owner_phone women_users latitude longitude
#> 1 +41 79 137 11 23         150    46.27      6.31
#> 2 +41 79 174 22 46          28    46.34      6.42
#> 3 +41 79 211 33 69         107    46.41      6.53
```

For an overview of the variable names, see the following table.

<div style="border: 1px solid #ddd; padding: 0px; overflow-y: scroll; height:200px; ">

<table class="table table-striped" style="margin-left: auto; margin-right: auto;">

<thead>

<tr>

<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">

variable_name
</th>

<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">

variable_type
</th>

<th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;">

description
</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

id
</td>

<td style="text-align:left;">

character
</td>

<td style="text-align:left;">

Water point identifier
</td>

</tr>

<tr>

<td style="text-align:left;">

region
</td>

<td style="text-align:left;">

character
</td>

<td style="text-align:left;">

Region where the water point is located
</td>

</tr>

<tr>

<td style="text-align:left;">

waterSource
</td>

<td style="text-align:left;">

character
</td>

<td style="text-align:left;">

Type of water source
</td>

</tr>

<tr>

<td style="text-align:left;">

status
</td>

<td style="text-align:left;">

character
</td>

<td style="text-align:left;">

NA
</td>

</tr>

<tr>

<td style="text-align:left;">

installation_date
</td>

<td style="text-align:left;">

character
</td>

<td style="text-align:left;">

Date the water point was installed
</td>

</tr>

<tr>

<td style="text-align:left;">

users_count
</td>

<td style="text-align:left;">

integer
</td>

<td style="text-align:left;">

TODO
</td>

</tr>

<tr>

<td style="text-align:left;">

owner_phone
</td>

<td style="text-align:left;">

character
</td>

<td style="text-align:left;">

Phone number of the water point owner
</td>

</tr>

<tr>

<td style="text-align:left;">

women_users
</td>

<td style="text-align:left;">

integer
</td>

<td style="text-align:left;">

Number of women among the water point users
</td>

</tr>

<tr>

<td style="text-align:left;">

latitude
</td>

<td style="text-align:left;">

numeric
</td>

<td style="text-align:left;">

Latitude of the water point in decimal degrees
</td>

</tr>

<tr>

<td style="text-align:left;">

longitude
</td>

<td style="text-align:left;">

numeric
</td>

<td style="text-align:left;">

Longitude of the water point in decimal degrees
</td>

</tr>

</tbody>

</table>

</div>

## Example

``` r
library(ggplot2)

ggplot(pkgreviewtest, aes(x = region)) +
  geom_bar(fill = "steelblue") +
  labs(
    title = "Water points per region",
    x = "Region",
    y = "Number of water points"
  ) +
  theme_minimal()
```

<img src="man/figures/README-fig-users-1.png" alt="Bar chart of the number of water points per region." width="100%" />

The bar chart in figure `fig-users` shows the number of observed water
points in each of the four regions.

## License

Data are available as [MIT](https://opensource.org/license/mit).

## Citation

Please cite this package using:

``` r
citation("pkgreviewtest")
#> To cite package 'pkgreviewtest' in publications use:
#> 
#>   Lastname F (2026). "pkgreviewtest: Water Point Observations for
#>   Review Workflow Testing."
#>   <https://github.com/openwashdata/pkgreviewtest>.
#> 
#> A BibTeX entry for LaTeX users is
#> 
#>   @Misc{,
#>     title = {pkgreviewtest: Water Point Observations for Review Workflow Testing},
#>     author = {Firstname Lastname},
#>     year = {2026},
#>     url = {https://github.com/openwashdata/pkgreviewtest},
#>     abstract = {Water point observations from four Swiss regions, including water source type, functional status, installation date, and number of users.},
#>   }
```
