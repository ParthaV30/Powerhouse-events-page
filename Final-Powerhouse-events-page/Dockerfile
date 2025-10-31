FROM nginx:alpine

RUN rm -rf /usr/share/hginx/html/*

COPY Eventmanagement-main/EventPlanner-main /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
