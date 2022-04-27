# CRAN Explorer

### Grabbed as template from https://github.com/rstudio/shiny-gallery/tree/master/genome-browser

---

- App on gallery: https://gallery.shinyapps.io/genome_browser

---

## App description
 this is an example change
Example from [here](https://shiny.rstudio.com/gallery/genome-browser.html)
Explore CRAN packages in an interactive R Shiny app. You can see the application in action on shinyapps.io: [gallery.shinyapps.io/cran-explorer](https://gallery.shinyapps.io/cran-explorer/).

The goal of this project is to demonstrate the development of a complete data service entirely written in the statistical programming language R. Besides this web application, the project includes the creation of a data refresh process (also written in R) that runs inside an AWS Docker container on a daily schedule. Additionally, efforts were made to develop this project in a reproducible way by controlling the operating environmentand the used R version (through Docker containers), a complete list of all required R packages and their specific versions (through `packrat`) with the intention to  promote collaborative development and to reduce the friction of the setup process of R projects in heterogeneous development environments.

## Shiny app

This web application is written using the [R Shiny](https://shiny.rstudio.com/) web framework. It demonstrates the use of custom HTML templates in Shiny apps to create a fancy user experience. The theme used in this app is made by [Colorlib](https://colorlib.com). The app was developed with best Shiny practices in mind, e.g. the use of Shiny modules. In total about 1,100 lines of code were written for this app in less than 80 hours. This time included app ideation and all required research of data sources, data preparation and its operationalisation, app development, design and how to best present the information.


## Setup development environment

The development environment of this project is encapsulated in a Docker container.



1. move into the main directory `cd MGT6203-GRP-PROJECT`
2. Assuming the user has installed R, RStudio, and  `renv` 
  
```R
install.packages("renv")
```

**_NOTE:_** **_If the following error with occurs, resolve with the following: `install.packages("RcppArmadillo", dependencies = T)`_**

**_If using this app in linux (with an apt package manager) or Mac, install the following: r-cran-rcpparmadillo, libblas-dev, liblapack-dev, libcurl4-openssl-dev libxml2-dev additionally, ensure on linux the following command is run: `sudo ln -s /usr/lib/x86_64-linux-gnu/libgfortran.so.3 /usr/lib/x86_64-linux-gnu/libgfortran.so`_**

(Docker Container to come soon!)
1. Make docker run without sudo
    ```
    sudo groupadd docker
    sudo usermod -aG docker $USER
    ```
    Log out and log back in so that your group membership is re-evaluated
2. Clone the GIT repository
    ```
    git clone https://github.com/nz-stefan/cran-explorer.git
    ```
3. Setup development Docker container
    ```
    cd cran-explorer
    bin/setup-environment.sh
    ```
    You should see lots of container build messages
4. Spin up the container
    ```
    bin/start_rstudio.sh
    ```
5. Open [http://localhost:8787](http://localhost:8787) in your browser to start a new RStudio session
6. Install R packages required for this app. Type the following instructions into the R session window of RStudio
    ```
    packrat::on()
    packrat::restore()
    ```
    The installation will take a few minutes. The package library will be installed into the `packrat/lib` directory of the project path.
7.  Open the file `app/global.R` and hit the "Run app" button in the toolbar of the script editor (or type `shiny::runApp("app")` in the R session window). The Shiny app should open in a new window. You may need to instruct your browser to not block popup windows for this URL.

## Data

The data for this app is extracted from [MetaCRAN](https://www.r-pkg.org/) which provides a database of all packages on CRAN and their publication history. The extraction processes transforms and summarises the data for efficient consumption in this app. The app's data is refreshed through a separate R process which runs daily in a Docker container on AWS. The data refresh is published in its own git repository (to be published soon). 


## Deployment

The app is deployed through RStudio's webservice [shinyapps.io](https://shinyapps.io/). Additionally, the app is published on [RStudio Cloud](https://rstudio.cloud/project/258634) which provides a complete development environment of the project.

# testing git with this simple comment -Jason 
