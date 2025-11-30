# Dockerfile
FROM ruby:3.4.4

# Define la carpeta de trabajo
WORKDIR /app

# Instala dependencias necesarias del sistema
RUN apt-get update -qq && \
    apt-get install -y build-essential libpq-dev curl gnupg &&\
    apt-get install -y watchman

# Instala Node.js (usamos 22.16.0)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x -o nodesource_setup.sh && \
     bash nodesource_setup.sh  && \
    apt-get install -y nodejs

# Habilita Corepack para usar Yarn
RUN corepack enable && corepack prepare yarn@stable --activate

# Instala Rails
RUN gem install rails -v 8.0.2

COPY Gemfile .
COPY Gemfile.lock .

RUN bundle install

COPY . .

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3000

CMD ["rails", "server"]
