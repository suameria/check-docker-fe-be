ARG NODE_VERSION
FROM node:${NODE_VERSION}

RUN apt update

RUN apt install -y vim less git zip unzip

# Enable to use tsc command
RUN npm install -g typescript

COPY ./.bashrc /root/.bashrc

ARG WORKDIR
WORKDIR ${WORKDIR}
