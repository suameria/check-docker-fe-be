FROM node:16

WORKDIR /app

# パッケージのインストール
COPY package.json package-lock.json ./
RUN npm install

# アプリケーションのコピー
COPY . .

# ビルド
RUN npm run build

# サーバーの起動
CMD ["npm", "start"]
