# Sistema Librería

![Ruby](https://img.shields.io/badge/Ruby-3.4-red) ![Rails](https://img.shields.io/badge/Rails-8.0.2-blue) ![Docker](https://img.shields.io/badge/Docker-enabled-blue) ![Postgres](https://img.shields.io/badge/Postgres-18-%233367AB)

## Descripción del proyecto

Sistema Librería es una aplicación web desarrollada en Ruby on Rails diseñada para gestionar los procesos operativos de una librería o pequeño comercio de libros: catálogos de productos, proveedores, ventas, compras y gestión de usuarios/roles. Está pensada para ofrecer interfaces CRUD dinámicas y reactivas (Hotwire/Turbo), plantillas con Tailwind/DaisyUI y despliegue fácil mediante Docker.

El objetivo principal es centralizar el catálogo, las relaciones con proveedores y el flujo de ventas/órdenes de compra en una sola aplicación administrativa, reduciendo trabajo manual y asegurando trazabilidad de operaciones.

## Capturas de pantalla

![Screenshot](url-imagen)

> Coloque aquí capturas de la UI (p. ej. lista de productos, formulario de proveedor, panel administrativo).

## Tech stack

- 🟣 Ruby 3.4 (imagen Docker: `ruby:3.4.4`)
- ⚙️ Rails 8.0.2
- 🚀 Hotwire / Turbo (`turbo-rails`) y Stimulus (`stimulus-rails`)
- 🎨 Tailwind CSS (`tailwindcss-rails` y `tailwindcss-ruby`) + DaisyUI (paquete npm)
- 🗄️ PostgreSQL (imagen Docker: `postgres:18`) — configuración en `compose.yml`
- 📦 Bundler (gems), Yarn / npm (paquetes JS)
- 🐳 Docker & Docker Compose (archivo `compose.yml` incluido)

## Características clave

Basado en los controladores y modelos presentes en el repositorio, las funcionalidades principales son:

1. Gestión de catálogo: productos y categorías con vistas listadas y formularios (CRUD).
2. Gestión de proveedores: alta/edición/listado de `proveedor` y relaciones con órdenes de compra.
3. Flujo de ventas y compras: modelos para `venta`, `orden_de_compra` y sus detalles (`detalle_venta`, `detalle_orden_de_compra`).
4. Seguridad y usuarios: autenticación y administración de roles/menus (`user`, `rol`, `roles_user`, `roles_menu`, `seguridad` controllers).
5. Infraestructura moderna de front y UX: Hotwire/Turbo para actualizaciones parciales y Tailwind+DaisyUI para estilos.

## Inputs / Outputs

- Inputs: variables de entorno para conexión a base de datos (`.env`), credenciales y configuración del entorno.
- Outputs: servidor Rails escuchando en el puerto 3000 (por defecto), contenedores Docker para `web` y `db`.
- Modos de error: la app asume que la base de datos está accesible; `rails db:prepare` fallará si credenciales/host son incorrectos.

## Requisitos previos

- Git
- Docker & Docker Compose (o Docker Desktop)
- Ruby (si ejecuta sin contenedor): 3.4.x y Bundler
- Node.js 22.x (si ejecuta sin contenedor)
- Yarn (opcional si usa Yarn)
- PostgreSQL (solo si no usa Docker para la BD)

> Nota: el repositorio incluye `Dockerfile` y `compose.yml` preparados para levantar la aplicación y la base de datos en contenedores.

## Clonar el proyecto

```bash
git clone https://github.com/Kate505/sistema_libreria.git
cd sistema_libreria
git checkout main
```

## Dependencias e instalación (local, sin Docker)

1. Instalar gems:

```bash
bundle install
```

2. Instalar paquetes JS (el proyecto declara `daisyui` en `package.json`):

```bash
# usando Yarn (si está configurado)
yarn install

# o con npm
npm install
```

3. Variables de entorno:

```bash
# Si existe .env.example
cp .env.example .env
# Editar .env con credenciales (POSTGRES_USER, POSTGRES_PASSWORD, POSTGRES_DB, DATABASE_URI, DATABASE_HOST)
```

4. Preparar base de datos local (ajuste `config/database.yml` si usa otro motor):

```bash
rails db:create
rails db:migrate
rails db:seed # opcional
```

## Ejecución — Desarrollo

Opciones disponibles:

1) Usando bin/dev (valide si el script existe y está configurado en `Procfile.dev`):

