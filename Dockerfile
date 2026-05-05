# Dockerfile (Desarrollo)
FROM ruby:3.4.4

WORKDIR /app

# Instala dependencias necesarias del sistema
RUN apt-get update -qq && \
    apt-get install -y build-essential libpq-dev curl gnupg watchman

# Instala Node.js 22
RUN curl -fsSL https://deb.nodesource.com/setup_22.x -o nodesource_setup.sh && \
    bash nodesource_setup.sh && \
    apt-get install -y nodejs

# Habilita Corepack para usar Yarn
RUN corepack enable && corepack prepare yarn@stable --activate

ENV TZ=America/Managua

# Instala Rails
RUN gem install rails -v 8.0.2

# 1. Instala gemas
COPY Gemfile Gemfile.lock ./
RUN bundle install

# 2. Instala paquetes de Node (ESTO FALTABA)
COPY package.json yarn.lock ./
RUN yarn install

# Copia el resto del código
COPY . .

RUN yarn install

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]
