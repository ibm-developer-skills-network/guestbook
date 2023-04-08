# Please choose from the below set of Docker commands to complete your Dockerfile:

# COPY
# RUN
# ADD
# EXPOSE
# FROM
# CMD
# PUSH
# PULL
# WORKDIR

# Dockerfile guestbook app  v1
FROM golang:1.15 as builder
RUN go get github.com/codegangsta/negroni
# change url to fix simpleredis dependency v2
RUN go get github.com/gorilla/mux github.com/xyproto/simpleredis/v2
COPY main.go .
RUN go build main.go

FROM ubuntu:18.04

COPY --from=builder /go//main /app/guestbook
COPY public/index.html /app/public/index.html
COPY public/script.js /app/public/script.js
COPY public/style.css /app/public/style.css
COPY public/jquery.min.js /app/public/jquery.min.js

WORKDIR /app
CMD ["./guestbook"]
EXPOSE 3000
