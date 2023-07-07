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


FROM golang:1.15 as builder
RUN go get github.com/codegangsta/negroni
<Please fill in the required Docker command> go get github.com/gorilla/mux 
<Please fill in the required Docker command> go get github.com/xyproto/simpleredis/v2
COPY main.go .
RUN go build main.go

FROM ubuntu:18.04

<Please fill in the required Docker command> --from=builder /go//main /app/guestbook
<Please fill in the required Docker command> public/index.html /app/public/index.html
<Please fill in the required Docker command> public/script.js /app/public/script.js
<Please fill in the required Docker command> public/style.css /app/public/style.css
<Please fill in the required Docker command> public/jquery.min.js /app/public/jquery.min.js

WORKDIR /app
CMD ["./guestbook"]
<Please fill in the required Docker command> 3000
