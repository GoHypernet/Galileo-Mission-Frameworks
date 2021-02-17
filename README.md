# RStudio

## Overview
- **Industry**: Statistical Data Science

- **Target Container OS**: Linux

- **Source Code**: Open Source

- **Website**: https://rstudio.com/products/rstudio/download/#download

- **Github**: https://github.com/rstudio/rstudio

## Notes

This is a GUI application that requires a reverse proxy.

## Building

```
docker build -t rstudio .
```

## Running

```
docker run --rm -d -p 8888:8888 rstudio
```
