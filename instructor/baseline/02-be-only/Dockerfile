FROM node:22-alpine
WORKDIR /app
COPY src/package.json ./
RUN npm install --omit=dev
COPY src/server.js ./
EXPOSE 3000
CMD ["npm", "start"]
