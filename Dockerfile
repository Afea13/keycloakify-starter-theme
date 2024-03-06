FROM node:18 as keycloakify_jar_builder

COPY ./keycloakify-starter/package.json ./keycloakify-starter/yarn.lock /opt/app/

WORKDIR /opt/app

RUN yarn install --frozen-lockfile

COPY ./keycloakify-starter/ /opt/app/

RUN yarn build-keycloak-theme

FROM quay.io/keycloak/keycloak:latest as builder

WORKDIR /opt/keycloak

COPY --from=keycloakify_jar_builder /opt/app/build_keycloak/target/keycloakify-starter-x-keycloak-theme-4.8.3.jar /opt/keycloak/providers/

RUN /opt/keycloak/bin/kc.sh build

FROM quay.io/keycloak/keycloak:latest
COPY --from=builder /opt/keycloak/ /opt/keycloak/

ENV KC_HOSTNAME=localhost
ENTRYPOINT ["/opt/keycloak/bin/kc.sh","start-dev"]