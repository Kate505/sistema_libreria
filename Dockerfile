# Dockerfile
FROM ruby:3.4.4

# Define la carpeta de trabajo
WORKDIR /app

# Instala Rails
RUN gem install rails -v 8.0.2
