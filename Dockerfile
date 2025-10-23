FROM nginx:alpine

COPY Eventmanagement-main/EventPlanner-main /usr/share/nginx/html

EXPOSE 80
