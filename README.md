# RStudio

Industry: Statistical Data Science

Target OS: Linux

License: Open Source

Website: https://rstudio.com/products/rstudio/download/#download

Github: https://github.com/rstudio/rstudio

Notes: This is a GUI application that requires a reverse proxy.

docker build -t rstudio .
docker run --rm -d -p 8888:8888 rstudio