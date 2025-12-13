# Stage 1: Build React App
FROM node:20-alpine as build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Stage 2: Serve with Nginx
FROM nginx:alpine
# Copiamos los archivos del build
COPY --from=build /app/dist /usr/share/nginx/html

# Copiamos la plantilla de configuración
COPY nginx.conf.template /etc/nginx/templates/default.conf.template

# La imagen de nginx:alpine soporta envsubst automáticamente en /etc/nginx/templates/
# Si definimos la variable de entorno BACKEND_URL, la reemplazará en el archivo .conf final.
# IMPORTANTE: La variable debe llamarse exactamente como en el template (${BACKEND_URL}).

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