```bash
# Ejecuta servidor Rails y watcher de CSS/Tailwind (Procfile.dev)
bin/dev
```

2) Rails server directamente:

```bash
rails server -b 0.0.0.0
```

3) Usando Docker Compose (recomendado para entornos reproducibles):

```bash
# Levanta servicios web y db con build
# En PowerShell Windows se recomienda:
docker compose -f compose.yml up --build

# Alternativa (si su CLI usa docker-compose):
docker-compose -f compose.yml up --build
```

El `compose.yml` incluido ejecuta `rails db:prepare` automáticamente antes de iniciar el servidor.

## Ejecución — Producción (sugerida)

1) Construir imagen y ejecutar contenedor (localmente):

```bash
# Construir imagen
docker build -t sistema_libreria .

# Ejecutar (exponiendo el puerto 3000 y usando .env)
docker run --env-file .env -p 3000:3000 --rm sistema_libreria
```

2) Comandos Rails para producción (si se despliega en VM o servidor sin Docker):

```bash
RAILS_ENV=production bundle exec rails assets:precompile
RAILS_ENV=production bundle exec rails db:migrate
RAILS_ENV=production bundle exec rails server -e production -p 3000
```

## Variables de entorno y `.env.example`

El repositorio incluye `.env.example`. Campos detectados:

```
POSTGRES_USERNAME=
POSTGRES_PASSWORD=
DATABASE_URI=
```

El archivo `.env` en el repositorio también contiene variables utilizadas por `compose.yml` (p. ej. `DATABASE_HOST`, `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB`). Asegúrese de sincronizar y proteger este archivo (no subir credenciales reales al repositorio).

## Scripts y utilidades detectadas

- `Procfile.dev` define `web: bin/rails server` y `css: bin/rails tailwindcss:watch`.
- `compose.yml` usa `postgres:18` y arranca `web` con `rails db:prepare && rails server -b 0.0.0.0`.
- `Dockerfile` instala Ruby 3.4.4, Node.js 22.x y prepara la imagen con `entrypoint.sh`.

## Árbol simplificado del proyecto

```
.
├── app
│   ├── controllers
│   │   ├── application_controller.rb
│   │   ├── home_controller.rb
│   │   ├── sessions_controller.rb
│   │   ├── passwords_controller.rb
│   │   ├── catalogos/        # controladores de catálogos (productos, proveedores...)
│   │   └── seguridad/        # autenticación y roles
│   ├── models
│   │   ├── producto.rb
│   │   ├── proveedor.rb
│   │   ├── venta.rb
│   │   ├── orden_de_compra.rb
│   │   └── user.rb
│   └── views
├── config
│   ├── database.yml
│   └── routes.rb
├── db
│   ├── migrate
│   └── seeds.rb
├── Dockerfile
├── compose.yml
├── Gemfile
├── Gemfile.lock
├── package.json
├── Procfile.dev
└── .env.example
```

## Consejos de despliegue y siguientes pasos

- En producción use un servidor de aplicaciones (Puma ya está incluido) y un proxy reverso (NGINX) para manejar TLS y balanceo.
- Use variables de entorno seguras y un servicio de secretos (Vault, AWS Parameter Store) para credenciales.
- Automatice migraciones y precompilado de assets en su pipeline CI/CD. `compose.yml` facilita pruebas locales replicando la arquitectura de contenedores.

