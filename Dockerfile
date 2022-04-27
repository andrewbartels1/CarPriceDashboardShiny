# Example shiny app docker file
# https://blog.sellorm.com/2021/04/25/shiny-app-in-docker/

# get shiny server and R from the rocker project
FROM rocker/shiny

ENV RENV_VERSION 4.1.3
RUN R -e "install.packages('remotes', repos = c(CRAN = 'https://cloud.r-project.org'))"
RUN R -e "remotes::install_github('rstudio/renv@${RENV_VERSION}')"

# copy the app directory into the image
COPY ./app/* /srv/shiny-server/
COPY ./*.sqlite /srv/
COPY ./*.sqlite3 /srv/


WORKDIR /srv
COPY app/renv.lock /srv/renv.lock
RUN R -e 'renv::restore()'

# run app
CMD ["/usr/bin/shiny-server"]